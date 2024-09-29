import FirebaseAuth

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var signUpError: String?
    @Published var isEmailVerified = false
    @Published var isAuthenticated = false

    init() {
        checkAuthentication()
    }

    func checkAuthentication() {
        if let user = Auth.auth().currentUser {
            isAuthenticated = user.isEmailVerified
        } else {
            isAuthenticated = false
        }
    }

    func signUp(completion: @escaping (Error?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.signUpError = error.localizedDescription
                completion(error) // Pass the error back
            } else if let user = result?.user {
                user.sendEmailVerification { error in
                    if let error = error {
                        self.signUpError = error.localizedDescription
                        completion(error)
                    } else {
                        self.signUpError = nil
                        completion(nil)
                    }
                }
            }
        }
    }

    func signIn() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.signUpError = error.localizedDescription
            } else if let user = result?.user {
                self.isEmailVerified = user.isEmailVerified
                self.isAuthenticated = user.isEmailVerified // Update the authentication state
                if !user.isEmailVerified {
                    self.signUpError = "Please verify your email before signing in."
                }
            }
        }
    }

    func signOut() {
        do {
            try Auth.auth().signOut()
            self.isAuthenticated = false
        } catch let error {
            self.signUpError = error.localizedDescription
        }
    }
}
