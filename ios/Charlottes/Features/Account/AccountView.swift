import SwiftUI

struct AccountView: View {
  @Environment(SessionStore.self) private var session
  @Environment(AppRouter.self) private var router

  @State private var isSigningIn = false
  @State private var bookings: [Booking] = []
  @State private var isLoading = false
  @State private var loadFailed = false
  @State private var error: ErrorMessage?
  @State private var isConfirmingDelete = false
  @State private var isConfirmingDeleteFinal = false
  @State private var isDeleting = false
  @State private var deletedNotice = false

  var body: some View {
    Group {
      if session.isLoading {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
          .background(Palette.background)
      } else if let user = session.user {
        signedIn(email: user.email ?? "your account")
          .task(id: "\(user.id)-\(router.bookingsVersion)") { await load() }
      } else {
        signedOut
      }
    }
    .navigationTitle("My bookings")
    .navigationDestination(for: LegalDoc.self) { LegalView(doc: $0) }
    .navigationDestination(for: AccountRoute.self) { route in
      switch route {
      case .staff:
        StaffAdminView()
      #if DEBUG
        case .staffDemo:
          StaffBookingsView(slugs: Restaurant.all.map(\.slug), demo: Booking.demo)
            .navigationTitle("Staff admin")
      #endif
      }
    }
    #if DEBUG
      .onAppear {
        if debugScreen == "auth" { isSigningIn = true }
      }
    #endif
    .sheet(isPresented: $isSigningIn) { AuthView() }
    .errorAlert($error)
    .alert("Account deleted", isPresented: $deletedNotice) {
      Button("OK", role: .cancel) {}
    } message: {
      Text("Your account has been deleted. You can still book a table without an account.")
    }
  }

  private var signedOut: some View {
    List {
      Section {
        VStack(alignment: .leading, spacing: 12) {
          DecoRule()
          Text("Sign in or create an account to see the status of your table bookings. You can still book a table without an account.")
            .foregroundStyle(Palette.secondary)
          Button("Sign in") { isSigningIn = true }
            .buttonStyle(.brand(fullWidth: true))
        }
        .padding(.vertical, 8)
      }
      .unclippedRow()

      legalSection
    }
    .brandList()
  }

  private func signedIn(email: String) -> some View {
    let upcoming = bookings.filter(\.isUpcoming).reversed()
    let past = bookings.filter { !$0.isUpcoming }

    return List {
      Section {
        LabeledContent("Signed in as", value: email)
      }
      .brandRow()

      if session.isStaff {
        Section {
          NavigationLink("Staff admin", value: AccountRoute.staff)
        }
        .brandRow()
      }

      if isLoading && bookings.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity)
          .listRowBackground(Color.clear)
      } else if loadFailed && bookings.isEmpty {
        Section {
          Text("We couldn't load your bookings.").foregroundStyle(Palette.danger)
          Button("Try again") { Task { await load() } }
        }
        .brandRow()
      } else if bookings.isEmpty {
        Section {
          Text("No bookings yet.").foregroundStyle(Palette.secondary)
          Button("Book a table") { router.tab = .book }
        }
        .brandRow()
      }

      if !upcoming.isEmpty {
        Section("Upcoming") {
          ForEach(Array(upcoming)) { BookingRow(booking: $0) }
        }
        .brandRow()
      }

      if !past.isEmpty {
        Section("Past") {
          ForEach(past) { BookingRow(booking: $0) }
        }
        .brandRow()
      }

      legalSection

      Section {
        Button("Sign out") { Task { await signOut() } }
      }
      .brandRow()

      Section {
        Button(role: .destructive) {
          isConfirmingDelete = true
        } label: {
          HStack {
            Text("Delete account")
            if isDeleting {
              Spacer()
              ProgressView()
            }
          }
        }
        .disabled(isDeleting)
      } footer: {
        Text("Permanently deletes your Charlotte's account and sign-in details.")
      }
      .brandRow()
    }
    .brandList()
    .refreshable { await load() }
    .confirmationDialog(
      "Delete your account?",
      isPresented: $isConfirmingDelete,
      titleVisibility: .visible
    ) {
      Button("Delete account", role: .destructive) { isConfirmingDeleteFinal = true }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This permanently deletes the account for \(email). You will be signed out and won't see your booking history in the app. Bookings you have already made are kept by the restaurant so your table is still honoured.")
    }
    .alert("Are you sure?", isPresented: $isConfirmingDeleteFinal) {
      Button("Delete permanently", role: .destructive) { Task { await deleteAccount() } }
      Button("Cancel", role: .cancel) {}
    } message: {
      Text("This cannot be undone.")
    }
  }

  private var legalSection: some View {
    Section {
      NavigationLink("Privacy policy", value: LegalDoc.privacy)
      NavigationLink("Terms & conditions", value: LegalDoc.terms)
    }
    .brandRow()
  }

  private func load() async {
    guard let id = session.user?.id else { return }
    isLoading = true
    defer { isLoading = false }
    do {
      bookings = try await API.myBookings(userId: id)
      loadFailed = false
    } catch is CancellationError {
      return
    } catch {
      loadFailed = true
    }
  }

  private func signOut() async {
    do {
      try await session.signOut()
      bookings = []
    } catch {
      self.error = ErrorMessage("Sign out failed", error)
    }
  }

  private func deleteAccount() async {
    isDeleting = true
    defer { isDeleting = false }
    do {
      try await session.deleteAccount()
      bookings = []
      deletedNotice = true
    } catch {
      self.error = ErrorMessage(
        "Could not delete account",
        message: "Please try again, or email customerservice@in-excess.co.uk and we will delete your account for you."
      )
    }
  }
}

private struct BookingRow: View {
  let booking: Booking
  @State private var calendarItem: CalendarItem?

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text(booking.restaurantName)
        .font(AppFont.display(20))
        .foregroundStyle(Palette.primary)
      Text("\(Fmt.prettyDay(booking.bookingDate)) at \(booking.bookingTime) · \(booking.guestsLabel)")
        .font(AppFont.body(14))
        .foregroundStyle(Palette.secondary)
      StatusBadge(status: booking.status)
    }
    .padding(.vertical, 4)
    .accessibilityElement(children: .combine)
    .swipeActions(edge: .trailing) {
      if booking.isUpcoming && booking.status != .declined {
        Button("Add to Calendar", systemImage: "calendar.badge.plus") {
          calendarItem = CalendarItem(booking: booking)
        }
        .tint(Palette.primary)
      }
    }
    .sheet(item: $calendarItem) { item in
      CalendarEventEditor(item: item).ignoresSafeArea()
    }
  }
}
