import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var confirmPassword = ""
    
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

            // Display error in red, and email verification message in blue
            if let error = authViewModel.signUpError {
                Text(error)
                    .foregroundColor(error.contains("verification email") ? .blue : .red) // Check if it's a verification message
                    .padding()
            }

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
