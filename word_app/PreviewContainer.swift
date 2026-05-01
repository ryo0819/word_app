import Foundation
import SwiftData

@MainActor
enum PreviewContainer {
    static let container: ModelContainer = {
        do {
            let schema = Schema([Word.self])
            let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: schema, configurations: [configuration])
            
            let sampleWords = [
                Word(english: "Algorithm", japanese: "アルゴリズム", context: "A process or set of rules to be followed in calculations."),
                Word(english: "Database", japanese: "データベース", context: "A structured set of data held in a computer."),
                Word(english: "Encryption", japanese: "暗号化", context: "The process of converting information or data into a code.")
            ]
            
            // 1つは復習が必要な状態に設定
            sampleWords[0].nextReviewDate = Date().addingTimeInterval(-3600)
            
            for word in sampleWords {
                container.mainContext.insert(word)
            }
            
            return container
        } catch {
            fatalError("Failed to create preview container: \(error.localizedDescription)")
        }
    }()
}
