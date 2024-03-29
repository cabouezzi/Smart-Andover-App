//
//  LoginView.swift
//  Smart Andover
//
//  Created by Chaniel Ezzi on 9/7/21.
//

import SwiftUI

struct LoginView: View {
    
    @Namespace var namespace
    
    private enum Pages {
        case start, login, register, resetPassword
    }
    
    @Binding var user: User?
    
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    
    @State private var error: Error?
    @State private var shouldStarFields: Bool = false
    @State private var state: Pages = .start
    
    var body: some View {
        
        switch state {
        
        case .start:
            StartView()
            
        case .login:
            LoginView()
            
        case .register:
            RegisterView()
            
        case .resetPassword:
            ResetPasswordView()
            
        }
        
    }
    
    @ViewBuilder func StartView () -> some View {
        
        VStack {
            
            Button("Login") {
                
                withAnimation {
                    state = .login
                }
                
            }
            .buttonStyle(BarButtonStyle(tint: .theme))
            .matchedGeometryEffect(id: 0, in: namespace)
            
            HStack {
                
                VStack {Divider()}
                
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack {Divider()}
                
            }
            
            Button("Register") {
                
                withAnimation {
                    state = .register
                }
                
            }
            .buttonStyle(BarButtonStyle(tint: .green))
            .matchedGeometryEffect(id: 1, in: namespace)
            
        }
        .padding()
        
    }
    
    @ViewBuilder func LoginView () -> some View {
        
        VStack (spacing: 10) {
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .requiredField($shouldStarFields)
            
            SecureField("Password", text: $password)
                .textContentType(.password)
                .requiredField($shouldStarFields)
            
            Button("Login", action: login)
                .buttonStyle(BarButtonStyle(tint: .theme))
                .matchedGeometryEffect(id: 0, in: namespace)
            
            Button("Forgot Password") {
                
                state = .resetPassword
                
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.theme)
            
            Button("Back") {
                
                withAnimation {
                    shouldStarFields = false
                    error = nil
                    state = .start
                }
                
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.theme)
            
            if let error = error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .font(.caption)
                    .layoutPriority(1)
            }
            
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
        
    }
    
    @ViewBuilder func RegisterView () -> some View {
        
        VStack (spacing: 10) {
            
            TextField("First name", text: $firstName)
                .textContentType(.givenName)
                .requiredField($shouldStarFields)
            
            TextField("Last name", text: $lastName)
                .textContentType(.familyName)
                .requiredField($shouldStarFields)
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
                .requiredField($shouldStarFields)
            
            SecureField("Password", text: $password)
                .textContentType(.newPassword)
                .requiredField($shouldStarFields)
            
            Button("Register", action: register)
                .buttonStyle(BarButtonStyle(tint: .green))
                .matchedGeometryEffect(id: 1, in: namespace)
            
            Button("Back") {
                
                withAnimation {
                    shouldStarFields = false
                    error = nil
                    state = .start
                }
                
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.theme)
            
            if let error = error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .font(.caption)
                    .layoutPriority(1)
            }
            
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
        
    }
    
    @ViewBuilder func ResetPasswordView () -> some View {
        
        VStack (spacing: 10) {
            
            TextField("Email", text: $email)
                .textContentType(.emailAddress)
            
            Button("Send") {
                
                DatabaseController.authentication.sendPasswordReset(withEmail: email) { er in
                    if let er = er {
                        error = er
                    }
                    else {
                        state = .start
                    }
                }
                
            }
            .buttonStyle(BarButtonStyle(tint: .blue))
            
            Text("Enter your email address and we'll send you instructions to reset your password.")
                .foregroundColor(.secondary)
                .font(.caption)
            
            Button("Back") {
                
                withAnimation {
                    shouldStarFields = false
                    error = nil
                    state = .login
                }
                
            }
            .buttonStyle(PlainButtonStyle())
            .foregroundColor(.theme)
            
            if let error = error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
                    .font(.caption)
                    .layoutPriority(1)
            }
            
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding()
        
    }
    
    func login () {
        
        guard !email.isEmpty && !password.isEmpty else {
            shouldStarFields = true
            return
        }
        
        DatabaseController.signIn(email: email, password: password) { user, error in
            
            let credentials = try? Keychain.retrieveCredentials()
            
            if error == nil {
                if credentials == nil {
                    try? Keychain.saveCredentials(email: email, password: password)
                }
                else {
                    do { try Keychain.updateCredentials(newEmail: email, newPassword: password) }
                    catch { print("Error updating credentials") }
                }
            }
            
            withAnimation {
                self.user = user
                self.error = error
            }
            
        }
        
    }
    
    func register () {
        
        guard !email.isEmpty && !password.isEmpty else {
            shouldStarFields = true
            return
        }
        
        DatabaseController.signUp(firstName: firstName, lastName: lastName, email: email, password: password) { user, error in
            
            do {
                try Keychain.saveCredentials(email: email, password: password)
            }
            catch {
                print(error)
            }
            
            withAnimation {
                self.user = user
                self.error = error
            }
            
        }
        
    }
    
}
