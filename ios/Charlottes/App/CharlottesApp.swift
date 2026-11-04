import SwiftUI
import UIKit

@main
struct CharlottesApp: App {
  @State private var session = SessionStore()
  @State private var router = AppRouter()

  init() {
    let navigationBar = UINavigationBar.appearance()
    if let large = UIFont(name: "CormorantGaramond-SemiBold", size: 34) {
      navigationBar.largeTitleTextAttributes = [.font: large, .foregroundColor: UIColor.brandPrimary]
    }
    if let inline = UIFont(name: "CormorantGaramond-SemiBold", size: 20) {
      navigationBar.titleTextAttributes = [.font: inline, .foregroundColor: UIColor.brandPrimary]
    }
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(session)
        .environment(router)
        .tint(Palette.primary)
    }
  }
}

struct RootView: View {
  @Environment(AppRouter.self) private var router

  var body: some View {
    @Bindable var router = router

    TabView(selection: $router.tab) {
      NavigationStack(path: $router.restaurantPath) {
        RestaurantsView()
      }
      .tabItem { Label("Restaurants", systemImage: "fork.knife") }
      .tag(AppTab.restaurants)

      NavigationStack {
        BookingFormView()
          .navigationTitle("Book a table")
      }
      .tabItem { Label("Book", systemImage: "calendar") }
      .tag(AppTab.book)

      NavigationStack(path: $router.accountPath) {
        AccountView()
      }
      .tabItem { Label("Account", systemImage: "person") }
      .tag(AppTab.account)
    }
  }
}
