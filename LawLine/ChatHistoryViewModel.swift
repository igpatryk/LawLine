import Foundation
import FirebaseFirestore
import FirebaseAuth

struct Conversation: Identifiable, Equatable {
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
    
    static func == (lhs: Conversation, rhs: Conversation) -> Bool {
        return lhs.id == rhs.id
    }
}

class ChatHistoryViewModel: ObservableObject {
    @Published var conversations: [Conversation] = []
    private let db = Firestore.firestore()
    private var currentConversationId: String?
    private var messageListeners: [String: ListenerRegistration] = [:]
    
    func setCurrentConversationId(_ id: String) {
        currentConversationId = id
    }
    
    func saveMessage(_ message: Message, userEmail: String) {
        guard let conversationId = currentConversationId else {
            currentConversationId = startNewConversation()
            saveMessage(message, userEmail: userEmail)
            return
        }
        
        let chatMessage = ChatMessage(
            text: message.text,
            isUserMessage: message.isUserMessage,
            timestamp: Date(),
            userEmail: userEmail
        )
        
        db.collection("conversations")
            .document(conversationId)
            .setData([
                "userEmail": userEmail,
                "lastUpdateTime": Date(),
                "startTime": FieldValue.serverTimestamp()
            ], merge: true)
        
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
                    
                    // Keep track of current conversation IDs
                    var currentIds = Set<String>()
                    
                    for document in documents {
                        let conversationId = document.documentID
                        currentIds.insert(conversationId)
                        let data = document.data()
                        
                        let startTime = (data["startTime"] as? Timestamp)?.dateValue() ?? Date()
                        let userEmail = data["userEmail"] as? String ?? ""
                        
                        // Check if conversation already exists
                        let conversationExists = self?.conversations.contains(where: { $0.id == conversationId }) ?? false
                        if !conversationExists {
                            // Only create new conversation if it doesn't exist
                            let conversation = Conversation(
                                id: conversationId,
                                startTime: startTime,
                                userEmail: userEmail,
                                messages: []
                            )
                            self?.loadMessages(for: conversation)
                        }
                    }
                    
                    // Remove conversations that no longer exist
                    self?.conversations.removeAll(where: { !currentIds.contains($0.id) })
                    
                    // Clean up listeners for removed conversations
                    self?.messageListeners.forEach { id, listener in
                        if !currentIds.contains(id) {
                            listener.remove()
                            self?.messageListeners.removeValue(forKey: id)
                        }
                    }
                }
        }
    
    private func loadMessages(for conversation: Conversation) {
        // Remove existing listener if any
        messageListeners[conversation.id]?.remove()
        
        let listener = db.collection("conversations")
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
                
                DispatchQueue.main.async {
                    if let index = self?.conversations.firstIndex(where: { $0.id == conversation.id }) {
                        // Update messages for existing conversation
                        self?.conversations[index].messages = messages
                    } else if !messages.isEmpty {
                        // Add new conversation
                        let updatedConversation = Conversation(
                            id: conversation.id,
                            startTime: conversation.startTime,
                            userEmail: conversation.userEmail,
                            messages: messages
                        )
                        self?.conversations.append(updatedConversation)
                    }
                    
                    // Sort conversations by last message time
                    self?.conversations.sort(by: { $0.lastUpdateTime > $1.lastUpdateTime })
                    self?.objectWillChange.send()
                }
            }
        
        // Store the listener
        messageListeners[conversation.id] = listener
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
    
    deinit {
        // Clean up all listeners when view model is deallocated
        messageListeners.values.forEach { $0.remove() }
    }
}
