// InputFormView.swift

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

                // Profile
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
                    TextField("Previous Courses (comma‑separated)", text: $vm.previousCourses)
                }

                // Generate & Update
                Section {
                    Button("Get Schedule") {
                        guard let user = session.user else { return }

                        // Build updated profile
                        let yearStr = String(
                            Calendar.current.component(.year, from: vm.graduationDate)
                        )
                        let availStr = vm.availability
                            .flatMap { $0 }
                            .map { $0 ? "1" : "0" }
                            .joined()

                        // 1) Update user profile
                        APIService.shared.updateUser(
                            id: user.id,
                            graduationYear: yearStr,
                            interests: vm.interest.isEmpty ? nil : vm.interest,
                            availability: availStr
                        ) { result in
                            switch result {
                            case .success:
                                // 2) Split out course numbers
                                let courseNums = vm.previousCourses
                                    .split(separator: ",")
                                    .map { $0.trimmingCharacters(in: .whitespaces) }
                                    .filter { !$0.isEmpty }

                                // 3) Add each new completion, waiting for all
                                let group = DispatchGroup()
                                courseNums.forEach { num in
                                    group.enter()
                                    APIService.shared.addCompletedCourse(
                                        userId: user.id,
                                        courseNumber: num
                                    ) { _ in
                                        group.leave()
                                    }
                                }

                                // 4) When all additions complete, re‑fetch the full list
                                group.notify(queue: .main) {
                                    APIService.shared.fetchCompletedCourses(userId: user.id) { fetchResult in
                                        if case .success(let comps) = fetchResult {
                                            DispatchQueue.main.async {
                                                // Update the text field so you see _all_ courses
                                                vm.previousCourses = comps.joined(separator: ", ")
                                            }
                                        }
                                        // 5) Finally generate the schedule
                                        vm.submit(userId: user.id)
                                    }
                                }

                            case .failure(let error):
                                print("Profile update failed:", error)
                                // Even on failure, still attempt schedule generation
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

                // Seed vm from session.user
                if let yearInt = Int(user.graduationYear) {
                    vm.graduationDate = Calendar.current.date(
                        from: DateComponents(year: yearInt, month: 1, day: 1)
                    ) ?? Date()
                }

                vm.interest = user.interests ?? ""

                let chars = Array(user.availability)
                if chars.count == 7 * 12 {
                    vm.availability = stride(from: 0, to: chars.count, by: 12)
                        .map { i in chars[i..<i+12].map { $0 == "1" } }
                }

                // Load existing completed courses
                APIService.shared.fetchCompletedCourses(userId: user.id) { result in
                    if case .success(let courses) = result {
                        DispatchQueue.main.async {
                            vm.previousCourses = courses.joined(separator: ", ")
                        }
                    }
                }
            }
        }
    }
}
