//
//  SideMenuforSettings.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 9.11.2024.
//

import SwiftUI

struct SideMenu<Content: View>: View {
    @Binding var isShowing: Bool
    var edgeTransition: AnyTransition = .move(edge: .leading)
    @ViewBuilder var content: () -> Content

    var body: some View {
        ZStack {
            if isShowing {
                // Dim background when the side menu is showing
                Color.black
                    .opacity(0.3)
                    .ignoresSafeArea()
                    .onTapGesture {
                        isShowing.toggle()
                    }

                // Side menu content
                content()
                    .frame(maxWidth: 270)  // Adjust the width as needed
                    .transition(edgeTransition)
            }
        }
        .animation(.easeInOut, value: isShowing)
    }
}
