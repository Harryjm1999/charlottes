import Foundation

/// Row types for the database shared with the website
/// (src/integrations/supabase/types.ts).

enum BookingStatus: String {
  case pending, accepted, declined

  var label: String {
    switch self {
    case .pending: "Awaiting reply"
    case .accepted: "Accepted"
    case .declined: "Declined"
    }
  }
}

struct Booking: Decodable, Identifiable, Hashable {
  let id: UUID
  let restaurantSlug: String
  let name: String
  let email: String
  let phone: String
  let bookingDate: String
  let bookingTime: String
  let guests: Int
  let notes: String?
  let statusRaw: String
  let source: String

  enum CodingKeys: String, CodingKey {
    case id, name, email, phone, guests, notes, source
    case restaurantSlug = "restaurant_slug"
    case bookingDate = "booking_date"
    case bookingTime = "booking_time"
    case statusRaw = "status"
  }

  var status: BookingStatus { BookingStatus(rawValue: statusRaw) ?? .pending }
  var restaurantName: String { Restaurant.find(restaurantSlug)?.name ?? restaurantSlug }
  var guestsLabel: String { guests == 1 ? "1 guest" : "\(guests) guests" }
  var isUpcoming: Bool { bookingDate >= Fmt.key(Date()) }

  func withStatus(_ status: BookingStatus) -> Booking {
    Booking(
      id: id, restaurantSlug: restaurantSlug, name: name, email: email, phone: phone,
      bookingDate: bookingDate, bookingTime: bookingTime, guests: guests, notes: notes,
      statusRaw: status.rawValue, source: source
    )
  }
}

/// A customer's table request. Guests have no user id, as on the website.
struct NewBooking: Encodable {
  let restaurant_slug: String
  let name: String
  let email: String
  let phone: String
  let booking_date: String
  let booking_time: String
  let guests: Int
  let notes: String?
  let user_id: String?
}

/// The fields staff can edit. `notes` is always sent so that it can be cleared.
struct BookingFields: Encodable {
  let restaurant_slug: String
  let name: String
  let email: String
  let phone: String
  let booking_date: String
  let booking_time: String
  let guests: Int
  let notes: String?

  enum CodingKeys: String, CodingKey {
    case restaurant_slug, name, email, phone, booking_date, booking_time, guests, notes
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(restaurant_slug, forKey: .restaurant_slug)
    try container.encode(name, forKey: .name)
    try container.encode(email, forKey: .email)
    try container.encode(phone, forKey: .phone)
    try container.encode(booking_date, forKey: .booking_date)
    try container.encode(booking_time, forKey: .booking_time)
    try container.encode(guests, forKey: .guests)
    try container.encode(notes, forKey: .notes)
  }
}

struct StaffMember: Decodable, Identifiable, Hashable {
  let id: UUID
  let email: String
  let restaurantSlug: String

  enum CodingKeys: String, CodingKey {
    case id, email
    case restaurantSlug = "restaurant_slug"
  }

  var restaurantName: String { Restaurant.find(restaurantSlug)?.name ?? restaurantSlug }
}

struct StaffAccess: Equatable {
  var isOwner = false
  var slugs: [String] = []
}

/// Whether a string looks like an email address.
func isValidEmail(_ value: String) -> Bool {
  value.range(of: #"^[^@\s]+@[^@\s]+\.[^@\s]+$"#, options: .regularExpression) != nil
}
