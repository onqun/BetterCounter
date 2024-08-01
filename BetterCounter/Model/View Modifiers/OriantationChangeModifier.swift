import SwiftUI

struct OrientationChangeModifier: ViewModifier {
    @Binding var isLandscape: Bool

    func body(content: Content) -> some View {
        content
            .onAppear(perform: detectOrientation)
            .onRotate(perform: handleRotation)
    }

    private func detectOrientation() {
        let currentOrientation = UIDevice.current.orientation
        isLandscape = currentOrientation.isLandscape
    }

    private func handleRotation(_ newOrientation: UIDeviceOrientation) {
        isLandscape = newOrientation.isLandscape
    }
}

extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }

    func detectOrientation(isLandscape: Binding<Bool>) -> some View {
        self.modifier(OrientationChangeModifier(isLandscape: isLandscape))
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}
