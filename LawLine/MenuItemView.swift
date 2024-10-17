import SwiftUI

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
