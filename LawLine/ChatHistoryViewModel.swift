import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Conversation: Identifiable {
    let id: String
    let startTime: Date
    let userEmail: String
    var messages: [ChatMessage]
    
    var lastMessage: String {
        messages.last?.text ?? ""
    }
    
    var lastUpdateTime: Date {
        messages.last?.timestamp ?? startTime
    }
}

class ChatHistoryViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    private let db = Firestore.firestore()
    private var currentConversationId: String?
    
    func saveMessage(_ message: Message, userEmail: String) {
        guard let conversationId = currentConversationId else {
            // If no conversation is active, create a new one
            currentConversationId = startNewConversation()
            saveMessage(message, userEmail: userEmail) // Retry with new conversation
            return
        }
        
        let chatMessage = ChatMessage(
            text: message.text,
            isUserMessage: message.isUserMessage,
            timestamp: Date(),
            userEmail: userEmail
        )
        
        // Update conversation's last message time
        db.collection("conversations")
            .document(conversationId)
            .setData([
                "userEmail": userEmail,
                "lastUpdateTime": Date(),
                "startTime": FieldValue.serverTimestamp()
            ], merge: true)
        
        // Save the message
        do {
            try db.collection("conversations")
                .document(conversationId)
                .collection("messages")
                .addDocument(from: chatMessage)
        } catch {
            print("Error saving message: \(error.localizedDescription)")
        }
    }
    
    func loadConversations(for userEmail: String) {
        db.collection("conversations")
            .whereField("userEmail", isEqualTo: userEmail)
            .order(by: "lastUpdateTime", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading conversations: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                // Clear existing conversations
                self?.conversations.removeAll()
                
                // Load messages for each conversation
                for document in documents {
                    let conversationId = document.documentID
                    let data = document.data()
                    
                    // Get conversation metadata
                    let startTime = (data["startTime"] as? Timestamp)?.dateValue() ?? Date()
                    let userEmail = data["userEmail"] as? String ?? ""
                    
                    // Create temporary conversation
                    let conversation = Conversation(
                        id: conversationId,
                        startTime: startTime,
                        userEmail: userEmail,
                        messages: []
                    )
                    
                    // Load messages for this conversation
                    self?.loadMessages(for: conversation)
                }
            }
    }
    
    private func loadMessages(for conversation: Conversation) {
        db.collection("conversations")
            .document(conversation.id)
            .collection("messages")
            .order(by: "timestamp")
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("Error loading messages: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                let messages = documents.compactMap { document -> ChatMessage? in
                    try? document.data(as: ChatMessage.self)
                }
                
                // Only add conversation if it has messages
                if !messages.isEmpty {
                    DispatchQueue.main.async {
                        let updatedConversation = Conversation(
                            id: conversation.id,
                            startTime: conversation.startTime,
                            userEmail: conversation.userEmail,
                            messages: messages
                        )
                        
                        // Remove existing conversation with same ID if exists
                        self?.conversations.removeAll(where: { $0.id == conversation.id })
                        // Add updated conversation
                        self?.conversations.append(updatedConversation)
                        // Sort conversations by last message time
                        self?.conversations.sort(by: { $0.lastUpdateTime > $1.lastUpdateTime })
                        
                        self?.objectWillChange.send()
                    }
                }
            }
    }
    
    func startNewConversation() -> String? {
        guard let userEmail = Auth.auth().currentUser?.email else { return nil }
        let conversationId = "\(userEmail)_\(Date().timeIntervalSince1970)"
        
        db.collection("conversations")
            .document(conversationId)
            .setData([
                "userEmail": userEmail,
                "startTime": FieldValue.serverTimestamp(),
                "lastUpdateTime": FieldValue.serverTimestamp()
            ])
        
        currentConversationId = conversationId
        return conversationId
    }
    
    func getCurrentConversationId() -> String? {
        return currentConversationId
    }
}
