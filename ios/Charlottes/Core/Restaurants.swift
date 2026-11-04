import CoreLocation
import Foundation

/// The four restaurants, from the website's src/data/restaurants.ts.
struct Restaurant: Identifiable, Hashable {
  struct Menu: Identifiable, Hashable {
    let label: String
    let file: String
    var id: String { label }
  }

  /// Opening times in minutes from midnight.
  struct Hours {
    let open: Int
    let close: Int
  }

  let slug: String
  let name: String
  let centre: String
  let phone: String
  let address: [String]
  let hoursText: [String]
  var serviceTimes: [String] = []
  let googleMaps: URL
  let latitude: Double
  let longitude: Double
  let photo: String
  let weekdayHours: Hours
  let sundayHours: Hours
  let menus: [Menu]

  var id: String { slug }
  var addressLine: String { address.joined(separator: ", ") }
  var coordinate: CLLocationCoordinate2D { .init(latitude: latitude, longitude: longitude) }
  var phoneURL: URL? { URL(string: "tel:\(phone.replacingOccurrences(of: " ", with: ""))") }

  var appleMaps: URL? {
    var components = URLComponents(string: "https://maps.apple.com/")
    components?.queryItems = [URLQueryItem(name: "daddr", value: "\(centre), \(addressLine)")]
    return components?.url
  }

  static func == (lhs: Restaurant, rhs: Restaurant) -> Bool { lhs.slug == rhs.slug }
  func hash(into hasher: inout Hasher) { hasher.combine(slug) }

  func hours(on date: Date) -> Hours {
    Fmt.calendar.component(.weekday, from: date) == 1 ? sundayHours : weekdayHours
  }

  func todayText(now: Date = Date()) -> String {
    let today = hours(on: now)
    return "Today \(Fmt.clock(minutes: today.open)) – \(Fmt.clock(minutes: today.close))"
  }

  /// Half-hour table slots, up to half an hour before closing. Times already gone
  /// are left out when the date is today.
  func slots(on date: Date, now: Date = Date()) -> [String] {
    let day = self.hours(on: date)
    var earliest = day.open
    if Fmt.key(date) == Fmt.key(now) {
      let parts = Fmt.calendar.dateComponents([.hour, .minute], from: now)
      earliest = max(earliest, (parts.hour ?? 0) * 60 + (parts.minute ?? 0) + 1)
    }
    return stride(from: day.open, to: day.close, by: 30)
      .filter { $0 >= earliest }
      .map(Fmt.slot(minutes:))
  }

  static func find(_ slug: String) -> Restaurant? { all.first { $0.slug == slug } }

  static let allergens = Menu(label: "Allergens", file: "allergen-info.jpg")
  static let heroPhoto = "rest-7.jpg"

  private static let breakfast = Menu(label: "Breakfast", file: "FO_LF_Breakfast25.jpg")
  private static let lunch = Menu(label: "Lunch", file: "FO_LF_Lunch25.jpg")
  private static let snacks = Menu(label: "Snacks", file: "FO_LF_Snacks.jpg")
  private static let kids = Menu(label: "Children's", file: "FO_LF_Kids.jpg")
  private static let afternoonTea = Menu(label: "Afternoon Tea", file: "FO_LF_RW_Afternoon_Tea_NEW.jpg")
  private static let creamTea = Menu(label: "Cream Tea", file: "SGC_Cream_Tea.jpg")

  static let all: [Restaurant] = [
    Restaurant(
      slug: "fair-oak",
      name: "Charlotte's Restaurant at Fair Oak",
      centre: "In-Excess Fair Oak Garden Centre",
      phone: "02380 697250",
      address: ["Winchester Road", "Fair Oak", "Eastleigh", "SO50 7HD"],
      hoursText: ["Monday – Saturday: 9.00am – 4.30pm", "Sunday: 10.00am – 3.30pm"],
      googleMaps: URL(string: "https://www.google.com/maps/search/?api=1&query=In-Excess+Fair+Oak+Garden+Centre")!,
      latitude: 50.97890938780038,
      longitude: -1.3066324095823214,
      photo: "rest-1.jpg",
      weekdayHours: Hours(open: 540, close: 990),
      sundayHours: Hours(open: 600, close: 930),
      menus: [breakfast, lunch, snacks, kids, afternoonTea, creamTea]
    ),
    Restaurant(
      slug: "landford",
      name: "Charlotte's Luxury Restaurant at Landford",
      centre: "In-Excess Landford Garden Centre",
      phone: "01794 390426",
      address: ["Southampton Road", "Landford", "Salisbury", "SP5 2BE"],
      hoursText: ["Monday – Saturday: 9.00am – 5.30pm", "Sunday: 10.00am – 4.00pm"],
      serviceTimes: [
        "Mon – Sat: Breakfast 9.00 – 11.45 · Lunch 12.00 – 2.30 · High tea 2.30 – 4.30",
        "Sunday: Breakfast 10.00 – 11.30 · Lunch 12.30 – 2.30 · High tea 2.30 – 3.30",
        "Tea, filter coffee and cake served until close",
      ],
      googleMaps: URL(string: "https://www.google.com/maps/search/?api=1&query=In-Excess+Landford+Garden+Centre")!,
      latitude: 50.97671920210393,
      longitude: -1.6282875801082732,
      photo: "rest-3.jpg",
      weekdayHours: Hours(open: 540, close: 1050),
      sundayHours: Hours(open: 600, close: 960),
      menus: [breakfast, lunch, snacks, kids, afternoonTea, creamTea]
    ),
    Restaurant(
      slug: "ringwood",
      name: "Charlotte's Tea Room at Ringwood",
      centre: "In-Excess Ringwood Garden Centre",
      phone: "01425 489328",
      address: ["Forest Corner", "Poulner Hill", "Ringwood", "BH24 3HW"],
      hoursText: ["Monday – Saturday: 9.30am – 4.30pm", "Sunday: 10.00am – 3.00pm"],
      googleMaps: URL(string: "https://www.google.com/maps/search/?api=1&query=In-Excess+Ringwood+Garden+Centre")!,
      latitude: 50.85141763940678,
      longitude: -1.7506827525780426,
      photo: "rest-5.jpg",
      weekdayHours: Hours(open: 570, close: 990),
      sundayHours: Hours(open: 600, close: 900),
      menus: [
        Menu(label: "Breakfast", file: "RW_Breakfast25.jpg"),
        Menu(label: "Lunch", file: "RW_Lunch25.jpg"),
        afternoonTea,
        creamTea,
      ]
    ),
    Restaurant(
      slug: "salisbury",
      name: "Charlotte's Tea Room at Salisbury",
      centre: "In-Excess Salisbury Garden Centre",
      phone: "01722 744918",
      address: ["Netherhampton Road", "Salisbury", "SP2 8PR"],
      hoursText: ["Monday – Saturday: 9.30am – 4.30pm", "Sunday: 10.00am – 3.00pm"],
      googleMaps: URL(string: "https://www.google.com/maps/search/?api=1&query=In-Excess+Salisbury+Garden+Centre")!,
      latitude: 51.06327147946431,
      longitude: -1.8388582485006204,
      photo: "rest-7.jpg",
      weekdayHours: Hours(open: 570, close: 990),
      sundayHours: Hours(open: 600, close: 900),
      menus: [
        Menu(label: "Savoury", file: "SGC_Savoury_DraftREDUCED25_copy.jpg"),
        Menu(label: "Sweet", file: "SGC_Sweet_DraftREDUCED25_copy.jpg"),
        creamTea,
      ]
    ),
  ]
}
