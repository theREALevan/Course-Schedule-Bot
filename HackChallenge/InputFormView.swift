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

                // Profile (no NetID)
                Section(header: Text("Your Profile").font(.headline)) {
                    DatePicker("Graduation Date", selection: $vm.graduationDate, displayedComponents: .date)
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

                // Submit
                Section {
                    Button("Get Schedule") {
                        guard let id = session.user?.id else { return }
                        vm.submit(userId: id)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }

                // Recommendation
                if let schedule = vm.recommended {
                    Section {
                        NavigationLink("View Schedule", destination: ScheduleView(schedule: schedule))
                    }
                }
            }
            .navigationTitle("Course Scheduler")
        }
    }
}
