import SwiftUI
import GoogleGenerativeAI

struct Message: Identifiable {
    let id = UUID()
    let text: String
    let isUserMessage: Bool
    
    init(text: String, isUserMessage: Bool) {
        self.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        self.isUserMessage = isUserMessage
    }
}

struct ChatView: View {
    var existingConversationId: String? = nil
    var existingMessages: [ChatMessage]? = nil
    var showNavigation: Bool = true
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var historyViewModel = ChatHistoryViewModel()
    @State private var currentConversationId: String?
    let model = GenerativeModel(name: "gemini-1.5-flash", apiKey: APIKey.default)
    private let systemMessage = "Jesteś pomocnikiem w aplikacji z poradami prawnymi. Gdy moje zapytanie będzie dotyczyło czegoś innego niż porada prawna, odpowiedz 'Nie jestem w stanie ci z tym pomóc - jestem tylko pomocnikiem prawnym. Czy jest coś innego, w czym mogę ci pomóc?'. Jeśli moje zapytanie będzie dotyczyło porady prawnej, podeprzyj swoją odpowiedź linkami do źródeł, takich jak fora prawne, kodeksy prawne itp i zakończ wiadomość tekstem 'Pamiętaj, że powyższe informacje mają charakter jedynie informacyjny i nie stanowią porady prawnej. W razie potrzeby skonsultuj się z prawnikiem'. Nie używaj formatowania tekstu, takiego jak pogrubienia itp. Przy formatowaniu list, używaj '-' zamiast '*', jako oznaczenie elementu listy."
    @State var aiResponse = ""
    @State private var messages: [Message] = [
        Message(text: "W czym mogę Ci pomóc?", isUserMessage: false)
    ]
    @State private var userInput: String = ""
    @State private var isLoading = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if showNavigation {
                NavigationView {
                    chatContent
                }
            } else {
                chatContent
            }
        }
    }
    
    private var chatContent: some View {
        ZStack {
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
                        .disabled(isLoading)

                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "paperplane.fill")
                            .foregroundColor(isLoading ? .gray : .blue)
                            .padding()
                    }
                    .disabled(isLoading)
                }
                .padding()
            }
            
            if isLoading {
                VStack {
                    Spacer()
                    HStack {
                        ProgressView()
                            .padding()
                        Text("AI pisze...")
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .background(Color.white.opacity(0.9))
                    .padding(.bottom, 60)
                }
            }
        }
        .navigationTitle("Pomoc AI")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: showNavigation ? Button("Zamknij") {
            dismiss()
        } : nil)
        .onAppear {
            if let existingConversationId = existingConversationId {
                currentConversationId = existingConversationId
                historyViewModel.setCurrentConversationId(existingConversationId)
                
                if let existingMessages = existingMessages {
                    self.messages = existingMessages.map { chatMessage in
                        Message(text: chatMessage.text, isUserMessage: chatMessage.isUserMessage)
                    }
                }
            } else {
                currentConversationId = historyViewModel.startNewConversation()
                messages = [Message(text: "W czym mogę Ci pomóc?", isUserMessage: false)]
            }
        }
    }
    
    func sendMessage() {
        guard !userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = Message(text: userInput, isUserMessage: true)
        messages.append(userMessage)
        historyViewModel.saveMessage(userMessage, userEmail: authViewModel.email)
        
        let currentUserInput = userInput
        userInput = ""
        isLoading = true
        fetchAIResponseWithHistory(currentUserInput)
    }
    
    func fetchAIResponseWithHistory(_ currentUserInput: String) {
        Task {
            do {
                var conversationLines = [systemMessage]
                
                if !messages.dropLast().isEmpty {
                    conversationLines.append("\nPrevious conversation:")
                    for message in messages.dropLast() {
                        let prefix = message.isUserMessage ? "User: " : "Assistant: "
                        conversationLines.append("\(prefix)\(message.text)")
                    }
                }
                
                conversationLines.append("\nUser: \(currentUserInput)")
                conversationLines.append("\nAssistant:")
                
                let conversationContext = conversationLines.joined(separator: "\n")
                
                let response = try await model.generateContent(conversationContext)
                
                guard let text = response.text else {
                    await handleAIResponse("Sorry, I could not process that. Please try again.")
                    return
                }
                
                await handleAIResponse(text)
                
            } catch {
                await handleAIResponse("Something went wrong!\n\(error.localizedDescription)")
            }
        }
    }
    
    @MainActor
    private func handleAIResponse(_ text: String) {
        let aiMessage = Message(text: text, isUserMessage: false)
        messages.append(aiMessage)
        historyViewModel.saveMessage(aiMessage, userEmail: authViewModel.email)
        isLoading = false
    }
}

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
