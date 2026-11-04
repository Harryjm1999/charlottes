import SwiftUI
import UIKit

/// Full-screen menus: swipe between them, pinch or double-tap to zoom.
struct MenuViewer: View {
  let menus: [Restaurant.Menu]

  @Environment(\.dismiss) private var dismiss
  @State private var selection: Int

  init(menus: [Restaurant.Menu], start: Int) {
    self.menus = menus
    _selection = State(initialValue: start)
  }

  var body: some View {
    NavigationStack {
      TabView(selection: $selection) {
        ForEach(Array(menus.enumerated()), id: \.element.id) { index, menu in
          ZoomableImage(file: menu.file)
            .ignoresSafeArea(edges: .bottom)
            .accessibilityLabel("\(menu.label) menu")
            .tag(index)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .always))
      .background(Palette.deep)
      .navigationTitle(menus.indices.contains(selection) ? menus[selection].label : "Menu")
      .navigationBarTitleDisplayMode(.inline)
      .toolbarBackground(Palette.deep, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .toolbar {
        ToolbarItem(placement: .confirmationAction) {
          Button("Done") { dismiss() }
            .tint(Palette.brass)
        }
      }
    }
  }
}

private struct ZoomableImage: UIViewRepresentable {
  let file: String

  func makeUIView(context: Context) -> ZoomingImageView {
    ZoomingImageView(image: UIImage(named: file))
  }

  func updateUIView(_ uiView: ZoomingImageView, context: Context) {}
}

final class ZoomingImageView: UIScrollView, UIScrollViewDelegate {
  private let imageView = UIImageView()

  init(image: UIImage?) {
    super.init(frame: .zero)
    delegate = self
    minimumZoomScale = 1
    maximumZoomScale = 4
    showsHorizontalScrollIndicator = false
    showsVerticalScrollIndicator = false
    contentInsetAdjustmentBehavior = .never
    imageView.image = image
    imageView.contentMode = .scaleAspectFit
    addSubview(imageView)

    let doubleTap = UITapGestureRecognizer(target: self, action: #selector(toggleZoom(_:)))
    doubleTap.numberOfTapsRequired = 2
    addGestureRecognizer(doubleTap)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) is not used")
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    if zoomScale == 1 {
      imageView.frame = bounds
      contentSize = bounds.size
    }
  }

  func viewForZooming(in scrollView: UIScrollView) -> UIView? { imageView }

  @objc private func toggleZoom(_ gesture: UITapGestureRecognizer) {
    if zoomScale > 1 {
      setZoomScale(1, animated: true)
    } else {
      let point = gesture.location(in: imageView)
      let size = CGSize(width: bounds.width / 2.5, height: bounds.height / 2.5)
      zoom(
        to: CGRect(x: point.x - size.width / 2, y: point.y - size.height / 2, width: size.width, height: size.height),
        animated: true
      )
    }
  }
}
