import SwiftUI
struct HelloView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showChatView = false
    @State private var showPDFViewer = false
    
    var body: some View {
        VStack {
            // Pasek powitania na górze ekranu
            VStack {
                Text("Witaj, \(authViewModel.email)")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .foregroundColor(.blue)
            }
            .padding(.top, 20)

            Spacer()

            // Kafelki funkcji
            HStack {
                FeatureTileView(
                    title: "Pomoc AI",
                    imageName: "brain.fill"
                )
                .onTapGesture {
                    showChatView = true
                }
                .fullScreenCover(isPresented: $showChatView) {
                    ChatView()
                }
                
                FeatureTileView(
                    title: "Kontakt z prawnikiem",
                    imageName: "person.fill"
                )
            }
            .padding()

            HStack {
                FeatureTileView(
                    title: "Kodeks karny",
                    imageName: "book.fill"
                )
                .onTapGesture {
                    showPDFViewer = true
                }
            }
            .padding()

            Spacer()

            // Menu dolne
            HStack {
                MenuItemView(title: "Strona główna", imageName: "house.fill")
                MenuItemView(title: "Historia", imageName: "message.fill")
                MenuItemView(
                    title: "Kodeks Karny",
                    imageName: "book.fill"
                )
                .onTapGesture {
                    showPDFViewer = true
                }
                MenuItemView(title: "Ustawienia", imageName: "gearshape.fill")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .edgesIgnoringSafeArea(.bottom)
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
    }
}
