import SwiftUI

struct MotivationsView: View {
    let quotes = [
        "Believe in yourself and all that you are.",
        "The only way to do great work is to love what you do.",
        "Success is not final, failure is not fatal: it is the courage to continue that counts.",
        "Don't watch the clock; do what it does. Keep going.",
        "Your limitation—it’s only your imagination.",
        "Push yourself, because no one else is going to do it for you.",
        "Great things never come from comfort zones."
    ]
    
    @State private var currentQuote = "Click the button for a boost!"

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.12, blue: 0.2).ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "quote.opening")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                
                Text(currentQuote)
                    .font(.title3)
                    .italic()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)
                    .foregroundColor(.white)
                    .animation(.easeInOut, value: currentQuote)  
                
                Button(action: {
                    currentQuote = quotes.randomElement() ?? "Keep going!"
                }) {
                    Text("New Motivation ✨")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Capsule().fill(Color.blue.opacity(0.4)))
                }
            }
        }
    }
}
