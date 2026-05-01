import Foundation
import SwiftData

@Model
final class Word {
    @Attribute(.unique) var id: UUID
    var english: String
    var japanese: String
    @Attribute(originalName: "medicalContext") var context: String
    
    // SM-2 Algorithm fields
    var easinessFactor: Double // Default: 2.5
    var interval: Int          // Days until next review
    var repetitionCount: Int   // Number of consecutive correct answers
    var nextReviewDate: Date
    var lastReviewedAt: Date?
    var createdAt: Date

    init(english: String, japanese: String, context: String = "") {
        self.id = UUID()
        self.english = english
        self.japanese = japanese
        self.context = context
        self.easinessFactor = 2.5
        self.interval = 0
        self.repetitionCount = 0
        self.nextReviewDate = Date()
        self.createdAt = Date()
    }
    
    /// Updates the word's review schedule using the SM-2 algorithm.
    /// - Parameter quality: 0-5 response quality (0: total failure, 5: perfect response)
    func updateReviewSchedule(quality: Int) {
        let q = Double(max(0, min(5, quality)))
        
        if q >= 3 {
            // Correct response
            if repetitionCount == 0 {
                interval = 1
            } else if repetitionCount == 1 {
                interval = 6
            } else {
                interval = Int(ceil(Double(interval) * easinessFactor))
            }
            repetitionCount += 1
        } else {
            // Incorrect response
            repetitionCount = 0
            interval = 1
        }
        
        // Update easiness factor
        easinessFactor = easinessFactor + (0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02))
        if easinessFactor < 1.3 {
            easinessFactor = 1.3
        }
        
        // Update dates
        lastReviewedAt = Date()
        nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date()) ?? Date()
    }
}
