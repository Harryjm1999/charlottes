import Foundation
import Supabase

extension UUID {
  /// Lowercase form, as Postgres prints UUIDs.
  var db: String { uuidString.lowercased() }
}

struct APIError: LocalizedError {
  let message: String
  var errorDescription: String? { message }
}

/// Data access for the database shared with the website. Table, column and function
/// names must stay identical to the website's queries.
enum API {
  // MARK: Customer bookings

  static func myBookings(userId: UUID) async throws -> [Booking] {
    try await supabase
      .from("bookings")
      .select()
      .eq("user_id", value: userId.db)
      .order("booking_date", ascending: false)
      .execute()
      .value
  }

  /// A table request. Guests can only insert, so nothing is read back.
  static func requestTable(_ booking: NewBooking) async throws {
    if booking.user_id != nil {
      try await supabase.from("bookings").insert(booking, returning: .minimal).execute()
    } else {
      try await guestInsert(booking)
    }
  }

  /// Publishable keys aren't JWTs, so signed out the website sends this one in the `apikey`
  /// header only. The Swift client would also send it as a bearer token, so this request
  /// is made directly to match the website exactly.
  private static func guestInsert(_ booking: NewBooking) async throws {
    var request = URLRequest(url: SupabaseConfig.url.appendingPathComponent("rest/v1/bookings"))
    request.httpMethod = "POST"
    request.setValue(SupabaseConfig.publishableKey, forHTTPHeaderField: "apikey")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
    request.httpBody = try JSONEncoder().encode(booking)
    let (_, response) = try await URLSession.shared.data(for: request)
    guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
      throw APIError(message: "The booking wasn't accepted.")
    }
  }

  // MARK: Account

  private struct StaffAccessRow: Decodable {
    let is_owner: Bool
    let slugs: [String]
  }

  static func staffAccess() async throws -> StaffAccess {
    let rows: [StaffAccessRow] = try await supabase.rpc("my_staff_access").execute().value
    guard let row = rows.first else { return StaffAccess() }
    return StaffAccess(isOwner: row.is_owner, slugs: row.slugs)
  }

  /// Permanently deletes the signed-in account. Bookings stay with the restaurant,
  /// unlinked from the account.
  static func deleteOwnAccount() async throws {
    try await supabase.rpc("delete_own_account").execute()
  }

  // MARK: Staff

  static func staffBookings(slugs: [String]) async throws -> [Booking] {
    try await supabase
      .from("bookings")
      .select()
      .in("restaurant_slug", values: slugs)
      .order("booking_date", ascending: true)
      .order("booking_time", ascending: true)
      .execute()
      .value
  }

  static func setStatus(bookingId: UUID, status: BookingStatus) async throws {
    try await supabase
      .from("bookings")
      .update(["status": status.rawValue], returning: .minimal)
      .eq("id", value: bookingId.db)
      .execute()
  }

  private struct NoteRow: Decodable {
    let note: String
  }

  /// The staff-only note on a booking. Customers never see it.
  static func staffNote(bookingId: UUID) async throws -> String {
    let rows: [NoteRow] = try await supabase
      .from("booking_notes")
      .select("note")
      .eq("booking_id", value: bookingId.db)
      .limit(1)
      .execute()
      .value
    return rows.first?.note ?? ""
  }

  private struct NoteUpsert: Encodable {
    let booking_id: String
    let note: String
    let updated_at: String
  }

  private struct PhoneBooking: Encodable {
    let id: String
    let fields: BookingFields

    enum CodingKeys: String, CodingKey { case id, status, source }

    func encode(to encoder: Encoder) throws {
      try fields.encode(to: encoder)
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(id, forKey: .id)
      try container.encode("accepted", forKey: .status)
      try container.encode("phone", forKey: .source)
    }
  }

  /// Edits a booking, or adds a phone booking when `bookingId` is nil.
  static func saveBooking(bookingId: UUID?, fields: BookingFields, staffNote: String) async throws {
    let id: UUID
    if let bookingId {
      id = bookingId
      try await supabase
        .from("bookings")
        .update(fields, returning: .minimal)
        .eq("id", value: id.db)
        .execute()
    } else {
      id = UUID()
      try await supabase
        .from("bookings")
        .insert(PhoneBooking(id: id.db, fields: fields), returning: .minimal)
        .execute()
    }
    if !staffNote.isEmpty || bookingId != nil {
      try await supabase
        .from("booking_notes")
        .upsert(
          NoteUpsert(
            booking_id: id.db,
            note: staffNote,
            updated_at: ISO8601DateFormatter().string(from: Date())
          ),
          returning: .minimal
        )
        .execute()
    }
  }

  static func staffMembers() async throws -> [StaffMember] {
    try await supabase
      .from("staff_members")
      .select("id,email,restaurant_slug")
      .order("email", ascending: true)
      .execute()
      .value
  }

  private struct NewStaff: Encodable {
    let email: String
    let restaurant_slug: String
  }

  static func addStaff(email: String, slug: String) async throws {
    do {
      try await supabase
        .from("staff_members")
        .insert(
          NewStaff(email: email.trimmingCharacters(in: .whitespaces).lowercased(), restaurant_slug: slug),
          returning: .minimal
        )
        .execute()
    } catch let error as PostgrestError where error.code == "23505" {
      throw APIError(message: "Already added to that restaurant.")
    }
  }

  static func removeStaff(id: UUID) async throws {
    try await supabase
      .from("staff_members")
      .delete(returning: .minimal)
      .eq("id", value: id.db)
      .execute()
  }
}
