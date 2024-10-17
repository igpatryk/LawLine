import SwiftUI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUserMessage: Bool
}

struct ChatView: View {
    @State private var messages: [Message] = [
        Message(text: "W czym mogę Ci pomóc?", isUserMessage: false)
    ]
    @State private var userInput: String = ""
    
    var body: some View {
        VStack {
            ScrollView {
                ScrollViewReader { scrollView in
                    VStack(spacing: 10) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                    .onChange(of: messages.count) {
                        scrollView.scrollTo(messages.last?.id, anchor: .bottom)
                    }
                }
            }

            HStack {
                TextField("Napisz wiadomość...", text: $userInput)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(minHeight: 30)

                Button(action: {
                    sendMessage()
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .padding()
        }
        .navigationTitle("Pomoc AI")
    }
    
    func sendMessage() {
        // Dodanie wiadomości użytkownika
        let userMessage = Message(text: userInput, isUserMessage: true)
        messages.append(userMessage)
        
        // Wyczyszczenie pola tekstowego
        userInput = ""

        // Wywołanie API i dodanie odpowiedzi
        fetchAIResponse(for: userMessage.text) { response in
            DispatchQueue.main.async {
                let aiMessage = Message(text: response, isUserMessage: false)
                messages.append(aiMessage)
            }
        }
    }
    
    // Funkcja do integracji z API Gemini
    func fetchAIResponse(for userMessage: String, completion: @escaping (String) -> Void) {
        // Tutaj musisz wywołać swoje API i przekazać odpowiedź do completion
        // Zamiast przykładowej odpowiedzi poniżej wywołaj swoje API Gemini
        let sampleResponse = "To jest przykładowa odpowiedź od AI."
        completion(sampleResponse)
    }
}

// Widok dymku wiadomości
struct MessageBubble: View {
    var message: Message

    var body: some View {
        HStack {
            if message.isUserMessage {
                Spacer()
                Text(message.text)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(15)
                    .frame(maxWidth: 300, alignment: .trailing)
            } else {
                Text(message.text)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(15)
                    .frame(maxWidth: 300, alignment: .leading)
                Spacer()
            }
        }
    }
}

