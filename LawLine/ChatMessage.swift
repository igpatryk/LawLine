import Foundation
import FirebaseFirestore

struct ChatMessage: Identifiable, Codable {
    @DocumentID var id: String?
    let text: String
    let isUserMessage: Bool
    let timestamp: Date
    let userEmail: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case isUserMessage
        case timestamp
        case userEmail
    }
}
