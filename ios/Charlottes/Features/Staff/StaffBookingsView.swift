import SwiftUI

struct StaffBookingsView: View {
  private enum Mode: Hashable { case day, awaiting, all }

  private enum Editing: Identifiable {
    case new
    case edit(Booking)

    var id: String {
      switch self {
      case .new: "new"
      case .edit(let booking): booking.id.uuidString
      }
    }
  }

  let slugs: [String]
  /// Sample bookings for the screenshot job; never set in a release build.
  var demo: [Booking]?

  @State private var bookings: [Booking] = []
  @State private var isLoading = true
  @State private var loadFailed = false
  @State private var mode = Mode.day
  @State private var day = Fmt.key(Date())
  @State private var month = StaffBookingsView.firstOfMonth(Date())
  @State private var restaurantFilter = "all"
  @State private var search = ""
  @State private var editing: Editing?
  @State private var error: ErrorMessage?

  static func firstOfMonth(_ date: Date) -> Date {
    let parts = Fmt.calendar.dateComponents([.year, .month], from: date)
    return Fmt.calendar.date(from: parts) ?? date
  }

  private func restaurantMatches(_ booking: Booking) -> Bool {
    restaurantFilter == "all" || booking.restaurantSlug == restaurantFilter
  }

  private var shown: [Booking] {
    let query = search.trimmingCharacters(in: .whitespaces).lowercased()
    return bookings.filter { booking in
      guard restaurantMatches(booking) else { return false }
      switch mode {
      case .day: if booking.bookingDate != day { return false }
      case .awaiting: if booking.status != .pending { return false }
      case .all: break
      }
      if query.isEmpty { return true }
      return [booking.name, booking.email, booking.phone].contains { $0.lowercased().contains(query) }
    }
  }

  private var pendingCount: Int { bookings.filter { $0.status == .pending }.count }

  private var dayCounts: [String: MonthCalendarView.DayCount] {
    var counts: [String: MonthCalendarView.DayCount] = [:]
    for booking in bookings where restaurantMatches(booking) && booking.status != .declined {
      var count = counts[booking.bookingDate] ?? .init()
      count.total += 1
      if booking.status == .pending { count.pending += 1 }
      counts[booking.bookingDate] = count
    }
    return counts
  }

  var body: some View {
    let shown = shown

    List {
      Section {
        Picker("Booking view", selection: $mode) {
          Text("Day").tag(Mode.day)
          Text("Awaiting (\(pendingCount))").tag(Mode.awaiting)
          Text("All").tag(Mode.all)
        }
        .pickerStyle(.segmented)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())

        if mode == .day {
          MonthCalendarView(
            month: $month,
            day: $day,
            counts: dayCounts
          )
          .unclippedRow()
        }
      }
      .listRowSeparator(.hidden)

      Section {
        if isLoading && bookings.isEmpty {
          ProgressView().frame(maxWidth: .infinity)
        } else if loadFailed && bookings.isEmpty {
          Text("We couldn't load the bookings.").foregroundStyle(Palette.danger)
          Button("Try again") { Task { await load() } }
        } else if shown.isEmpty {
          Text("Nothing here right now.").foregroundStyle(Palette.secondary)
        } else {
          ForEach(shown) { booking in
            StaffBookingRow(
              booking: booking,
              onDecide: { status in Task { await decide(booking, status) } },
              onEdit: { editing = .edit(booking) }
            )
            .swipeActions(edge: .leading) {
              if booking.status != .accepted {
                Button("Accept") { Task { await decide(booking, .accepted) } }
                  .tint(Palette.success)
              }
            }
            .swipeActions(edge: .trailing) {
              if booking.status != .declined {
                Button("Decline") { Task { await decide(booking, .declined) } }
                  .tint(Palette.danger)
              }
            }
          }
        }
      } header: {
        if mode == .day {
          let guests = shown.filter { $0.status != .declined }.reduce(0) { $0 + $1.guests }
          Text("\(Fmt.prettyDay(day)) · \(shown.count) bookings · \(guests) guests")
        }
      }
      .brandRow()
    }
    .brandList()
    .searchable(text: $search, prompt: "Name, email or phone")
    .refreshable { await load() }
    .toolbar {
      ToolbarItemGroup(placement: .topBarTrailing) {
        if slugs.count > 1 {
          Menu {
            Picker("Restaurant", selection: $restaurantFilter) {
              Text("All restaurants").tag("all")
              ForEach(slugs, id: \.self) { slug in
                Text(Restaurant.find(slug)?.name ?? slug).tag(slug)
              }
            }
          } label: {
            Label(
              "Filter by restaurant",
              systemImage: restaurantFilter == "all"
                ? "line.3.horizontal.decrease.circle"
                : "line.3.horizontal.decrease.circle.fill"
            )
          }
        }
        Button {
          editing = .new
        } label: {
          Label("Add a phone booking", systemImage: "plus")
        }
      }
    }
    .sheet(item: $editing, onDismiss: { Task { await load() } }) { target in
      switch target {
      case .new:
        BookingEditorView(booking: nil, slugs: slugs, defaultDay: day)
      case .edit(let booking):
        BookingEditorView(booking: booking, slugs: slugs, defaultDay: day)
      }
    }
    .errorAlert($error)
    .task { await load() }
  }

  private func load() async {
    if let demo {
      bookings = demo
      isLoading = false
      return
    }
    isLoading = true
    defer { isLoading = false }
    do {
      bookings = try await API.staffBookings(slugs: slugs)
      loadFailed = false
    } catch is CancellationError {
      return
    } catch {
      loadFailed = true
    }
  }

  private func decide(_ booking: Booking, _ status: BookingStatus) async {
    do {
      if demo == nil { try await API.setStatus(bookingId: booking.id, status: status) }
      if let index = bookings.firstIndex(where: { $0.id == booking.id }) {
        bookings[index] = booking.withStatus(status)
      }
    } catch {
      self.error = ErrorMessage("Could not update booking", error)
    }
  }
}

