import SwiftUI


struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        if authViewModel.isAuthenticated {
            HelloView()
        } else {
            LoginView()
                .environmentObject(authViewModel)
        }
    }
}


struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showSignUp = false

    var body: some View {
        VStack {
            // Image above the login form
            Image("icon with text") // Replace "loginImage" with the name of your image asset
                .resizable()   // Makes the image resizable
                .aspectRatio(contentMode: .fit) // Maintains the aspect ratio of the image
                .frame(width: 150, height: 150) // Adjust the size to fit your design
                .padding(.bottom, 20) // Add some padding between the image and the form
            
            // Login form
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                authViewModel.signIn()
            }) {
                Text("Sign In")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            if let error = authViewModel.signUpError {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }

            Button(action: {
                showSignUp = true
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
        .padding()
    }
}

