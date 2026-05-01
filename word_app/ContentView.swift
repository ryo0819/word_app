import SwiftUI
import SwiftData

// 学習セッションの状態を管理するための構造体
struct StudySession: Identifiable {
    let id = UUID()
    let words: [Word]
    let isExtraReview: Bool
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var words: [Word]
    
    @State private var activeSession: StudySession? = nil
    @State private var showingAddWordView = false
    
    var reviewCount: Int {
        let now = Date()
        return words.filter { $0.nextReviewDate <= now }.count
    }
    
    var learnedWords: [Word] {
        words.filter { $0.repetitionCount > 0 }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 25) {
                // Stats Header
                VStack(spacing: 10) {
                    Text("\(reviewCount)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(reviewCount > 0 ? .orange : .green)
                    Text("Words to Review")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 20)
                
                VStack(spacing: 12) {
                    // 1. Scheduled Review
                    Button(action: {
                        let now = Date()
                        let sessionWords = words.filter { $0.nextReviewDate <= now }
                            .sorted { $0.nextReviewDate < $1.nextReviewDate }
                        activeSession = StudySession(words: sessionWords, isExtraReview: false)
                    }) {
                        Label("Scheduled Review", systemImage: "calendar")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(reviewCount > 0 ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(reviewCount == 0)
                    
                    // 2. Study All Words
                    Button(action: {
                        let sessionWords = Array(words.shuffled().prefix(20))
                        activeSession = StudySession(words: sessionWords, isExtraReview: true)
                    }) {
                        Label("Study All Words", systemImage: "books.vertical.fill")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(words.isEmpty ? Color.gray : Color.purple)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(words.isEmpty)
                    
                    // 3. Review Learned Only
                    Button(action: {
                        let sessionWords = Array(learnedWords.shuffled().prefix(20))
                        activeSession = StudySession(words: sessionWords, isExtraReview: true)
                    }) {
                        Label("Review Learned Only", systemImage: "checkmark.seal.fill")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(learnedWords.isEmpty ? Color.gray : Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(15)
                    }
                    .disabled(learnedWords.isEmpty)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // Statistics Cards
                HStack(spacing: 20) {
                    NavigationLink(destination: WordListView()) {
                        StatCard(title: "Total Words", value: "\(words.count)", icon: "books.vertical.fill")
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    StatCard(title: "Learned", value: "\(learnedWords.count)", icon: "checkmark.seal.fill")
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("IT Vocabulary")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingAddWordView = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
            // item: を使うことで、データがセットされた瞬間にそのデータを持って画面を作る
            .sheet(item: $activeSession) { session in
                StudyView(sessionWords: session.words, isExtraReview: session.isExtraReview)
            }
            .sheet(isPresented: $showingAddWordView) {
                AddWordView()
            }
            .onAppear {
                DataLoader.loadInitialData(modelContext: modelContext)
            }
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
        .modelContainer(PreviewContainer.container)
}
