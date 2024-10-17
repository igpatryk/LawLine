import SwiftUI

struct HelloView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
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

// Kafelki z funkcjami
struct FeatureTileView: View {
    var title: String
    var imageName: String

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
                .padding()

            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 10)
        }
        .frame(width: 160, height: 160)
        .background(Color.blue)
        .cornerRadius(15)
        .shadow(radius: 5)
    }
}

// Menu dolne
struct MenuItemView: View {
    var title: String
    var imageName: String

    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.blue)
            Text(title)
                .font(.caption)
                .foregroundColor(.blue)
        }
        .frame(maxWidth: .infinity)
    }
}

struct HelloView_Previews: PreviewProvider {
    static var previews: some View {
        HelloView().environmentObject(AuthViewModel())
    }
}
