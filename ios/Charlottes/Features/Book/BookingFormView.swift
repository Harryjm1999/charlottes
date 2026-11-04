import SwiftUI

/// The table request form. Works signed out, as on the website.
struct BookingFormView: View {
  var lockedRestaurant: Restaurant?

  @Environment(SessionStore.self) private var session
  @Environment(AppRouter.self) private var router

  @State private var slug = Restaurant.all[0].slug
  @State private var date = Date()
  @State private var time = ""
  @State private var guests = 2
  @State private var name = ""
  @State private var phone = ""
  @State private var email = ""
  @State private var notes = ""
  @State private var isSending = false
  @State private var showErrors = false
  @State private var sendError: String?
  @State private var submitted: Submitted?

  private struct Submitted {
    let firstName: String
    let restaurant: Restaurant
    let dayKey: String
    let time: String
    let guests: Int
  }

  private static let daysAhead = 60

  private var restaurant: Restaurant {
    lockedRestaurant ?? Restaurant.find(slug) ?? Restaurant.all[0]
  }

  private var dateRange: ClosedRange<Date> {
    let today = Fmt.calendar.startOfDay(for: Date())
    let last = Fmt.calendar.date(byAdding: .day, value: Self.daysAhead - 1, to: today) ?? today
    return today...last
  }

  private var slots: [String] { restaurant.slots(on: date) }

