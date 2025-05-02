//
//  LoginView.swift
//  HackChallenge
//
//  Created by Zhang Yiwen Evan on 2025/5/2.
//

import SwiftUI

struct LoginView: View {
    @State private var netid: String = ""
    @State private var isLoggingIn = false
    @ObservedObject private var session = SessionStore.shared

    var body: some View {
        ZStack {
            // 1. Full-screen gradient background
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                // 2. App title & icon
                VStack(spacing: 8) {
                    Image(systemName: "book.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 72, height: 72)
                        .foregroundStyle(.white, .blue)
                    Text("Course Scheduler")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                // 3. Card-like login form
                VStack(spacing: 16) {
                    // NetID field with custom style
                    TextField("NetID", text: $netid)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)

                    // Login button
                    Button(action: attemptLogin) {
                        HStack {
                            if isLoggingIn {
                                ProgressView()
                            } else {
                                Text("Log In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                    }
                    .disabled(netid.trimmingCharacters(in: .whitespaces).isEmpty || isLoggingIn)
                }
                .padding(24)
                .background(Color(.systemBackground).opacity(0.95))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 24)

                Spacer()
            }
            .padding(.top, 60)
        }
    }

    private func attemptLogin() {
        isLoggingIn = true
        session.login(netid: netid)
        // In production, observe session.user instead of fixed delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            isLoggingIn = false
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
