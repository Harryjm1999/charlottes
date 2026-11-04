import MapKit
import SwiftUI

struct RestaurantDetailView: View {
  let restaurant: Restaurant

  @State private var openMenu: MenuSelection?
  @State private var isBooking = false

  private struct MenuSelection: Identifiable {
    let index: Int
    var id: Int { index }
  }

  private var menus: [Restaurant.Menu] { restaurant.menus + [Restaurant.allergens] }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Color.clear
          .frame(height: 210)
          .overlay { BundleImage(file: restaurant.photo).scaledToFill() }
          .clipped()
          .accessibilityHidden(true)

        VStack(alignment: .leading, spacing: 24) {
          header
          actions
          hoursCard
          menusSection
          mapSection
        }
        .padding(.horizontal, 20)
      }
      .padding(.bottom, 32)
    }
    .background(Palette.background)
    .navigationTitle(shortTitle)
    .navigationBarTitleDisplayMode(.inline)
    .fullScreenCover(item: $openMenu) { selection in
      MenuViewer(menus: menus, start: selection.index)
    }
    .sheet(isPresented: $isBooking) {
      NavigationStack {
        BookingFormView(lockedRestaurant: restaurant)
          .navigationTitle("Reserve a table")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .cancellationAction) {
              Button("Close") { isBooking = false }
            }
          }
      }
    }
  }

  private var shortTitle: String {
    restaurant.address.first { ["Fair Oak", "Landford", "Ringwood", "Salisbury"].contains($0) } ?? "Restaurant"
  }

  private var header: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(restaurant.centre)
        .font(AppFont.medium(12))
        .textCase(.uppercase)
        .tracking(2)
        .foregroundStyle(Palette.secondary)
      Text(restaurant.name)
        .font(AppFont.display(32))
        .foregroundStyle(Palette.primary)
        .accessibilityAddTraits(.isHeader)
      Text(restaurant.addressLine)
        .font(AppFont.body(15))
        .foregroundStyle(Palette.secondary)
    }
  }

  private var actions: some View {
    VStack(spacing: 10) {
      Button("Reserve a table") { isBooking = true }
        .buttonStyle(.brand(fullWidth: true))
      HStack(spacing: 10) {
        if let phoneURL = restaurant.phoneURL {
          Link(destination: phoneURL) {
            Label("Call", systemImage: "phone")
          }
          .buttonStyle(.brand(.outline, fullWidth: true))
          .accessibilityLabel("Call \(restaurant.phone)")
        }
        directionsMenu
      }
    }
  }

  private var directionsMenu: some View {
    Menu {
      if let appleMaps = restaurant.appleMaps {
        Link("Apple Maps", destination: appleMaps)
      }
      Link("Google Maps", destination: restaurant.googleMaps)
    } label: {
      Label("Directions", systemImage: "arrow.triangle.turn.up.right.diamond")
        .font(AppFont.semibold(15))
        .foregroundStyle(Palette.primary)
        .frame(maxWidth: .infinity, minHeight: 44)
        .padding(.vertical, 14)
        .overlay(
          RoundedRectangle(cornerRadius: 10, style: .continuous)
            .stroke(Palette.border, lineWidth: 1)
        )
    }
  }

  private var hoursCard: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text("Opening hours")
        .font(AppFont.display(22))
        .foregroundStyle(Palette.primary)
        .accessibilityAddTraits(.isHeader)
      ForEach(restaurant.hoursText, id: \.self) { line in
        Text(line).font(AppFont.body(15)).foregroundStyle(Palette.text)
      }
      if !restaurant.serviceTimes.isEmpty {
        Divider().overlay(Palette.border).padding(.vertical, 4)
        ForEach(restaurant.serviceTimes, id: \.self) { line in
          Text(line).font(AppFont.caption()).foregroundStyle(Palette.secondary)
        }
      }
    }
    .brandCard()
  }

  private var menusSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Our menus")
        .font(AppFont.display(26))
        .foregroundStyle(Palette.primary)
        .accessibilityAddTraits(.isHeader)
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          ForEach(Array(menus.enumerated()), id: \.element.id) { index, menu in
            Button {
              openMenu = MenuSelection(index: index)
            } label: {
              VStack(spacing: 8) {
                BundleImage(file: menu.file)
                  .scaledToFill()
                  .frame(width: 124, height: 170)
                  .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                  .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                      .stroke(Palette.border, lineWidth: 1)
                  )
                Text(menu.label)
                  .font(AppFont.medium(14))
                  .foregroundStyle(Palette.text)
              }
            }
            .buttonStyle(.plain)
            .accessibilityLabel("\(menu.label) menu")
            .accessibilityHint("Opens the menu full screen")
          }
        }
        .padding(.horizontal, 20)
      }
      .padding(.horizontal, -20)
    }
  }

  private var mapSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Find us")
        .font(AppFont.display(26))
        .foregroundStyle(Palette.primary)
        .accessibilityAddTraits(.isHeader)
      Map(initialPosition: .region(MKCoordinateRegion(
        center: restaurant.coordinate,
        latitudinalMeters: 1500,
        longitudinalMeters: 1500
      ))) {
        Marker(restaurant.centre, systemImage: "fork.knife", coordinate: restaurant.coordinate)
          .tint(Palette.primary)
      }
      .frame(height: 190)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .allowsHitTesting(false)
      .accessibilityLabel("Map showing \(restaurant.centre)")
    }
  }
}
