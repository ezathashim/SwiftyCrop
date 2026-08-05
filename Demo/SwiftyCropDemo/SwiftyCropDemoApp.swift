import SwiftUI
import SwiftyCrop

/// Shared state passed between the main window and the macOS crop window.
class CropSession: ObservableObject {
  @Published var image: PlatformImage?
  var maskShape: MaskShape = .square
  var configuration: SwiftyCropConfiguration = SwiftyCropConfiguration()
  var onComplete: ((PlatformImage?) -> Void)?
  var onCancel: (() -> Void)?
}

@main
struct SwiftyCropDemoApp: App {
  @StateObject private var cropSession = CropSession()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(cropSession)
    }
    #if os(macOS)
    .defaultSize(width: 700, height: 800)
    #endif

    #if os(macOS)
    Window("Crop Image", id: "crop-image") {
      CropWindowView()
        .environmentObject(cropSession)
    }
    .windowStyle(.hiddenTitleBar)
    .defaultSize(width: 620, height: 620)
    #endif
  }
}

#if os(macOS)
struct CropWindowView: View {
  @EnvironmentObject private var session: CropSession
  @Environment(\.dismiss) private var dismiss

  var body: some View {
    if let image = session.image {
      SwiftyCropView(
        imageToCrop: image,
        maskShape: session.maskShape,
        configuration: session.configuration,
        onCancel: {
          session.onCancel?()
          closeWindowIfNeeded()
        }
      ) { croppedImage in
        session.onComplete?(croppedImage)
        closeWindowIfNeeded()
      }
    }
  }

  /// With `dismissesOnCompletion` disabled, the crop window is closed by the demo app instead of by SwiftyCrop.
  private func closeWindowIfNeeded() {
    guard !session.configuration.dismissesOnCompletion else { return }
    dismiss()
  }
}
#endif
