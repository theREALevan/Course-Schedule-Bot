//
//  InputFormView.swift
//  HackChallenge
//
//  Created by Zhang Yiwen Evan on 2025/5/2.
//

import SwiftUI

struct InputFormView: View {
    @EnvironmentObject var session: SessionStore
    @StateObject private var vm = SchedulerViewModel()
    @State private var didInitialize = false

    var body: some View {
        NavigationView {
            Form {
                // Greeting
                if let user = session.user {
                    Section {
                        Text("Welcome, \(user.netid.uppercased())!")
                            .font(.headline)
                    }
                }

                // Profile –– loaded from session.user
                Section(header: Text("Your Profile").font(.headline)) {
                    DatePicker("Graduation Date",
                               selection: $vm.graduationDate,
                               displayedComponents: .date)
                    Picker("Year", selection: $vm.yearSelection) {
                        ForEach(vm.yearOptions, id: \.self) { Text($0) }
                    }
                }

                // Availability
                Section(header: Text("Availability").font(.headline)) {
                    AvailabilityPickerView(availability: $vm.availability)
                }

                // Preferences
                Section(header: Text("Preferences").font(.headline)) {
                    TextField("Interest (e.g. ML, PL)", text: $vm.interest)
                    TextField("Previous Courses", text: $vm.previousCourses)
                }

                // Generate & Update DB
                Section {
                    Button("Get Schedule") {
                        guard let user = session.user else { return }

                        // 1) Build updated profile payload
                        let yearStr = String(Calendar.current.component(.year, from: vm.graduationDate))
                        let availStr = vm.availability
                            .flatMap { $0 }
                            .map { $0 ? "1" : "0" }
                            .joined()

                        // 2) Update user on backend
                        APIService.shared.updateUser(
                            id: user.id,
                            graduationYear: yearStr,
                            interests: vm.interest.isEmpty ? nil : vm.interest,
                            availability: availStr
                        ) { result in
                            switch result {
                            case .success(let updatedUser):
                                DispatchQueue.main.async {
                                    // sync session
                                    session.user = updatedUser
                                    // 3) generate schedule with new data
                                    vm.submit(userId: updatedUser.id)
                                }
                            case .failure(let error):
                                print("Update failed:", error)
                                // still attempt schedule generation
                                DispatchQueue.main.async {
                                    vm.submit(userId: user.id)
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                // Show newly recommended schedule
                if let schedule = vm.recommended {
                    Section {
                        NavigationLink("View Schedule",
                                       destination: ScheduleView(schedule: schedule))
                    }
                }
            }
            .navigationTitle("Course Scheduler")
            .onAppear {
                guard !didInitialize, let user = session.user else { return }
                didInitialize = true
                // seed vm from session.user
                if let yearInt = Int(user.graduationYear) {
                    vm.graduationDate = Calendar.current.date(
                        from: DateComponents(year: yearInt, month: 1, day: 1)
                    ) ?? Date()
                }
                vm.interest = user.interests ?? ""
                let chars = Array(user.availability)
                if chars.count == 7*12 {
                    vm.availability = stride(from: 0, to: chars.count, by: 12)
                        .map { i in chars[i..<i+12].map { $0 == "1" } }
                }
            }
        }
    }
}
