import SwiftUI

/// Edit a booking, or add a phone booking when `booking` is nil.
struct BookingEditorView: View {
  let booking: Booking?
  let slugs: [String]
  let defaultDay: String

  @Environment(\.dismiss) private var dismiss

  @State private var slug = ""
  @State private var name = ""
  @State private var phone = ""
  @State private var email = ""
  @State private var date = Date()
  @State private var time = Date()
  @State private var guests = 2
  @State private var notes = ""
  @State private var staffNote = ""
  @State private var isSaving = false
  @State private var errorText: String?
  @State private var didPrepare = false

  private var trimmedEmail: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }

  private var validationError: String? {
    if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Name is required." }
    if phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { return "Phone is required." }
    if !trimmedEmail.isEmpty && !isValidEmail(trimmedEmail) { return "Please enter a valid email address." }
    return nil
  }

  var body: some View {
    NavigationStack {
      Form {
        if slugs.count > 1 {
          Section("Restaurant") {
            Picker("Restaurant", selection: $slug) {
              ForEach(slugs, id: \.self) { Text(Restaurant.find($0)?.name ?? $0).tag($0) }
            }
          }
          .brandRow()
        }

        Section("Customer") {
          TextField("Name", text: $name)
            .textInputAutocapitalization(.words)
          TextField("Phone", text: $phone)
            .keyboardType(.phonePad)
          TextField("Email (optional)", text: $email)
            .keyboardType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
        }
        .brandRow()

        Section("Table") {
          DatePicker("Date", selection: $date, displayedComponents: .date)
          DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
          Stepper(value: $guests, in: 1...20) {
            LabeledContent("Guests", value: "\(guests)")
          }
        }
        .environment(\.timeZone, Fmt.london)
        .environment(\.calendar, Fmt.calendar)
        .environment(\.locale, Locale(identifier: "en_GB"))
        .brandRow()

        Section("Customer requests") {
          TextField("Requests", text: $notes, axis: .vertical)
            .lineLimit(2...5)
        }
        .brandRow()

        Section {
          TextField("Staff-only note", text: $staffNote, axis: .vertical)
            .lineLimit(2...5)
        } header: {
          Text("Staff-only note")
        } footer: {
          Text("The customer never sees this.")
        }
        .brandRow()

        if let errorText {
          Section {
            Text(errorText).foregroundStyle(Palette.danger)
          }
          .brandRow()
        }
      }
      .brandList()
      .navigationTitle(booking == nil ? "New phone booking" : "Edit booking")
      .navigationBarTitleDisplayMode(.inline)
      .keyboardDoneButton()
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
          if isSaving {
            ProgressView()
          } else {
            Button("Save") { Task { await save() } }
          }
        }
      }
    }
    .task { await prepare() }
  }

  private func prepare() async {
    guard !didPrepare else { return }
    didPrepare = true
    slug = booking?.restaurantSlug ?? slugs.first ?? ""
    name = booking?.name ?? ""
    phone = booking?.phone ?? ""
    email = booking?.email ?? ""
    guests = booking?.guests ?? 2
    notes = booking?.notes ?? ""
    let dayKey = booking?.bookingDate ?? defaultDay
    date = Fmt.date(key: dayKey) ?? Date()
    time = Fmt.date(key: dayKey, time: booking?.bookingTime ?? "12:00") ?? Date()
    if let booking, let note = try? await API.staffNote(bookingId: booking.id), staffNote.isEmpty {
      staffNote = note
    }
  }

  private func save() async {
    errorText = validationError
    guard errorText == nil else { return }

    isSaving = true
    defer { isSaving = false }
    let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
    do {
      try await API.saveBooking(
        bookingId: booking?.id,
        fields: BookingFields(
          restaurant_slug: slug,
          name: name.trimmingCharacters(in: .whitespacesAndNewlines),
          email: trimmedEmail,
          phone: phone.trimmingCharacters(in: .whitespacesAndNewlines),
          booking_date: Fmt.key(date),
          booking_time: Fmt.time(time),
          guests: guests,
          notes: trimmedNotes.isEmpty ? nil : trimmedNotes
        ),
        staffNote: staffNote
      )
      dismiss()
    } catch {
      errorText = error.localizedDescription
    }
  }
}
