import SwiftUI
import SwiftData

struct FlashcardView: View {
    let word: Word
    @State private var isFlipped = false
    var onRate: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                // Front Side
                CardSideView(title: "English", content: word.english, backgroundColor: .blue.opacity(0.1))
                    .opacity(isFlipped ? 0 : 1)
                    .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
                
                // Back Side
                CardSideView(title: "Japanese", content: word.japanese, subContent: word.context, backgroundColor: .green.opacity(0.1))
                    .opacity(isFlipped ? 1 : 0)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : -180), axis: (x: 0, y: 1, z: 0))
            }
            .onTapGesture {
                withAnimation(.spring()) {
                    isFlipped.toggle()
                }
            }
            .frame(height: 300)
            
            if isFlipped {
                VStack(spacing: 15) {
                    Text("How was it?")
                        .font(.headline)
                    
                    HStack(spacing: 10) {
                        RateButton(label: "Again", color: .red, quality: 0, action: onRate)
                        RateButton(label: "Hard", color: .orange, quality: 3, action: onRate)
                        RateButton(label: "Good", color: .blue, quality: 4, action: onRate)
                        RateButton(label: "Easy", color: .green, quality: 5, action: onRate)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            } else {
                Text("Tap to flip")
                    .foregroundColor(.secondary)
                    .font(.subheadline)
            }
        }
        .padding()
    }
}

struct CardSideView: View {
    let title: String
    let content: String
    var subContent: String = ""
    let backgroundColor: Color
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(content)
                .font(.system(size: 32, weight: .bold, design: .serif))
                .multilineTextAlignment(.center)
            if !subContent.isEmpty {
                Text(subContent)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
        .cornerRadius(20)
        .shadow(radius: 5)
    }
}

struct RateButton: View {
    let label: String
    let color: Color
    let quality: Int
    let action: (Int) -> Void
    
    var body: some View {
        Button(action: { action(quality) }) {
            Text(label)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(color)
                .cornerRadius(10)
        }
    }
}

#Preview {
    FlashcardView(word: Word(english: "Algorithm", japanese: "アルゴリズム", context: "A set of rules for solving a problem.")) { quality in
        print("Rated with quality: \(quality)")
    }
    .modelContainer(PreviewContainer.container)
}
