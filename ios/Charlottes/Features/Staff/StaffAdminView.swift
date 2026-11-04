import SwiftUI

/// Bookings for staff, plus staff management for owners. Access comes from the
/// `my_staff_access` function; row-level security on the database is the real boundary.
struct StaffAdminView: View {
  private enum Section: Hashable { case bookings, staff }

  @Environment(SessionStore.self) private var session
  @State private var section = Section.bookings

  var body: some View {
    Group {
      if session.isCheckingAccess && !session.isStaff {
        ProgressView()
          .frame(maxWidth: .infinity, maxHeight: .infinity)
      } else if !session.isStaff {
        ContentUnavailableView(
          "Not linked to a restaurant",
          systemImage: "person.crop.circle.badge.questionmark",
          description: Text("Ask the owner to add your email as staff.")
        )
      } else if section == .staff && session.access.isOwner {
        StaffMembersView()
      } else {
        StaffBookingsView(slugs: session.access.slugs)
      }
    }
    .background(Palette.background)
    .navigationTitle("Staff admin")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      if session.access.isOwner {
        ToolbarItem(placement: .principal) {
          Picker("Admin section", selection: $section) {
            Text("Bookings").tag(Section.bookings)
            Text("Staff").tag(Section.staff)
          }
          .pickerStyle(.segmented)
          .frame(width: 200)
        }
      }
    }
  }
}
