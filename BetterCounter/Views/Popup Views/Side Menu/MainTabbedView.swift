//
//  MainTabbedView.swift
//  BetterCounter
//
//  Created by Ongun Palaoğlu on 9.11.2024.
//


import SwiftUI

struct MainTabbedView: View {
    
    @State var presentSideMenu = false
    @State var selectedSideMenuTab = 0
    
    var body: some View {
        ZStack{
            
            TabView(selection: $selectedSideMenuTab) {
                HomeView(presentSideMenu: $presentSideMenu)
                    .tag(0)
//                FavoriteView(presentSideMenu: $presentSideMenu)
//                    .tag(1)
//                ChatView(presentSideMenu: $presentSideMenu)
//                    .tag(2)
//                ProfileView(presentSideMenu: $presentSideMenu)
//                    .tag(3)
            }
            
            SideMenu(isShowing: $presentSideMenu, content: AnyView(SideMenuView(selectedSideMenuTab: $selectedSideMenuTab, presentSideMenu: $presentSideMenu)))
        }
    }
}
