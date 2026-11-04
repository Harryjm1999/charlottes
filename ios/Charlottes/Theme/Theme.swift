import SwiftUI
import UIKit

/// Charlotte's brand: cream and deep green with brass trim, from the website's
/// tokens (src/styles.css). Dark mode uses the deep greens as the ground.
enum Palette {
  static let background = Color(uiColor: .brand(light: 0xFAF7EC, dark: 0x08180E))
  static let surface = Color(uiColor: .brand(light: 0xFEFCF6, dark: 0x0E2517))
  static let text = Color(uiColor: .brand(light: 0x112418, dark: 0xFAF5E6))
  static let secondary = Color(uiColor: .brand(light: 0x536255, dark: 0x98AA9B))
  static let border = Color(uiColor: .brand(light: 0xD9D4C2, dark: 0x273E2F))
  static let primary = Color(uiColor: .brandPrimary)
  static let onPrimary = Color(uiColor: .brand(light: 0xFAF5E6, dark: 0x08180E))
  static let danger = Color(uiColor: .brand(light: 0xC9302D, dark: 0xF66D67))
  static let onDanger = Color(uiColor: .brand(light: 0xFFFFFF, dark: 0x08180E))
  static let success = Color(uiColor: .brand(light: 0x2E7D4F, dark: 0x5BC489))
  static let brass = Color(uiColor: UIColor(hex: 0xC29F57))
  static let deep = Color(uiColor: UIColor(hex: 0x0E2517))
  static let onDeep = Color(uiColor: UIColor(hex: 0xFAF5E6))
}

extension UIColor {
  convenience init(hex: UInt32) {
    self.init(
      red: CGFloat((hex >> 16) & 0xFF) / 255,
      green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255,
      alpha: 1
    )
  }

  static func brand(light: UInt32, dark: UInt32) -> UIColor {
    UIColor { $0.userInterfaceStyle == .dark ? UIColor(hex: dark) : UIColor(hex: light) }
  }

  static let brandPrimary = UIColor.brand(light: 0x193B26, dark: 0xC29F57)
}

/// Cormorant Garamond for headings and Karla for body text, as on the website.
/// Every size scales with the person's Dynamic Type setting.
enum AppFont {
  static func display(_ size: CGFloat = 26) -> Font {
    .custom("CormorantGaramond-SemiBold", size: size, relativeTo: .title)
  }

  static func body(_ size: CGFloat = 16) -> Font {
    .custom("Karla-Regular", size: size, relativeTo: .body)
  }

  static func medium(_ size: CGFloat = 16) -> Font {
    .custom("Karla-Medium", size: size, relativeTo: .body)
  }

  static func semibold(_ size: CGFloat = 16) -> Font {
    .custom("Karla-SemiBold", size: size, relativeTo: .body)
  }

  static func caption(_ size: CGFloat = 13) -> Font {
    .custom("Karla-Regular", size: size, relativeTo: .caption)
  }
}

struct BrandButtonStyle: ButtonStyle {
  enum Variant { case primary, outline, danger, brass }

  var variant: Variant = .primary
  var compact = false
  var fullWidth = false

  @Environment(\.isEnabled) private var isEnabled

  func makeBody(configuration: Configuration) -> some View {
    configuration.label
      .font(AppFont.semibold(compact ? 13 : 15))
      .multilineTextAlignment(.center)
      .padding(.horizontal, compact ? 12 : 18)
      .padding(.vertical, compact ? 9 : 14)
      .frame(maxWidth: fullWidth ? .infinity : nil, minHeight: 44)
      .foregroundStyle(foreground)
      .background(background)
      .overlay(
        RoundedRectangle(cornerRadius: 10, style: .continuous)
          .stroke(stroke, lineWidth: 1)
      )
      .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
      .opacity(isEnabled ? (configuration.isPressed ? 0.8 : 1) : 0.5)
      .contentShape(Rectangle())
  }

  private var foreground: Color {
    switch variant {
    case .primary: Palette.onPrimary
    case .outline: Palette.primary
    case .danger: Palette.onDanger
    case .brass: Palette.brass
    }
  }

  private var background: Color {
    switch variant {
    case .primary: Palette.primary
    case .danger: Palette.danger
    case .outline, .brass: .clear
    }
  }

  private var stroke: Color {
    switch variant {
    case .outline: Palette.border
    case .brass: Palette.brass
    case .primary, .danger: .clear
    }
  }
}

extension ButtonStyle where Self == BrandButtonStyle {
  static func brand(
    _ variant: BrandButtonStyle.Variant = .primary,
    compact: Bool = false,
    fullWidth: Bool = false
  ) -> BrandButtonStyle {
    BrandButtonStyle(variant: variant, compact: compact, fullWidth: fullWidth)
  }
}

extension View {
  /// Bordered surface used for cards.
  func brandCard(padding: CGFloat = 16) -> some View {
    self
      .padding(padding)
      .frame(maxWidth: .infinity, alignment: .leading)
      .background(Palette.surface)
      .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
      .overlay(
        RoundedRectangle(cornerRadius: 14, style: .continuous)
          .stroke(Palette.border, lineWidth: 1)
      )
  }

  /// A native Form or List in the app's colours.
  func brandList() -> some View {
    self
      .scrollContentBackground(.hidden)
      .background(Palette.background)
      .font(AppFont.body())
      .foregroundStyle(Palette.text)
  }

  func brandRow() -> some View {
    listRowBackground(Palette.surface)
  }

  /// Adds a Done button above the keyboard; the phone keypad has no return key.
  func keyboardDoneButton() -> some View {
    toolbar {
      ToolbarItemGroup(placement: .keyboard) {
        Spacer()
        Button("Done") {
          UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
          )
        }
      }
    }
  }
}
