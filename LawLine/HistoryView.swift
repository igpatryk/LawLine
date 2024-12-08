import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = ChatHistoryViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedConversation: Conversation?
    
    var body: some View {
        NavigationView {
            Group {
                if viewModel.conversations.isEmpty {
                    VStack(spacing: 20) {
                        ProgressView()
                        Text("Ładowanie historii...")
                            .foregroundColor(.gray)
                    }
                } else {
                    List {
                        ForEach(viewModel.conversations) { conversation in
                            NavigationLink {
                                ConversationView(conversation: conversation)
                            } label: {
                                ConversationPreview(conversation: conversation)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Historia Czatów")
            .navigationBarItems(trailing: Button("Zamknij") {
                dismiss()
            })
            .onAppear {
                viewModel.loadConversations(for: authViewModel.email)
            }
        }
    }
}

struct ConversationPreview: View {
    let conversation: Conversation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(conversation.lastMessage)
                .lineLimit(1)
                .foregroundColor(.primary)
            
            Text(formatDate(conversation.lastUpdateTime))
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding(.vertical, 4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct ConversationView: View {
    let conversation: Conversation
    @State private var showingChatView = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(conversation.messages) { message in
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
                .padding()
            }
            NavigationLink {
                ChatView(
                    existingConversationId: conversation.id,
                    existingMessages: conversation.messages,
                    showNavigation: false  // Hide navigation when pushed from ConversationView
                )
            } label: {
                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                    Text("Kontynuuj rozmowę")
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.bottom)
        }
        .navigationTitle("Czat")
        .navigationBarTitleDisplayMode(.inline)
    }
}