  private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }
  private var trimmedPhone: String { phone.trimmingCharacters(in: .whitespacesAndNewlines) }
  private var trimmedEmail: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }

  private var nameError: String? { trimmedName.isEmpty ? "Name is required" : nil }
  private var phoneError: String? { trimmedPhone.isEmpty ? "Phone is required" : nil }
  private var emailError: String? {
    if trimmedEmail.isEmpty { return "Email is required" }
    return isValidEmail(trimmedEmail) ? nil : "Please enter a valid email address"
  }

  var body: some View {
    Group {
      if let submitted {
        confirmation(submitted)
      } else {
        form
      }
    }
    .onAppear {
      if let lockedRestaurant { slug = lockedRestaurant.slug }
      if email.isEmpty, let address = session.user?.email { email = address }
      chooseTime()
      #if DEBUG
        if debugScreen == "confirmation" {
          submitted = Submitted(
            firstName: "Sam", restaurant: restaurant, dayKey: Fmt.key(Date()), time: "12:30", guests: 2
          )
        }
      #endif
    }
    .onChange(of: date) { chooseTime() }
    .onChange(of: slug) { chooseTime() }
  }

  /// Keeps the chosen time valid for the restaurant and day, preferring lunchtime.
  private func chooseTime() {
    let available = slots
    if !available.contains(time) {
      time = available.contains("12:30") ? "12:30" : (available.first ?? "")
    }
  }

  private var form: some View {
    Form {
      if lockedRestaurant == nil {
        Section {
          Picker("Restaurant", selection: $slug) {
            ForEach(Restaurant.all) { Text($0.name).tag($0.slug) }
          }
          .pickerStyle(.navigationLink)
        }
        .brandRow()
      } else {
        Section {
          LabeledContent("Restaurant", value: restaurant.name)
        }
        .brandRow()
      }

      Section("When") {
        DatePicker("Date", selection: $date, in: dateRange, displayedComponents: .date)
          .datePickerStyle(.graphical)
          .environment(\.timeZone, Fmt.london)
          .environment(\.calendar, Fmt.calendar)
        if slots.isEmpty {
          Text("No more tables today. Please choose another day.")
            .foregroundStyle(Palette.secondary)
        } else {
          Picker("Time", selection: $time) {
            ForEach(slots, id: \.self) { Text($0).tag($0) }
          }
        }
        Stepper(value: $guests, in: 1...12) {
          LabeledContent("Guests", value: "\(guests)")
        }
      }
      .brandRow()

      Section {
        field("Name", text: $name, error: nameError)
          .textContentType(.name)
          .textInputAutocapitalization(.words)
        field("Phone", text: $phone, error: phoneError)
          .textContentType(.telephoneNumber)
          .keyboardType(.phonePad)
        field("Email", text: $email, error: emailError)
          .textContentType(.emailAddress)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
      } header: {
        Text("Your details")
      }
      .brandRow()

      Section("Notes") {
        TextField("Allergies, high chairs, occasions", text: $notes, axis: .vertical)
          .lineLimit(2...5)
      }
      .brandRow()

      Section {
        Button {
          Task { await send() }
        } label: {
          HStack(spacing: 8) {
            if isSending { ProgressView().tint(Palette.onPrimary) }
            Text(isSending ? "Sending…" : "Request table")
          }
        }
        .buttonStyle(.brand(fullWidth: true))
        .disabled(isSending || slots.isEmpty)
        .unclippedRow()
      } footer: {
        VStack(alignment: .leading, spacing: 8) {
          if let sendError {
            Text(sendError).foregroundStyle(Palette.danger)
          }
          Text("Requests are confirmed by the team, or call \(restaurant.phone) to book straight away.")
        }
        .padding(.top, 8)
      }
    }
    .brandList()
    .scrollDismissesKeyboard(.interactively)
    .keyboardDoneButton()
    .sensoryFeedback(.success, trigger: submitted != nil)
  }

  @ViewBuilder
  private func field(_ title: String, text: Binding<String>, error: String?) -> some View {
    VStack(alignment: .leading, spacing: 4) {
      TextField(title, text: text)
      if showErrors, let error {
        Text(error)
          .font(AppFont.caption())
          .foregroundStyle(Palette.danger)
      }
    }
  }

  private func send() async {
    showErrors = true
    sendError = nil
    guard nameError == nil, phoneError == nil, emailError == nil, !time.isEmpty else { return }

    isSending = true
    defer { isSending = false }
    let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
    let dayKey = Fmt.key(date)
    do {
      try await API.requestTable(
        NewBooking(
          restaurant_slug: restaurant.slug,
          name: trimmedName,
          email: trimmedEmail,
          phone: trimmedPhone,
          booking_date: dayKey,
          booking_time: time,
          guests: guests,
          notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
          user_id: session.user?.id.db
        )
      )
      submitted = Submitted(
        firstName: trimmedName.components(separatedBy: " ").first ?? trimmedName,
        restaurant: restaurant,
        dayKey: dayKey,
        time: time,
        guests: guests
      )
      router.bookingsVersion += 1
    } catch {
      sendError = "Sorry, we couldn't send that. Please try again or call us."
    }
  }

  private func reset() {
    notes = ""
    showErrors = false
    date = Date()
    submitted = nil
    chooseTime()
  }

  private func confirmation(_ booking: Submitted) -> some View {
    ScrollView {
      VStack(spacing: 16) {
        Image(systemName: "checkmark.circle")
          .font(.system(size: 44))
          .foregroundStyle(Palette.success)
          .accessibilityHidden(true)
        Text("Thank you, \(booking.firstName)")
          .font(AppFont.display(30))
          .foregroundStyle(Palette.primary)
          .multilineTextAlignment(.center)
          .accessibilityAddTraits(.isHeader)
        DecoRule()
        Text("We've noted your request for a table of \(booking.guests) at \(booking.restaurant.name) on \(Fmt.prettyDay(booking.dayKey)) at \(booking.time).")
          .foregroundStyle(Palette.secondary)
          .multilineTextAlignment(.center)
        Text("A member of the team will confirm shortly. For an immediate booking please call us.")
          .multilineTextAlignment(.center)

        VStack(spacing: 10) {
          AddToCalendarButton(
            item: CalendarItem(
              title: "Table request: \(booking.restaurant.name)",
              location: "\(booking.restaurant.centre), \(booking.restaurant.addressLine)",
              start: Fmt.date(key: booking.dayKey, time: booking.time) ?? Date(),
              notes: "Table for \(booking.guests). Awaiting confirmation from the restaurant."
            )
          )
          if let phoneURL = booking.restaurant.phoneURL {
            Link(destination: phoneURL) {
              Label("Call \(booking.restaurant.phone)", systemImage: "phone")
            }
            .buttonStyle(.brand(.outline, fullWidth: true))
          }
          Button("Make another booking") { reset() }
            .buttonStyle(.brand(.outline, fullWidth: true))
        }
        .padding(.top, 8)
      }
      .font(AppFont.body())
      .padding(24)
      .brandCard(padding: 8)
      .padding(20)
    }
    .background(Palette.background)
  }
}
