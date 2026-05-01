import SwiftUI
import SwiftData

struct AddWordView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var english = ""
    @State private var japanese = ""
    @State private var context = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Word Details")) {
                    TextField("English Term", text: $english)
                    TextField("Japanese Meaning", text: $japanese)
                }
                
                Section(header: Text("Context / Example")) {
                    TextEditor(text: $context)
                        .frame(height: 100)
                }
            }
            .navigationTitle("Add New Word")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newWord = Word(english: english, japanese: japanese, context: context)
                        modelContext.insert(newWord)
                        dismiss()
                    }
                    .disabled(english.isEmpty || japanese.isEmpty)
                }
            }
        }
    }
}

#Preview {
    AddWordView()
        .modelContainer(PreviewContainer.container)
}
