import SwiftUI

struct HelloView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var historyViewModel = ChatHistoryViewModel()
    @State private var showChatView = false
    @State private var showPDFViewer = false
    @State private var showHistoryView = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with app name
            Text("LawLine")
                .font(.title)
                .fontWeight(.bold)
                .padding(.bottom, 10)
                .frame(maxWidth: .infinity)
                .background(Color(red: 0.96, green: 0.93, blue: 0.88))
                .foregroundColor(.black)

            Spacer(minLength: 15)
            // Kafelki funkcji w beżowym kolorze
            ScrollView {
                VStack(spacing: 16) {
                    // Pierwszy rząd kafelków
                    HStack(spacing: 16) {
                        FeatureTileView(
                            title: "Pomoc AI",
                            imageName: "brain.fill",
                            backgroundColor: Color(red: 0.96, green: 0.93, blue: 0.88)
                        )
                        .onTapGesture {
                            showChatView = true
                        }
                        
                        FeatureTileView(
                            title: "Historia rozmów",
                            imageName: "clock.fill",
                            backgroundColor: Color(red: 0.96, green: 0.93, blue: 0.88)
                        )
                        .onTapGesture {
                            showHistoryView = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Drugi rząd kafelków
                    HStack(spacing: 16) {
                        FeatureTileView(
                            title: "Kontakt z prawnikiem",
                            imageName: "person.fill",
                            backgroundColor: Color(red: 0.96, green: 0.93, blue: 0.88)
                        )
                        
                        FeatureTileView(
                            title: "Kodeks karny",
                            imageName: "book.fill",
                            backgroundColor: Color(red: 0.96, green: 0.93, blue: 0.88)
                        )
                        .onTapGesture {
                            showPDFViewer = true
                        }
                    }
                    .padding(.horizontal)
                    
                    // Historia rozmów
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Ostatnie rozmowy")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button("Zobacz wszystkie") {
                                showHistoryView = true
                            }
                            .foregroundColor(.blue)
                        }
                        .padding(.horizontal)
                        
                        if historyViewModel.conversations.isEmpty {
                            Text("Brak historii rozmów")
                                .foregroundColor(.gray)
                                .padding()
                        } else {
                            ForEach(historyViewModel.conversations.prefix(3)) { conversation in
                                Button(action: {
                                    // Handle conversation tap
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(conversation.lastMessage)
                                            .lineLimit(2)
                                            .foregroundColor(.primary)
                                            .multilineTextAlignment(.leading)
                                        
                                        Text(formatDate(conversation.lastUpdateTime))
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(red: 0.96, green: 0.93, blue: 0.88))
                                    .cornerRadius(10)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top)
                }
            }

            // Menu dolne
            HStack {
                MenuItemView(title: "Strona główna", imageName: "house.fill")
                MenuItemView(
                    title: "Historia",
                    imageName: "message.fill",
                    action: {
                        showHistoryView = true
                    }
                )
                MenuItemView(
                    title: "Kodeks Karny",
                    imageName: "book.fill",
                    action: {
                        showPDFViewer = true
                    }
                )
                MenuItemView(title: "Ustawienia", imageName: "gearshape.fill")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .edgesIgnoringSafeArea(.bottom)
        .fullScreenCover(isPresented: $showChatView) {
            ChatView()
        }
        .sheet(isPresented: $showHistoryView) {
            HistoryView()
                .environmentObject(authViewModel)
        }
        .fullScreenCover(isPresented: $showPDFViewer) {
            NavigationView {
                if let pdfURL = Bundle.main.url(forResource: "kodeks_karny", withExtension: "pdf") {
                    PDFViewerView(pdfURL: pdfURL)
                        .navigationBarTitle("Kodeks Karny", displayMode: .inline)
                        .navigationBarItems(trailing: Button("Zamknij") {
                            showPDFViewer = false
                        })
                } else {
                    Text("Nie można znaleźć pliku PDF")
                        .navigationBarItems(trailing: Button("Zamknij") {
                            showPDFViewer = false
                        })
                }
            }
        }
        .onAppear {
            historyViewModel.loadConversations(for: authViewModel.email)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct FeatureTileView: View {
    let title: String
    let imageName: String
    var backgroundColor: Color = .blue.opacity(0.2)
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .font(.system(size: 30))
                .foregroundColor(.black)
            Text(title)
                .font(.subheadline)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 100)
        .background(backgroundColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(.black, lineWidth: 1)
        )
    }
}

struct MenuItemView: View {
    let title: String
    let imageName: String
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            VStack {
                Image(systemName: imageName)
                    .font(.system(size: 20))
                Text(title)
                    .font(.caption)
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundColor(.gray)
    }
}
