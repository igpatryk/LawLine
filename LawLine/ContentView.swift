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
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack {
            Image("icon with text")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)

            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                signIn()
            }) {
                Text("Sign In")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()

            Button(action: {
                showSignUp = true
            }) {
                Text("Don't have an account? Sign Up")
                    .foregroundColor(.blue)
            }
            .sheet(isPresented: $showSignUp, onDismiss: {
                authViewModel.signUpError = nil
            }) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
        .padding()
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func signIn() {
        // Clear any previous errors before sign-in attempt
        authViewModel.signUpError = nil
        showAlert = false

        authViewModel.signIn()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // Check if there is any sign-in error after attempt
            if let error = authViewModel.signUpError {
                alertMessage = error
                showAlert = true
            }
        }
    }
}


