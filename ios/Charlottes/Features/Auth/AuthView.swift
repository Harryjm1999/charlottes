import Supabase
import SwiftUI

/// Email and password only. No redirect is ever passed: the Supabase project is managed by
/// Lovable, so emailed confirmation and reset links open the website by design.
struct AuthView: View {
  private enum Mode: Hashable { case signIn, signUp }

  @Environment(SessionStore.self) private var session
  @Environment(\.dismiss) private var dismiss

  @State private var mode = Mode.signIn
  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""
  @State private var busy = false
  @State private var errorText: String?
  @State private var awaitingConfirmation: String?
  @State private var isResetting = false
  @State private var notice: ErrorMessage?

  private var trimmedEmail: String { email.trimmingCharacters(in: .whitespacesAndNewlines) }

  var body: some View {
    NavigationStack {
      Group {
        if let awaitingConfirmation {
          confirmEmail(awaitingConfirmation)
        } else {
          form
        }
      }
      .navigationTitle(mode == .signIn ? "Welcome back" : "Create your account")
      .navigationBarTitleDisplayMode(.inline)
      .navigationDestination(for: LegalDoc.self) { LegalView(doc: $0) }
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Close") { dismiss() }
        }
      }
      .keyboardDoneButton()
      .errorAlert($notice)
      .alert("Reset password", isPresented: $isResetting) {
        TextField("Email", text: $email)
          .textContentType(.emailAddress)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
        Button("Send link") { Task { await sendReset() } }
        Button("Cancel", role: .cancel) {}
      } message: {
        Text("We'll email you a link to set a new password on our website.")
      }
    }
    .onChange(of: session.user?.id) { _, id in
      if id != nil { dismiss() }
    }
  }

  private var form: some View {
    Form {
      Section {
        Picker("Account", selection: $mode) {
          Text("Sign in").tag(Mode.signIn)
          Text("Sign up").tag(Mode.signUp)
        }
        .pickerStyle(.segmented)
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets())
      } footer: {
        Text(
          mode == .signIn
            ? "Sign in to see your bookings."
            : "Create an account to keep track of your bookings. You can still book a table without one."
        )
        .padding(.top, 8)
      }

      Section {
        TextField("Email", text: $email)
          .textContentType(.username)
          .keyboardType(.emailAddress)
          .textInputAutocapitalization(.never)
          .autocorrectionDisabled()
        SecureField("Password", text: $password)
          .textContentType(mode == .signIn ? .password : .newPassword)
        if mode == .signUp {
          SecureField("Confirm password", text: $confirmPassword)
            .textContentType(.newPassword)
        }
      } footer: {
        if mode == .signUp {
          Text("Must be at least 6 characters.")
        }
      }
      .brandRow()

      Section {
        Button {
          Task { await submit() }
        } label: {
          HStack(spacing: 8) {
            if busy { ProgressView().tint(Palette.onPrimary) }
            Text(mode == .signIn ? "Sign in" : "Sign up")
          }
        }
        .buttonStyle(.brand(fullWidth: true))
        .disabled(busy)
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
      } footer: {
        if let errorText {
          Text(errorText)
            .foregroundStyle(Palette.danger)
            .padding(.top, 8)
        }
      }

      if mode == .signIn {
        Section {
          Button("Forgot password?") { isResetting = true }
        }
        .brandRow()
      } else {
        Section("By creating an account you agree to these") {
          NavigationLink("Terms & conditions", value: LegalDoc.terms)
          NavigationLink("Privacy policy", value: LegalDoc.privacy)
        }
        .brandRow()
      }
    }
    .brandList()
    .onChange(of: mode) { errorText = nil }
  }

  private func confirmEmail(_ address: String) -> some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        Text("Confirm your email")
          .font(AppFont.display(30))
          .foregroundStyle(Palette.primary)
          .accessibilityAddTraits(.isHeader)
        Text("We sent a confirmation link to \(address). It opens our website in your browser. Confirm your email there, then come back and sign in.")
          .font(AppFont.body())
          .foregroundStyle(Palette.secondary)
        if let errorText {
          Text(errorText).font(AppFont.body(14)).foregroundStyle(Palette.danger)
        }
        Button("I've confirmed my email") {
          Task { await signInAfterConfirming() }
        }
        .buttonStyle(.brand(fullWidth: true))
        .disabled(busy)
        Button("Send the email again") {
          Task { await resend(address) }
        }
        .buttonStyle(.brand(.outline, fullWidth: true))
        .disabled(busy)
        Button("Back to sign in") {
          awaitingConfirmation = nil
          errorText = nil
          mode = .signIn
        }
        .frame(maxWidth: .infinity)
      }
      .padding(20)
    }
    .background(Palette.background)
  }

  private func submit() async {
    errorText = nil
    guard isValidEmail(trimmedEmail) else {
      errorText = "Please enter a valid email address."
      return
    }
    guard password.count >= 6 else {
      errorText = "Password must be at least 6 characters."
      return
    }
    if mode == .signUp, password != confirmPassword {
      errorText = "Passwords do not match."
      return
    }

    busy = true
    defer { busy = false }
    do {
      switch mode {
      case .signIn:
        try await supabase.auth.signIn(email: trimmedEmail, password: password)
      case .signUp:
        let response = try await supabase.auth.signUp(email: trimmedEmail.lowercased(), password: password)
        if response.session == nil {
          awaitingConfirmation = trimmedEmail.lowercased()
        }
      }
    } catch {
      errorText = error.localizedDescription
    }
  }

  private func signInAfterConfirming() async {
    errorText = nil
    busy = true
    defer { busy = false }
    do {
      try await supabase.auth.signIn(email: trimmedEmail, password: password)
    } catch {
      errorText = "Your email doesn't look confirmed yet. Open the link in the email first."
    }
  }

  private func resend(_ address: String) async {
    errorText = nil
    busy = true
    defer { busy = false }
    do {
      try await supabase.auth.resend(email: address, type: .signup)
      notice = ErrorMessage("Email sent", message: "We sent another confirmation email to \(address).")
    } catch {
      errorText = error.localizedDescription
    }
  }

  private func sendReset() async {
    guard isValidEmail(trimmedEmail) else {
      notice = ErrorMessage("Reset password", message: "Please enter a valid email address.")
      return
    }
    do {
      try await supabase.auth.resetPasswordForEmail(trimmedEmail)
      notice = ErrorMessage(
        "Check your email",
        message: "We've sent a reset link to \(trimmedEmail). It opens a page in your browser where you set a new password. Then come back here and sign in."
      )
    } catch {
      notice = ErrorMessage("Reset failed", error)
    }
  }
}
