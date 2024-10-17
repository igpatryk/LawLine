import SwiftUI

struct HelloView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showChatView = false // Dodajemy flagę nawigacji
    
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
                    imageName: "brain"
                )
                .onTapGesture {
                    showChatView = true
                }
                .fullScreenCover(isPresented: $showChatView) {
                    ChatView() // Prezentacja widoku czatu
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
            }
            .padding()

            Spacer()

            // Menu dolne
            HStack {
                MenuItemView(title: "Strona główna", imageName: "house.fill")
                MenuItemView(title: "Historia", imageName: "message.fill")
                MenuItemView(title: "Kodeks prawny", imageName: "book.fill")
                MenuItemView(title: "Ustawienia", imageName: "gearshape.fill")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}
