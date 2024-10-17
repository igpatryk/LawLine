import SwiftUI

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