private struct StaffBookingRow: View {
  let booking: Booking
  let onDecide: (BookingStatus) -> Void
  let onEdit: () -> Void

  var body: some View {
    VStack(alignment: .leading, spacing: 6) {
      Text("\(booking.bookingTime) · \(booking.name) · \(booking.guestsLabel)")
        .font(AppFont.display(20))
        .foregroundStyle(Palette.primary)
      Text("\(Fmt.prettyDay(booking.bookingDate)) · \(booking.restaurantName)\(booking.source == "phone" ? " · by phone" : "")")
        .font(AppFont.body(14))
      HStack(spacing: 12) {
        if let url = URL(string: "tel:\(booking.phone.replacingOccurrences(of: " ", with: ""))") {
          Link(booking.phone, destination: url).buttonStyle(.borderless)
        }
        if !booking.email.isEmpty, let url = URL(string: "mailto:\(booking.email)") {
          Link(booking.email, destination: url)
            .buttonStyle(.borderless)
            .lineLimit(1)
        }
      }
      .font(AppFont.body(14))
      if let notes = booking.notes, !notes.isEmpty {
        Text("\"\(notes)\"")
          .font(AppFont.body(14))
          .italic()
          .foregroundStyle(Palette.secondary)
      }
      StatusBadge(status: booking.status)
      HStack(spacing: 8) {
        if booking.status != .accepted {
          Button("Accept") { onDecide(.accepted) }
            .buttonStyle(.brand(compact: true))
        }
        if booking.status != .declined {
          Button("Decline") { onDecide(.declined) }
            .buttonStyle(.brand(.outline, compact: true))
        }
        Button("Edit", action: onEdit)
          .buttonStyle(.brand(.outline, compact: true))
      }
      .padding(.top, 4)
    }
    .padding(.vertical, 6)
  }
}

#if DEBUG
  extension Booking {
    static var demo: [Booking] {
      let today = Fmt.key(Date())
      func booking(_ slug: String, _ name: String, _ time: String, _ guests: Int, _ status: String, _ notes: String?, _ source: String = "online") -> Booking {
        Booking(
          id: UUID(), restaurantSlug: slug, name: name, email: "\(name.split(separator: " ")[0].lowercased())@example.com",
          phone: "07700 900123", bookingDate: today, bookingTime: time, guests: guests,
          notes: notes, statusRaw: status, source: source
        )
      }
      return [
        booking("fair-oak", "Sam Taylor", "11:30", 2, "accepted", nil),
        booking("fair-oak", "Alex Morgan", "12:30", 4, "pending", "One high chair please"),
        booking("landford", "Jo Patel", "14:00", 6, "accepted", "Birthday tea", "phone"),
      ]
    }
  }
#endif
