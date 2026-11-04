import EventKit
import EventKitUI
import SwiftUI

/// What can be added to the person's calendar.
struct CalendarItem: Identifiable {
  let id = UUID()
  let title: String
  let location: String
  let start: Date
  let notes: String?

  init(title: String, location: String, start: Date, notes: String?) {
    self.title = title
    self.location = location
    self.start = start
    self.notes = notes
  }

  init?(booking: Booking) {
    guard let start = Fmt.date(key: booking.bookingDate, time: booking.bookingTime) else { return nil }
    let restaurant = Restaurant.find(booking.restaurantSlug)
    title = "Table: \(booking.restaurantName)"
    location = restaurant.map { "\($0.centre), \($0.addressLine)" } ?? booking.restaurantName
    self.start = start
    notes = "Table for \(booking.guests)."
  }
}

struct AddToCalendarButton: View {
  let item: CalendarItem
  @State private var isPresented = false

  var body: some View {
    Button {
      isPresented = true
    } label: {
      Label("Add to Calendar", systemImage: "calendar.badge.plus")
    }
    .buttonStyle(.brand(fullWidth: true))
    .sheet(isPresented: $isPresented) {
      CalendarEventEditor(item: item).ignoresSafeArea()
    }
  }
}

/// Apple's own "new event" screen. The person confirms the event there, so the app
/// never reads their calendar and doesn't need calendar permission.
struct CalendarEventEditor: UIViewControllerRepresentable {
  let item: CalendarItem

  @Environment(\.dismiss) private var dismiss

  func makeCoordinator() -> Coordinator { Coordinator(dismiss: dismiss) }

  func makeUIViewController(context: Context) -> EKEventEditViewController {
    let store = EKEventStore()
    let event = EKEvent(eventStore: store)
    event.title = item.title
    event.location = item.location
    event.notes = item.notes
    event.timeZone = Fmt.london
    event.startDate = item.start
    event.endDate = item.start.addingTimeInterval(90 * 60)

    let controller = EKEventEditViewController()
    controller.eventStore = store
    controller.event = event
    controller.editViewDelegate = context.coordinator
    return controller
  }

  func updateUIViewController(_ uiViewController: EKEventEditViewController, context: Context) {}

  final class Coordinator: NSObject, EKEventEditViewDelegate {
    let dismiss: DismissAction

    init(dismiss: DismissAction) {
      self.dismiss = dismiss
    }

    func eventEditViewController(
      _ controller: EKEventEditViewController,
      didCompleteWith action: EKEventEditViewAction
    ) {
      dismiss()
    }
  }
}
