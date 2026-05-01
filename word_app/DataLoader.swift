import Foundation
import SwiftData

@MainActor
class DataLoader {
    static func loadInitialData(modelContext: ModelContext) {
        // Clear existing data to switch from medical to IT terms
        try? modelContext.delete(model: Word.self)
        
        guard let url = Bundle.main.url(forResource: "initial_words", withExtension: "csv"),
              let content = try? String(contentsOf: url) else {
            print("CSV file not found or could not be read.")
            return
        }
        
        let lines = content.components(separatedBy: .newlines)
        // Skip header
        for line in lines.dropFirst() {
            let columns = line.components(separatedBy: ",")
            if columns.count >= 2 {
                let english = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let japanese = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let context = columns.count > 2 ? columns[2].trimmingCharacters(in: .whitespacesAndNewlines) : ""
                
                if !english.isEmpty && !japanese.isEmpty {
                    let word = Word(english: english, japanese: japanese, context: context)
                    modelContext.insert(word)
                }
            }
        }
        
        try? modelContext.save()
    }
}
