import SwiftUI
import SwiftData

struct StudyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allWords: [Word]
    
    let sessionWords: [Word]
    let isExtraReview: Bool
    
    @State private var currentIndex = 0
    @State private var quizOptions: [String] = []
    @State private var selectedOption: String? = nil
    @State private var showResult = false
    
    var body: some View {
        NavigationView {
            VStack {
                if sessionWords.isEmpty {
                    emptyState
                } else if currentIndex < sessionWords.count {
                    studyContent(word: sessionWords[currentIndex])
                } else {
                    completionState
                }
            }
            .navigationTitle(isExtraReview ? "Extra Review" : "Daily Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                prepareNextQuestion()
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill").font(.system(size: 80)).foregroundColor(.green)
            Text("All caught up!").font(.title2).fontWeight(.bold)
            Button("Finish") { dismiss() }.buttonStyle(.borderedProminent).padding(.top)
        }
    }
    
    private func studyContent(word: Word) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Progress and Counter
                VStack(spacing: 8) {
                    ProgressView(value: Double(currentIndex), total: Double(sessionWords.count))
                    Text("\(currentIndex + 1) / \(sessionWords.count)")
                        .font(.caption2).foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                // Question Card
                VStack(spacing: 10) {
                    Text(word.english)
                        .font(.system(size: 36, weight: .bold, design: .serif))
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    
                    if showResult {
                        Text(word.japanese)
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                            .transition(.opacity)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(15)
                .padding(.horizontal)
                
                // 4-Choice Quiz (Meaning / Context)
                VStack(spacing: 12) {
                    ForEach(quizOptions, id: \.self) { option in
                        Button(action: { 
                            withAnimation(.spring()) {
                                handleOptionSelection(option, correctAnswer: word.context)
                            }
                        }) {
                            HStack {
                                Text(option)
                                    .font(.subheadline)
                                    .multilineTextAlignment(.leading)
                                    .fixedSize(horizontal: false, vertical: true)
                                Spacer()
                                if selectedOption == option {
                                    Image(systemName: option == word.context ? "checkmark.circle.fill" : "xmark.circle.fill")
                                } else if showResult && option == word.context {
                                    Image(systemName: "checkmark.circle.fill")
                                }
                            }
                            .padding()
                            .frame(maxWidth: .infinity, minHeight: 60)
                            .background(buttonColor(for: option, correctAnswer: word.context))
                            .foregroundColor(buttonTextColor(for: option, correctAnswer: word.context))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(selectedOption == option ? Color.clear : Color.blue.opacity(0.1), lineWidth: 1)
                            )
                        }
                        .disabled(selectedOption != nil)
                    }
                }
                .padding(.horizontal)
                
                // Self Evaluation (Only appears after selection)
                if selectedOption != nil {
                    VStack(spacing: 15) {
                        Divider().padding(.vertical, 5)
                        
                        Text("Rate your memory of this word:")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 10) {
                            EvaluationButton(label: "Forgot", color: .red, quality: 0) { applyEvaluation($0) }
                            EvaluationButton(label: "Hard", color: .orange, quality: 3) { applyEvaluation($0) }
                            EvaluationButton(label: "Good", color: .blue, quality: 4) { applyEvaluation($0) }
                            EvaluationButton(label: "Easy", color: .green, quality: 5) { applyEvaluation($0) }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                    .padding(.horizontal)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                
                Spacer(minLength: 30)
            }
        }
    }
    
    private var completionState: some View {
        VStack(spacing: 20) {
            Image(systemName: "party.popper.fill").font(.system(size: 60)).foregroundColor(.orange)
            Text("Session Complete!").font(.title)
            Text("\(sessionWords.count) words reviewed.").foregroundColor(.secondary)
            Button("Done") { dismiss() }.buttonStyle(.borderedProminent)
        }
    }
    
    // --- Logic ---
    
    private func prepareNextQuestion() {
        guard currentIndex < sessionWords.count else { return }
        let currentWord = sessionWords[currentIndex]
        
        var options = [currentWord.context]
        let otherWords = allWords.filter { $0.id != currentWord.id && !$0.context.isEmpty }.map { $0.context }
        options.append(contentsOf: Array(otherWords.shuffled().prefix(3)))
        
        while options.count < 4 {
            options.append("Alternative description \(options.count + 1)")
        }
        
        quizOptions = options.shuffled()
        selectedOption = nil
        showResult = false
    }
    
    private func handleOptionSelection(_ option: String, correctAnswer: String) {
        selectedOption = option
        showResult = true
    }
    
    private func applyEvaluation(_ quality: Int) {
        let word = sessionWords[currentIndex]
        word.updateReviewSchedule(quality: quality)
        try? modelContext.save()
        
        withAnimation {
            currentIndex += 1
            prepareNextQuestion()
        }
    }
    
    private func buttonColor(for option: String, correctAnswer: String) -> Color {
        guard let selected = selectedOption else { return Color.secondary.opacity(0.05) }
        if option == correctAnswer { return .green.opacity(0.8) }
        if option == selected { return .red.opacity(0.8) }
        return Color.secondary.opacity(0.05)
    }
    
    private func buttonTextColor(for option: String, correctAnswer: String) -> Color {
        guard let selected = selectedOption else { return .primary }
        if option == correctAnswer || option == selected { return .white }
        return .primary.opacity(0.3)
    }
}

struct EvaluationButton: View {
    let label: String
    let color: Color
    let quality: Int
    let action: (Int) -> Void
    
    var body: some View {
        Button(action: { action(quality) }) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
    }
}

#Preview {
    StudyView(sessionWords: [
        Word(english: "Algorithm", japanese: "アルゴリズム", context: "A process or set of rules to be followed in calculations.")
    ], isExtraReview: false)
    .modelContainer(PreviewContainer.container)
}
