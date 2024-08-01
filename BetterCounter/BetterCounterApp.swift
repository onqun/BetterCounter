import SwiftUI
import SwiftData

@main
struct BetterCounterApp: App {
    let container: ModelContainer

    init() {
        let schema = Schema([CountedItem.self, ItemGroups.self])  // Ensure schema consistency
        let config = ModelConfiguration("ItemList.betterCounter", schema: schema)
        
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not display the container: \(error)")
        }
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)  // Injecting the persistent ModelContainer
        }
    }
}
