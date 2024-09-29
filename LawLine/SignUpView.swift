import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var confirmPassword = ""
    
    // State variables to control the popups
    @State private var showPasswordMismatchAlert = false
    @State private var showEmailVerificationAlert = false
    @State private var showErrorAlert = false
    
    var body: some View {
        VStack {
            // Image above the "Create a New Account" text
            Image("icon with text") // Replace with the name of your image asset
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 150, height: 150)
                .padding(.bottom, 20)

            Text("Create a New Account")
                .font(.title)
                .padding()

            TextField("Email", text: $authViewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Password", text: $authViewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                signUp()
            }) {
                Text("Sign Up")
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        // Show popups (alerts)
        .alert(isPresented: $showPasswordMismatchAlert) {
            Alert(title: Text("Error"), message: Text("Passwords do not match"), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showEmailVerificationAlert) {
            Alert(title: Text("Email Verification"), message: Text("A verification email has been sent to \(authViewModel.email). Please verify your email before signing in."), dismissButton: .default(Text("OK")))
        }
        .alert(isPresented: $showErrorAlert) {
            Alert(title: Text("Error"), message: Text(authViewModel.signUpError ?? ""), dismissButton: .default(Text("OK")))
        }
    }

    func signUp() {
        guard authViewModel.password == confirmPassword else {
            showPasswordMismatchAlert = true // Trigger the password mismatch popup
            return
        }

        authViewModel.signUp { error in
            if let error = error {
                showErrorAlert = true // Trigger the error popup
            } else {
                showEmailVerificationAlert = true // Trigger the email verification popup
            }
        }
    }
}
