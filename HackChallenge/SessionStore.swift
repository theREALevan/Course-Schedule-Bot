//
//  SessionStore.swift
//  HackChallenge
//
//  Created by Zhang Yiwen Evan on 2025/5/2.
//

import Foundation
import Combine

// Singleton that holds the logged‑in user and loads their data.
class SessionStore: ObservableObject {
    static let shared = SessionStore()

    @Published var user: UserResponse? = nil
    @Published var completedCourses: [String] = []
    @Published var pastSchedules: [ScheduleInfoDTO] = []

    private init() {}

    // Look up or create user by netid (case‑insensitive).
    func login(netid: String) {
        let normalized = netid.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()

        APIService.shared.fetchAllUsers { [weak self] result in
            switch result {
            case .success(let users):
                if let existing = users.first(where: { $0.netid.lowercased() == normalized }) {
                    DispatchQueue.main.async {
                        self?.user = existing
                        self?.loadPastData(for: existing.id)
                    }
                } else {
                    let year = Calendar.current.component(.year, from: Date())
                    APIService.shared.createUser(
                        netid: normalized,
                        graduationYear: String(year),
                        interests: nil,
                        availability: String(repeating: "1", count: 7*12)
                    ) { createResult in
                        if case .success(let newUser) = createResult {
                            DispatchQueue.main.async {
                                self?.user = newUser
                                // no past data yet
                            }
                        }
                    }
                }
            case .failure(let error):
                print("Fetch users failed:", error)
            }
        }
    }

    private func loadPastData(for userId: Int) {
        APIService.shared.fetchCompletedCourses(userId: userId) { [weak self] result in
            if case .success(let courses) = result {
                DispatchQueue.main.async { self?.completedCourses = courses }
            }
        }
        APIService.shared.fetchSchedules(userId: userId) { [weak self] result in
            if case .success(let schedules) = result {
                DispatchQueue.main.async { self?.pastSchedules = schedules }
            }
        }
    }

    func logout() {
        user = nil
        completedCourses = []
        pastSchedules = []
    }
}
