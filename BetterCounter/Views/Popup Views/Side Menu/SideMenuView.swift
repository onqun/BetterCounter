//
//  SideMenuView.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 9.11.2024.
//

import SwiftUI

import SwiftUI

struct SideMenuView: View {
    @Binding var selectedSideMenuTab: Int
    @Binding var presentSideMenu: Bool

    var body: some View {
        VStack(alignment: .leading) {
            ForEach(SideMenuRowType.allCases, id: \.self) { row in
                Button(action: {
                    selectedSideMenuTab = row.rawValue
                    presentSideMenu.toggle()
                }) {
                    HStack {
                        Image(systemName: row.iconName)  // Replace with your image
                        Text(row.title)
                            .foregroundColor(.black)
                    }
                    .padding()
                }
            }
            Spacer()
        }
        .frame(maxWidth: 270)  // Adjust width as needed
        .background(Color.white)
    }
}
    
    
    
func RowView(isSelected: Bool, imageName: String, title: String, hideDivider: Bool = false, action: @escaping (()->())) -> some View{
    Button{
        action()
    } label: {
        VStack(alignment: .leading){
            HStack(spacing: 20){
                Rectangle()
                    .fill(isSelected ? .purple : .white)
                    .frame(width: 5)
                    
                ZStack{
                    Image(imageName)
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(isSelected ? .black : .gray)
                        .frame(width: 26, height: 26)
                }
                .frame(width: 30, height: 30)
                Text(title)
                    .font(.system(size: 14, weight: .regular))
                    .foregroundColor(isSelected ? .black : .gray)
                Spacer()
            }
        }
    }
    .frame(height: 50)
    .background(
        LinearGradient(
            colors: [isSelected ? .purple.opacity(0.5) : .white, .white],
            startPoint: .leading,
            endPoint: .trailing
        )
    )
}

#Preview {
    RowView(
        isSelected: false,
        imageName: "star", // Example image name, make sure to use an available SF Symbol
        title: "Sample Title",
        action: {
            // Example action: print to the console
            print("RowView tapped")
        }
    )
}
