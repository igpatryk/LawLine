import FirebaseAuth
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var email = ""
    @Published var password = ""
    @Published var isEmailVerified = false
    @Published var signUpError: String?

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            if let error = error as NSError? {
                self?.handleSignInError(error)
            } else if let user = result?.user {
                user.reload { error in
                    self?.isEmailVerified = user.isEmailVerified
                    if user.isEmailVerified {
                        self?.isAuthenticated = true
                    } else {
                        self?.signUpError = "Please verify your email before signing in."
                    }
                }
            }
        }
    }

    private func handleSignInError(_ error: NSError) {
        self.signUpError = error.localizedDescription
    }

    func signUp(completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(error)
            } else if let user = result?.user {
                self.sendEmailVerification(to: user) { error in
                    if let error = error {
                        self.signUpError = "Failed to send verification email: \(error.localizedDescription)"
                    } else {
                        self.signUpError = "A verification email has been sent to \(self.email). Please verify before signing in."
                    }
                    completion(nil)
                }
            }
        }
    }

    private func sendEmailVerification(to user: User, completion: @escaping (Error?) -> Void) {
        user.sendEmailVerification(completion: completion)
    }
}
