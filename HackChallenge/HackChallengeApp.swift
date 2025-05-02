// HackChallengeApp.swift
// HackChallenge
// Created by Zhang Yiwen Evan on 2025/4/25.

import SwiftUI

@main
struct HackChallengeApp: App {
    @ObservedObject private var session = SessionStore.shared

    var body: some Scene {
        WindowGroup {
            Group {
                if session.user == nil {
                    LoginView()
                } else {
                    ContentView()
                        .environmentObject(session)
                }
            }
        }
    }
}
