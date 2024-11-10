import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = ChatHistoryViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
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
                            NavigationLink(destination: ConversationDetailView(messages: conversation.messages)) {
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

struct ConversationDetailView: View {
    let messages: [ChatMessage]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(messages) { message in
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
                        .id(message.id)
                    }
                }
                .padding()
            }
        }
        .navigationBarItems(trailing: Button("Zamknij") {
            dismiss()
        })
        .navigationBarTitle("Czat", displayMode: .inline)
    }
}
