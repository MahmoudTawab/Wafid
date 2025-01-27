import SwiftUI

struct FacebookStyleEditor: View {
    @State private var text: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Description")
                .font(.system(size: 20, weight: .regular))
                .padding(.horizontal)
                .padding(.top)
            
            TextEditor(text: $text)
                .frame(height: 200)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
                )
                .padding()
                .overlay(
                    Text(text.isEmpty ? "We are the teams who create all of Facebook's products used by billions of people around the world. Want to build new features and improve existing products like Messenger, Video, Groups, News Feed, Search and more?" : "")
                        .foregroundColor(.gray)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 25)
                        .allowsHitTesting(false),
                    alignment: .topLeading
                )
        }
        .background(Color(.systemGray6))
    }
}

#Preview {
    FacebookStyleEditor()
}