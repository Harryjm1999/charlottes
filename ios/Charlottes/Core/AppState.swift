import Foundation
import Observation
import Supabase
import SwiftUI

/// Tracks the signed-in person and which restaurants they can manage.
@MainActor
@Observable
final class SessionStore {
  private(set) var user: User?
  private(set) var isLoading = true
  private(set) var access = StaffAccess()
  private(set) var isCheckingAccess = false

  var isStaff: Bool { !access.slugs.isEmpty }

  init() {
    Task { await listen() }
  }

  private func listen() async {
    for await (_, session) in supabase.auth.authStateChanges {
      let next = session?.user
      let changed = next?.id != user?.id
      user = next
      isLoading = false
      if changed { await refreshAccess() }
    }
  }

  func refreshAccess() async {
    guard user != nil else {
      access = StaffAccess()
      return
    }
    isCheckingAccess = true
    if let access = try? await API.staffAccess() { self.access = access }
    isCheckingAccess = false
  }

  func signOut() async throws {
    try await supabase.auth.signOut()
  }

  func deleteAccount() async throws {
    try await API.deleteOwnAccount()
    // The user no longer exists on the server, so only the local session is cleared.
    try? await supabase.auth.signOut(scope: .local)
  }
}

#if DEBUG
  /// The screen the screenshot job asked for.
  let debugScreen: String? = {
    let args = ProcessInfo.processInfo.arguments
    guard let index = args.firstIndex(of: "-screen"), index + 1 < args.count else { return nil }
    return args[index + 1]
  }()
#endif

enum AppTab: String, Hashable {
  case restaurants, book, account
}

enum AccountRoute: Hashable {
  case staff
  #if DEBUG
    case staffDemo
  #endif
}

@MainActor
@Observable
final class AppRouter {
  var tab: AppTab = .restaurants
  var restaurantPath: [Restaurant] = []
  var accountPath = NavigationPath()
  /// Bumped when a booking is made so that lists reload.
  var bookingsVersion = 0

  init() {
    #if DEBUG
      // Lets the screenshot job open a given screen:
      //   -screen restaurants | restaurant | menu | book | confirmation | account | auth | staff | privacy
      if let screen = debugScreen {
        if let tab = AppTab(rawValue: screen) {
          self.tab = tab
        } else if screen == "restaurant" || screen == "menu", let first = Restaurant.all.first {
          restaurantPath = [first]
        } else if screen == "confirmation" {
          tab = .book
        } else if screen == "auth" {
          tab = .account
        } else if screen == "privacy" {
          tab = .account
          accountPath.append(LegalDoc.privacy)
        } else if screen == "staff" {
          tab = .account
          accountPath.append(AccountRoute.staffDemo)
        }
      }
    #endif
  }
}

/// A plain error message to show in an alert.
struct ErrorMessage: Identifiable {
  let id = UUID()
  let title: String
  let message: String

  init(_ title: String, _ error: Error) {
    self.title = title
    message = error.localizedDescription
  }

  init(_ title: String, message: String) {
    self.title = title
    self.message = message
  }
}

extension View {
  func errorAlert(_ item: Binding<ErrorMessage?>) -> some View {
    alert(item.wrappedValue?.title ?? "", isPresented: Binding(
      get: { item.wrappedValue != nil },
      set: { if !$0 { item.wrappedValue = nil } }
    )) {
      Button("OK", role: .cancel) {}
    } message: {
      Text(item.wrappedValue?.message ?? "")
    }
  }
}
