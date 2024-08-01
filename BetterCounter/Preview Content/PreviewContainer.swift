
import Foundation
import SwiftData

struct Preview {
    let container: ModelContainer
    
    init() {
        let schema = Schema([CountedItem.self, ItemGroups.self])  // Ensure schema consistency
        let config = ModelConfiguration(isStoredInMemoryOnly: true)  // In-memory configuration
        
        do {
            container = try ModelContainer(for: schema, configurations: config)
        } catch {
            fatalError("Could not create container: \(error)")
        }
    }
    
    func addExamples(_ examples: [Any]) {
        Task { @MainActor in
            for example in examples {
                if let item = example as? CountedItem {
                    container.mainContext.insert(item)
                } else if let group = example as? ItemGroups {
                    container.mainContext.insert(group)
                }
            }
            
            // Save context after adding examples
            do {
                try container.mainContext.save()
            } catch {
                print("Error saving context with examples: \(error)")
            }
        }
    }
}
