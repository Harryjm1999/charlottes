import SwiftUI

/// Owners only: who can see which restaurant's bookings.
struct StaffMembersView: View {
  @State private var members: [StaffMember] = []
  @State private var isLoading = true
  @State private var email = ""
  @State private var slug = Restaurant.all[0].slug
  @State private var isAdding = false
  @State private var addError: String?
  @State private var removing: StaffMember?
  @State private var error: ErrorMessage?

  var body: some View {
    List {
      Section {
        TextField("staff@example.com", text: $email)
          .keyboardType(.emailAddress)
          .textContentType(.emailAddress)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
        Picker("Restaurant", selection: $slug) {
          ForEach(Restaurant.all) { Text($0.name).tag($0.slug) }
        }
        Button(isAdding ? "Adding…" : "Add staff") {
          Task { await add() }
        }
        .disabled(isAdding || email.trimmingCharacters(in: .whitespaces).isEmpty)
      } header: {
        Text("Add staff")
      } footer: {
        VStack(alignment: .leading, spacing: 6) {
          if let addError {
            Text(addError).foregroundStyle(Palette.danger)
          }
          Text("They sign up or sign in with that same email and Staff admin appears in their account.")
        }
      }
      .brandRow()

      Section("Staff") {
        if isLoading && members.isEmpty {
          ProgressView().frame(maxWidth: .infinity)
        } else if members.isEmpty {
          Text("No staff added yet.").foregroundStyle(Palette.secondary)
        } else {
          ForEach(members) { member in
            VStack(alignment: .leading, spacing: 2) {
              Text(member.email)
              Text(member.restaurantName)
                .font(AppFont.caption())
                .foregroundStyle(Palette.secondary)
            }
            .swipeActions(edge: .trailing) {
              Button("Remove") { removing = member }
                .tint(Palette.danger)
            }
          }
        }
      }
      .brandRow()
    }
    .brandList()
    .keyboardDoneButton()
    .refreshable { await load() }
    .task { await load() }
    .errorAlert($error)
    .confirmationDialog(
      "Remove staff member?",
      isPresented: Binding(get: { removing != nil }, set: { if !$0 { removing = nil } }),
      titleVisibility: .visible,
      presenting: removing
    ) { member in
      Button("Remove", role: .destructive) { Task { await remove(member) } }
      Button("Cancel", role: .cancel) {}
    } message: { member in
      Text("\(member.email) will lose access to \(member.restaurantName).")
    }
  }

  private func load() async {
    isLoading = true
    defer { isLoading = false }
    do {
      members = try await API.staffMembers()
    } catch is CancellationError {
      return
    } catch {
      self.error = ErrorMessage("Could not load staff", error)
    }
  }

  private func add() async {
    addError = nil
    isAdding = true
    defer { isAdding = false }
    do {
      try await API.addStaff(email: email, slug: slug)
      email = ""
      await load()
    } catch {
      addError = error.localizedDescription
    }
  }

  private func remove(_ member: StaffMember) async {
    do {
      try await API.removeStaff(id: member.id)
      await load()
    } catch {
      self.error = ErrorMessage("Could not remove staff member", error)
    }
  }
}
