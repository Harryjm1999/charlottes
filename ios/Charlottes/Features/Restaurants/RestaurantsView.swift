import SwiftUI

/// The home tab: the brand header, then a card for each restaurant.
struct RestaurantsView: View {
  @Environment(AppRouter.self) private var router

  var body: some View {
    ScrollView {
      VStack(spacing: 0) {
        hero

        VStack(spacing: 16) {
          Text("Find your Charlotte's")
            .font(AppFont.display(28))
            .foregroundStyle(Palette.primary)
            .accessibilityAddTraits(.isHeader)
          DecoRule()

          ForEach(Restaurant.all) { restaurant in
            NavigationLink(value: restaurant) {
              RestaurantCard(restaurant: restaurant)
            }
            .buttonStyle(.plain)
          }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 28)

        footer
      }
    }
    .ignoresSafeArea(edges: .top)
    .background(Palette.background)
    .toolbar(.hidden, for: .navigationBar)
    .navigationDestination(for: Restaurant.self) { RestaurantDetailView(restaurant: $0) }
    .navigationDestination(for: LegalDoc.self) { LegalView(doc: $0) }
  }

  private var hero: some View {
    ZStack {
      GeometryReader { proxy in
        BundleImage(file: Restaurant.heroPhoto)
          .scaledToFill()
          .frame(width: proxy.size.width, height: proxy.size.height)
          .clipped()
          .accessibilityHidden(true)
      }
      Palette.deep.opacity(0.68)

      VStack(spacing: 14) {
        Text("In-Excess Garden Centres")
          .font(AppFont.medium(12))
          .textCase(.uppercase)
          .tracking(3)
          .foregroundStyle(Palette.brass)
        Text("Charlotte's Restaurants & Tea Rooms")
          .font(AppFont.display(36))
          .multilineTextAlignment(.center)
          .foregroundStyle(Palette.onDeep)
          .accessibilityAddTraits(.isHeader)
        DecoRule(width: 180)
        Text("Breakfasts, artisan light lunches and locally sourced sweet treats, served where art deco glamour meets botanical luxury.")
          .font(AppFont.body(15))
          .multilineTextAlignment(.center)
          .foregroundStyle(Palette.onDeep.opacity(0.9))
        Button("Book a table") { router.tab = .book }
          .buttonStyle(.brand(.brass))
          .padding(.top, 4)
      }
      .padding(.horizontal, 24)
      .padding(.top, 72)
      .padding(.bottom, 32)
    }
    .frame(maxWidth: .infinity)
  }

  private var footer: some View {
    VStack(alignment: .leading, spacing: 14) {
      BundleImage(file: "in-excess-logo.png")
        .scaledToFit()
        .frame(width: 120)
        .accessibilityLabel("In-Excess Garden Centres logo")
      Text("Charlotte's Restaurants & Tea Rooms are found inside In-Excess Garden Centres across Hampshire, Wiltshire and Dorset.")
        .font(AppFont.body(14))
        .foregroundStyle(Palette.onDeep.opacity(0.85))
      HStack(spacing: 20) {
        NavigationLink("Privacy policy", value: LegalDoc.privacy)
        NavigationLink("Terms & conditions", value: LegalDoc.terms)
      }
      .font(AppFont.medium(13))
      .tint(Palette.brass)
    }
    .padding(24)
    .frame(maxWidth: .infinity, alignment: .leading)
    .background(Palette.deep)
  }
}

private struct RestaurantCard: View {
  let restaurant: Restaurant

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Color.clear
        .frame(height: 170)
        .overlay {
          BundleImage(file: restaurant.photo).scaledToFill()
        }
        .clipped()
        .accessibilityHidden(true)

      VStack(alignment: .leading, spacing: 6) {
        Text(restaurant.name)
          .font(AppFont.display(23))
          .foregroundStyle(Palette.primary)
          .multilineTextAlignment(.leading)
        Text(restaurant.addressLine)
          .font(AppFont.body(14))
          .foregroundStyle(Palette.secondary)
          .multilineTextAlignment(.leading)
        Label(restaurant.todayText(), systemImage: "clock")
          .font(AppFont.medium(14))
          .foregroundStyle(Palette.text)
          .padding(.top, 2)
      }
      .padding(16)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .background(Palette.surface)
    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    .overlay(
      RoundedRectangle(cornerRadius: 14, style: .continuous)
        .stroke(Palette.border, lineWidth: 1)
    )
    .accessibilityElement(children: .combine)
    .accessibilityHint("Shows menus, hours and directions")
  }
}
