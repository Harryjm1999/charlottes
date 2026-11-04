import SwiftUI
import UIKit

/// An image bundled with the app, referred to by its file name.
struct BundleImage: View {
  let file: String

  var body: some View {
    Image(uiImage: UIImage(named: file) ?? UIImage())
      .resizable()
  }
}

/// The thin brass line used under headings.
struct DecoRule: View {
  var width: CGFloat = 128

  var body: some View {
    LinearGradient(
      colors: [Palette.brass.opacity(0), Palette.brass, Palette.brass.opacity(0)],
      startPoint: .leading,
      endPoint: .trailing
    )
    .frame(width: width, height: 1)
    .accessibilityHidden(true)
  }
}

struct StatusBadge: View {
  let status: BookingStatus

  var body: some View {
    Text(status.label)
      .font(AppFont.semibold(12))
      .foregroundStyle(color)
      .padding(.horizontal, 9)
      .padding(.vertical, 4)
      .overlay(Capsule().stroke(color.opacity(0.6), lineWidth: 1))
      .accessibilityLabel("Status: \(status.label)")
  }

  private var color: Color {
    switch status {
    case .pending: Palette.secondary
    case .accepted: Palette.success
    case .declined: Palette.danger
    }
  }
}
