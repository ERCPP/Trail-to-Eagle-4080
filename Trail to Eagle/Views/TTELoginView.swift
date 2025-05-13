//
//  TTELoginView.swift
//  Trail to Eagle
//
//  Created by Eric Wagner-Roberts on 1/4/24.
//

import SwiftUI

struct TTELoginView: View {
    @State private var username: String = ""
    @State private var password: String = ""
    @State var apiManager: APIManager
    @State var isLoading = false
    let animation = Animation.linear.repeatForever(autoreverses: false)
    
    @State private var errorMessage: String?
    @Environment(\.dismiss) var dismiss
    
    var onSuccess: (() -> Void)?

    var body: some View {
        VStack {
            if #available(iOS 16.0, *) {
                Image(systemName: "person.crop.circle")
                    .fontWeight(.light)
                    .font(.system(size: 80))
                    .padding(.bottom)
                    .foregroundColor(Color.blue)
                    .rotationEffect(.degrees(isLoading ? 440 : 0))
                    .animation(.default, value: isLoading)
            } else {
                Image(systemName: "person.crop.circle")
                    .font(.system(size: 80, weight: .light))
                    .padding(.bottom)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundColor(Color.blue)
                    .rotationEffect(.degrees(isLoading ? 440 : 0))
                    .animation(.default, value: isLoading)
            }
            Text("Your credentials are required to access server information.")
                .font(.body)
                .fontWeight(.regular)
                .multilineTextAlignment(.center)
                .padding(.bottom)
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.bottom, 5)
            }
            TextField("Username", text: $username)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal)
                .textContentType(.username)
            SecureField("Password", text: $password)
                .autocapitalization(.none)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
                .padding(.horizontal)
                .textContentType(.password)
            // For Eventual 2FA .textContentType = .oneTimeCode
            Button(action: login) {
                Text("Login")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(!(username.isEmpty || password.isEmpty) ? Color.blue : Color.gray)
                    .cornerRadius(12)
                    .padding(.horizontal)
            }
            .disabled(username.isEmpty || password.isEmpty || isLoading)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .padding()
    }
    
    private func login() {
        isLoading = true
        errorMessage = nil
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        apiManager.login(username: username, password: password) { result in
            isLoading = false
            switch result {
            case .success:
                onSuccess?()
                dismiss()
            case .failure(let error):
                if case .unauthorized = error {
                    errorMessage = "Incorrect Username or Password"
                } else {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
