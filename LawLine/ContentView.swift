import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        if authViewModel.isAuthenticated { // Now this will work as 'isAuthenticated' is part of AuthViewModel
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
    @State private var showEmailNotVerifiedAlert = false
    
    var body: some View {
        VStack {
            // Image above the login form
            Image("icon with text") // Replace "loginImage" with the name of your image asset
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)
            
            // Login form
            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                authViewModel.signIn()
                if !authViewModel.isEmailVerified {
                    showEmailNotVerifiedAlert = true // Trigger popup if email is not verified
                }
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
            .sheet(isPresented: $showSignUp) {
                SignUpView()
                    .environmentObject(authViewModel)
            }
        }
        .padding()
        // Show popup for unverified email
        .alert(isPresented: $showEmailNotVerifiedAlert) {
            Alert(title: Text("Email Verification Required"), message: Text("Please verify your email before signing in."), dismissButton: .default(Text("OK")))
        }
    }
}
