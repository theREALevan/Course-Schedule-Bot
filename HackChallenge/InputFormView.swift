// InputFormView.swift

import SwiftUI

struct InputFormView: View {
    @EnvironmentObject var session: SessionStore
    @StateObject private var vm = SchedulerViewModel()
    @State private var didInitialize = false

    @State private var selectedYear: Int = Calendar.current.component(.year, from: Date())
    private let yearRange: [Int] = {
        let current = Calendar.current.component(.year, from: Date())
        return Array(current...(current + 5))
    }()

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
                    Picker("Graduation Year", selection: $selectedYear) {
                        ForEach(yearRange, id: \.self) { year in
                            Text("\(year)").tag(year)
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

                        let availStr = vm.availability
                            .flatMap { $0 }
                            .map { $0 ? "1" : "0" }
                            .joined()
                        
                        APIService.shared.updateUser(
                            id: user.id,
                            graduationYear: String(selectedYear),
                            interests: vm.interest.isEmpty ? nil : vm.interest,
                            availability: availStr
                        ) { result in
                            switch result {
                            case .success(let updatedUser):
                                DispatchQueue.main.async {
                                    session.user = updatedUser

                                    let courseNums = vm.previousCourses
                                        .split(separator: ",")
                                        .map { $0.trimmingCharacters(in: .whitespaces) }
                                        .filter { !$0.isEmpty }

                                    let group = DispatchGroup()
                                    for num in courseNums {
                                        group.enter()
                                        APIService.shared.addCompletedCourse(
                                            userId: updatedUser.id,
                                            courseNumber: num
                                        ) { _ in group.leave() }
                                    }

                                    group.notify(queue: .main) {
                                        APIService.shared.fetchCompletedCourses(userId: updatedUser.id) { fetchResult in
                                            if case .success(let comps) = fetchResult {
                                                DispatchQueue.main.async {
                                                    vm.previousCourses = comps.joined(separator: ", ")
                                                }
                                            }
                                            vm.submit(userId: updatedUser.id)
                                        }
                                    }
                                }

                            case .failure:
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

                // Recommended schedule link
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

                // Initialize selectedYear from user
                selectedYear = Int(user.graduationYear) ?? Calendar.current.component(.year, from: Date())

                vm.interest = user.interests ?? ""

                let chars = Array(user.availability)
                if chars.count == 7 * 12 {
                    vm.availability = stride(from: 0, to: chars.count, by: 12)
                        .map { i in chars[i..<i+12].map { $0 == "1" } }
                }

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
