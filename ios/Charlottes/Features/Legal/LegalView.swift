import SwiftUI

enum LegalDoc: String, Hashable {
  case privacy, terms

  var title: String {
    switch self {
    case .privacy: "Privacy Policy"
    case .terms: "Terms & Conditions"
    }
  }

  var intro: String {
    switch self {
    case .privacy:
      "This policy covers the Charlotte's Restaurants & Tea Rooms app and table bookings. For the In-Excess garden centres and online shop:"
    case .terms:
      "Charlotte's Restaurants & Tea Rooms are part of In-Excess Garden Centres, so the In-Excess terms of service apply to this app."
    }
  }

  var source: (label: String, url: URL) {
    switch self {
    case .privacy:
      ("Read the In-Excess privacy policy", URL(string: "https://www.in-excess.com/policies/privacy-policy")!)
    case .terms:
      ("Read them on the In-Excess website", URL(string: "https://www.in-excess.com/policies/terms-of-service")!)
    }
  }

  fileprivate struct Block: Decodable, Identifiable {
    let kind: String
    let text: String
    var id: String { kind + text }
  }

  private struct File: Decodable {
    let privacy: [Block]
    let terms: [Block]
  }

  /// The wording lives in legal.json, generated from the website's src/data/legal.ts.
  private static let file: File? = {
    guard let url = Bundle.main.url(forResource: "legal", withExtension: "json"),
      let data = try? Data(contentsOf: url)
    else { return nil }
    return try? JSONDecoder().decode(File.self, from: data)
  }()

  fileprivate var blocks: [Block] {
    switch self {
    case .privacy: Self.file?.privacy ?? []
    case .terms: Self.file?.terms ?? []
    }
  }
}

struct LegalView: View {
  let doc: LegalDoc

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 14) {
        Text("In-Excess Garden Centres")
          .font(AppFont.medium(12))
          .textCase(.uppercase)
          .tracking(3)
          .foregroundStyle(Palette.secondary)
        DecoRule()
        Text(doc.intro)
          .font(AppFont.body(14))
          .foregroundStyle(Palette.secondary)
        Link(doc.source.label, destination: doc.source.url)
          .font(AppFont.medium(14))

        ForEach(Array(doc.blocks.enumerated()), id: \.offset) { _, block in
          switch block.kind {
          case "heading":
            Text(block.text)
              .font(AppFont.display(22))
              .foregroundStyle(Palette.primary)
              .padding(.top, 10)
              .accessibilityAddTraits(.isHeader)
          case "list":
            HStack(alignment: .firstTextBaseline, spacing: 8) {
              Text("•").foregroundStyle(Palette.brass).accessibilityHidden(true)
              Text(block.text)
            }
            .font(AppFont.body(15))
            .padding(.leading, 8)
          default:
            Text(block.text).font(AppFont.body(15))
          }
        }
      }
      .foregroundStyle(Palette.text)
      .padding(20)
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .background(Palette.background)
    .navigationTitle(doc.title)
    .navigationBarTitleDisplayMode(.inline)
  }
}
