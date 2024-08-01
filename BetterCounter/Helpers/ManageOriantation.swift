import SwiftUI
import Combine

enum Orientation {
    case portrait
    case landscape
    case landscapeLeftWithCameraUp
}

class OrientationManager: ObservableObject {
    @Published var orientation: Orientation = .portrait
    private var cancellable: AnyCancellable?

    init() {
        // Observe device orientation changes
        cancellable = NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .sink { _ in
                self.updateOrientation()
            }
        // Initial orientation setup
        updateOrientation()
    }

    private func updateOrientation() {
        let currentOrientation = UIDevice.current.orientation
        
        if currentOrientation == .landscapeLeft && currentOrientation.isFlat == false {
            orientation = .landscapeLeftWithCameraUp
        } else if currentOrientation.isLandscape {
            orientation = .landscape
        } else if currentOrientation.isPortrait {
            orientation = .portrait
        }
    }
}
