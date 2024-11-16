import SwiftUI

struct MainTabbedView: View {
    @State private var presentSideMenu = false
    @State var selectedSideMenuTab = 0

    var body: some View {
        ZStack {
            TabView(selection: $selectedSideMenuTab) {
                ListView(presentSideMenu: $presentSideMenu) // Correctly pass as Binding
                    .tag(0)
                // Additional views can go here
            }

            // SideMenu appears when presentSideMenu is true
            if presentSideMenu {
                SideMenuView(
                    selectedSideMenuTab: $selectedSideMenuTab,
                    presentSideMenu: $presentSideMenu
                )
                    .transition(.move(edge: .leading))
            }
        }
    }
}
