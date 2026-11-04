import SwiftUI

/// The month grid from the website's admin page. Tap a day to select it; swipe
/// sideways or use the arrows to change month.
struct MonthCalendarView: View {
  struct DayCount {
    var total = 0
    var pending = 0
  }

  @Binding var month: Date
  @Binding var day: String
  let counts: [String: DayCount]

  private static let weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
  private static let cellHeight: CGFloat = 58

  /// Each cell of the grid: a day key, or nil for the blanks around the month.
  private var cells: [String?] {
    let calendar = Fmt.calendar
    let weekday = calendar.component(.weekday, from: month)
    let leading = (weekday + 5) % 7
    let days = calendar.range(of: .day, in: .month, for: month)?.count ?? 30
    var cells: [String?] = Array(repeating: nil, count: leading)
    for offset in 0..<days {
      if let date = calendar.date(byAdding: .day, value: offset, to: month) {
        cells.append(Fmt.key(date))
      }
    }
    while cells.count % 7 != 0 { cells.append(nil) }
    return cells
  }

  private var weeks: [[String?]] {
    let cells = cells
    return stride(from: 0, to: cells.count, by: 7).map { Array(cells[$0..<($0 + 7)]) }
  }

  var body: some View {
    VStack(spacing: 8) {
      HStack {
        Button {
          move(by: -1)
        } label: {
          Image(systemName: "chevron.left").frame(width: 44, height: 44)
        }
        .accessibilityLabel("Previous month")
        Spacer()
        Text(Fmt.monthTitle(month))
          .font(AppFont.display(22))
          .foregroundStyle(Palette.primary)
          .accessibilityAddTraits(.isHeader)
        Spacer()
        Button("Today") {
          let now = Date()
          day = Fmt.key(now)
          month = StaffBookingsView.firstOfMonth(now)
        }
        .font(AppFont.medium(14))
        Button {
          move(by: 1)
        } label: {
          Image(systemName: "chevron.right").frame(width: 44, height: 44)
        }
        .accessibilityLabel("Next month")
      }
      .buttonStyle(.borderless)

      // Plain stacks with fixed-height cells, not a lazy grid: this sits in a List row, which
      // sizes itself from its content and crashes in a layout loop if that height shifts.
      VStack(spacing: 0) {
        HStack(spacing: 0) {
          ForEach(Self.weekdays, id: \.self) { name in
            Text(name)
              .font(AppFont.caption(12))
              .foregroundStyle(Palette.secondary)
              .lineLimit(1)
              .frame(maxWidth: .infinity)
          }
        }
        .padding(.bottom, 6)

        ForEach(weeks.indices, id: \.self) { index in
          HStack(spacing: 0) {
            ForEach(weeks[index].indices, id: \.self) { column in
              if let key = weeks[index][column] {
                dayCell(key)
              } else {
                Color.clear.frame(maxWidth: .infinity).frame(height: Self.cellHeight)
              }
            }
          }
        }
      }
    }
    .contentShape(Rectangle())
    .simultaneousGesture(
      DragGesture(minimumDistance: 30).onEnded { value in
        let dx = value.translation.width
        if abs(dx) > 60 && abs(dx) > abs(value.translation.height) * 1.5 {
          move(by: dx < 0 ? 1 : -1)
        }
      }
    )
  }

  private func dayCell(_ key: String) -> some View {
    let count = counts[key]
    let selected = key == day
    let isToday = key == Fmt.key(Date())
    let foreground = selected ? Palette.onPrimary : Palette.text

    return Button {
      day = key
    } label: {
      VStack(spacing: 1) {
        Text(String(Int(key.suffix(2)) ?? 0))
          .font(isToday ? AppFont.semibold(15) : AppFont.body(15))
          .underline(isToday && !selected)
        if let count {
          Text("\(count.total) bkg\(count.total == 1 ? "" : "s")")
            .font(AppFont.caption(10))
          if count.pending > 0 {
            Text("\(count.pending) pending")
              .font(AppFont.caption(9))
              .foregroundStyle(selected ? Palette.onPrimary : Palette.danger)
              .lineLimit(1)
              .minimumScaleFactor(0.7)
          }
        }
        Spacer(minLength: 0)
      }
      .foregroundStyle(foreground)
      .padding(.top, 5)
      .frame(maxWidth: .infinity)
      .frame(height: Self.cellHeight)
      .background(selected ? Palette.primary : Palette.surface)
      .overlay(Rectangle().stroke(Palette.border, lineWidth: 0.5))
    }
    .buttonStyle(.plain)
    .accessibilityLabel(accessibilityText(key, count))
    .accessibilityAddTraits(selected ? .isSelected : [])
  }

  private func accessibilityText(_ key: String, _ count: DayCount?) -> String {
    guard let count else { return "\(Fmt.prettyDay(key)), no bookings" }
    return "\(Fmt.prettyDay(key)), \(count.total) bookings, \(count.pending) awaiting reply"
  }

  private func move(by months: Int) {
    let calendar = Fmt.calendar
    guard let next = calendar.date(byAdding: .month, value: months, to: month) else { return }
    let selectedDay = Int(day.suffix(2)) ?? 1
    let lastDay = calendar.range(of: .day, in: .month, for: next)?.count ?? 28
    month = next
    if let date = calendar.date(byAdding: .day, value: min(selectedDay, lastDay) - 1, to: next) {
      day = Fmt.key(date)
    }
  }
}
