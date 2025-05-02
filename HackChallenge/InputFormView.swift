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
                        ForEach(vm.yearOptions, id: \.self) {
                            Text($0)
                        }
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
                            case .success(let updatedUser):
                                DispatchQueue.main.async {
                                    session.user = updatedUser
                                    // 2) Sync previous courses
                                    let courseNums = vm.previousCourses
                                        .split(separator: ",")
                                        .map { $0.trimmingCharacters(in: .whitespaces) }
                                        .filter { !$0.isEmpty }

                                    // First clear existing completions if needed, then add each:
                                    APIService.shared.fetchCompletedCourses(userId: user.id) { existing in
                                        if case .success(let already) = existing {
                                            // Remove ones no longer listed
                                            let toRemove = Set(already).subtracting(courseNums)
                                            let toAdd = Set(courseNums).subtracting(already)

                                            // (Assuming you have an API to delete completions—
                                            // otherwise you might skip removals.)
                                            // For now just add any new ones:
                                            toAdd.forEach { num in
                                                APIService.shared.addCompletedCourse(
                                                    userId: user.id,
                                                    courseNumber: num
                                                ) { _ in }
                                            }
                                        }
                                        // 3) Generate schedule
                                        DispatchQueue.main.async {
                                            vm.submit(userId: user.id)
                                        }
                                    }
                                }

                            case .failure(let error):
                                print("Update failed:", error)
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
                if chars.count == 7 * 12 {
                    vm.availability = stride(from: 0, to: chars.count, by: 12)
                        .map { i in chars[i..<i+12].map { $0 == "1" } }
                }

                // load existing completed courses into previousCourses text
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
