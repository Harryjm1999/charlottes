import Foundation

/// Booking dates are plain `yyyy-MM-dd` strings and times are `HH:mm` strings, the same
/// as the website. Everything is worked out in UK time, wherever the phone is.
enum Fmt {
  static let london = TimeZone(identifier: "Europe/London") ?? .current

  static let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = london
    calendar.locale = Locale(identifier: "en_GB")
    calendar.firstWeekday = 2
    return calendar
  }()

  private static func formatter(_ format: String) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.calendar = calendar
    formatter.timeZone = london
    formatter.locale = Locale(identifier: "en_GB")
    formatter.dateFormat = format
    return formatter
  }

  private static let keyFormatter = formatter("yyyy-MM-dd")
  private static let timeFormatter = formatter("HH:mm")
  private static let prettyFormatter = formatter("EEEE d MMMM")
  private static let monthFormatter = formatter("MMMM yyyy")
  private static let dateTimeFormatter = formatter("yyyy-MM-dd HH:mm")

  static func key(_ date: Date) -> String { keyFormatter.string(from: date) }
  static func time(_ date: Date) -> String { timeFormatter.string(from: date) }
  static func date(key: String) -> Date? { keyFormatter.date(from: key) }
  static func date(key: String, time: String) -> Date? { dateTimeFormatter.date(from: "\(key) \(time)") }
  static func monthTitle(_ date: Date) -> String { monthFormatter.string(from: date) }

  static func prettyDay(_ key: String) -> String {
    date(key: key).map(prettyFormatter.string(from:)) ?? key
  }

  /// A time of day in minutes as "9.00am", the way the restaurants write it.
  static func clock(minutes: Int) -> String {
    let hour = minutes / 60
    let shown = hour > 12 ? hour - 12 : hour
    return "\(shown).\(String(format: "%02d", minutes % 60))\(hour >= 12 ? "pm" : "am")"
  }

  static func slot(minutes: Int) -> String {
    String(format: "%02d:%02d", minutes / 60, minutes % 60)
  }
}
