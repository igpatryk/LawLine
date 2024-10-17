import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var confirmPassword = ""
    @State private var alertMessage = ""
    @State private var showAlert = false

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
        // Alert is presented based on showAlert state
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(alertMessage.contains("A verification email has been sent to") ? "Thank you!" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    // Reset alert state after dismissing
                    authViewModel.signUpError = nil
                }
            )
        }
        .onChange(of: authViewModel.signUpError) {
            if let error = authViewModel.signUpError {
                // Trigger alert update only when a new error occurs
                alertMessage = error
                showAlert = true // Ensure alert is shown on every error
            }
        }
    }

    func signUp() {
        guard authViewModel.password == confirmPassword else {
            authViewModel.signUpError = "Passwords do not match"
            return
        }

        authViewModel.signUp { error in
            if let error = error {
                authViewModel.signUpError = error.localizedDescription
            } else {
                authViewModel.signUpError = "A verification email has been sent to \(authViewModel.email). Please verify before signing in."
            }
        }
    }
}
