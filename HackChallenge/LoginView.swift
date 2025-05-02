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

    // MARK: –– Styling
    private let backgroundGradient = LinearGradient(
        gradient: Gradient(colors: [Color.blue.opacity(0.85), Color.purple.opacity(0.85)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            VStack {
                Spacer()

                // Title directly above the login card
                Text("📚 Schedulr")
                    .font(.system(size: 36, weight: .black, design: .rounded))
                    .foregroundColor(.white)

                // Login card centered
                VStack(spacing: 16) {
                    TextField("NetID (e.g. rm834)", text: $netid)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1),
                                radius: 4, x: 0, y: 2)

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
                        .background(RoundedRectangle(cornerRadius: 8).fill(Color.blue))
                        .foregroundColor(.white)
                    }
                    .disabled(netid.trimmingCharacters(in: .whitespaces).isEmpty || isLoggingIn)
                }
                .padding(24)
                .background(Color(.systemBackground).opacity(0.97))
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.horizontal, 32)

                // Optional tagline below card
                Text("Plan & rank your CS classes with AI‑powered schedules")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .padding(.horizontal, 40)

                Spacer()

                // Footer Info
                VStack(spacing: 8) {
                    Text("🧠 About Schedulr")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Generates personalized CS course schedules based on your grad year, completed courses & interests. Core data powered by Cornell’s API; AI‑driven prioritization of untaken core and electives.")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)

                    HStack(spacing: 16) {
                        Link("Frontend Repo", destination: URL(string: "https://github.com/theREALevan/Course-Schedule-Bot")!)
                        Link("API Spec", destination: URL(string: "https://github.com/Robylongo/CourseApp/blob/main/api_spec.md")!)
                    }
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 24)
            }
            .padding(.top, 60)
        }
    }

    private func attemptLogin() {
        isLoggingIn = true
        session.login(netid: netid)
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
