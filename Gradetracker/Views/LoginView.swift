//
//  LoginView.swift
//

import Foundation
import SwiftUI
import SwiftData

struct LoginView: View {
    
    @EnvironmentObject var appState: AppState
    @Environment(\.modelContext) private var modelContext
    
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View{
        NavigationStack {
            VStack(alignment: .leading, spacing: 15) {
                Spacer(minLength: 0)
                
                Text("Login")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                Text("Please sign in to continue")
                    .font(.callout)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)
                    .padding(.top, -5)
                
                VStack(spacing: 25) {
                    // Custom Text Fields
                    CustomTF(sfIcon: "at", hint: "Email", isPassword: false, value: $email)
                    
                    CustomTF(sfIcon: "lock", hint: "Password", isPassword: true, value: $password)
                        .padding(.top, 5)
                    
                    // Login Button
                    CustomButton(title: "Login", icon: "arrow.right") {
                        self.login()
                    }
                    .hSpacing(.trailing)
                    // Disabling Button When Text Fields Are Empty
                    .disableWithOpacity(email.isEmpty || password.isEmpty)
                }
                .padding(.top, 20)
                
                Spacer(minLength: 0)
                
            }
            .padding(.vertical, 15)
            .padding(.horizontal, 25)
            .toolbar(.hidden, for: .navigationBar)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Wrong Email or Password"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func login() {
        let email: String = self.email
        let password: String = self.password
        if !isValidEmail(email) {
            self.showAlert = true
            self.alertMessage = "Invalid email address"
            return
        }
        let fetchDescriptor = FetchDescriptor<UserModel>(
            predicate: #Predicate{ $0.email == email }
        )
        if let user = try? modelContext.fetch(fetchDescriptor).first {
            if user.checkPassword(password) {
                self.appState.user = user
                self.appState.userIsLoggedIn = true
            }
        }
        self.showAlert = true
        self.alertMessage = "Password not matched"
        return
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

}
