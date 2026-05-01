import SwiftUI
import SwiftData

struct EditWordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    // 元のデータ（保存時まで更新しない）
    let word: Word
    
    // 編集用の一時状態
    @State private var english: String = ""
    @State private var japanese: String = ""
    @State private var context: String = ""
    
    var body: some View {
        Form {
            Section(header: Text("Word Details")) {
                TextField("English Term", text: $english)
                TextField("Japanese Meaning", text: $japanese)
            }
            
            Section(header: Text("Context / Example")) {
                TextEditor(text: $context)
                    .frame(height: 100)
            }
            
            Section(header: Text("Study Progress")) {
                HStack {
                    Text("Repetitions")
                    Spacer()
                    Text("\(word.repetitionCount)")
                        .foregroundColor(.secondary)
                }
                HStack {
                    Text("Next Review")
                    Spacer()
                    Text(word.nextReviewDate, style: .date)
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Edit Word")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // 画面表示時に現在の値をセット
            english = word.english
            japanese = word.japanese
            context = word.context
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Save") {
                    // 保存ボタンが押された時だけ元のデータを更新
                    word.english = english
                    word.japanese = japanese
                    word.context = context
                    
                    try? modelContext.save()
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(english.isEmpty || japanese.isEmpty ? .gray : .blue)
                .disabled(english.isEmpty || japanese.isEmpty)
            }
        }
    }
}

#Preview {
    NavigationView {
        EditWordView(word: Word(english: "Algorithm", japanese: "アルゴリズム", context: "Sample context"))
            .modelContainer(PreviewContainer.container)
    }
}
