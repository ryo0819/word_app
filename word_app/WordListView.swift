import SwiftUI
import SwiftData

struct WordListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Word.english) private var words: [Word]
    @State private var searchText = ""
    
    var filteredWords: [Word] {
        if searchText.isEmpty {
            return words
        } else {
            return words.filter { 
                $0.english.localizedCaseInsensitiveContains(searchText) || 
                $0.japanese.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        List {
            ForEach(filteredWords) { word in
                NavigationLink(destination: EditWordView(word: word)) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(word.english)
                                .font(.headline)
                            Spacer()
                            if word.repetitionCount > 0 {
                                Text("Next: \(word.nextReviewDate, style: .date)")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            } else {
                                Text("New")
                                    .font(.caption2)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.blue.opacity(0.1))
                                    .foregroundColor(.blue)
                                    .cornerRadius(4)
                            }
                        }
                        Text(word.japanese)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .onDelete(perform: deleteWords)
        }
        .navigationTitle("Word List")
        .searchable(text: $searchText, prompt: "Search words")
    }
    
    private func deleteWords(offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(filteredWords[index])
        }
        try? modelContext.save()
    }
}

#Preview {
    NavigationView {
        WordListView()
            .modelContainer(PreviewContainer.container)
    }
}
