import SwiftUI

struct PopupView<Content: View>: View {
    
    @Binding var isShowing: Bool
    
    let width: CGFloat
    let height: CGFloat
    let backgroundColor: Color
    let cornerRadius: CGFloat
    let content: Content

    init(
        isShowing: Binding<Bool>,
        width: CGFloat,
        height: CGFloat,
        backgroundColor: Color = Color.white,
        cornerRadius: CGFloat = 12,
        @ViewBuilder content: () -> Content
    ) {
        self._isShowing = isShowing
        self.width = width
        self.height = height
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.content = content()
    }

    var body: some View {
        if isShowing {
            VStack {
                content
                    .padding()
                    .frame(width: width, height: height)
                    .background(backgroundColor)
                    .cornerRadius(cornerRadius)
                    .shadow(radius: 10)
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            }
            .transition(.scale)
        }
    }
}


