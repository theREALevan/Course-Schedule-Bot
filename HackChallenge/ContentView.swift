// ContentView.swift
// HackChallenge
// Created by Zhang Yiwen Evan on 2025/4/25.

import SwiftUI

// MARK: Models

struct Course: Identifiable {
    let id: String
    let title: String
    let description: String
}

struct Schedule: Identifiable {
    let id = UUID()
    let term: String
    let courses: [Course]
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let role: String  // "user" or "assistant"
    let content: String
}

// MARK: ViewModels

class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText = ""

    func send() {
        guard !inputText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        messages.append(.init(role: "user", content: inputText))
        messages.append(.init(role: "assistant", content: "Echo: \(inputText)"))
        inputText = ""
    }
}

// MARK: Availability Picker

struct AvailabilityPickerView: View {
    @Binding var availability: [[Bool]]
    private let days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
    private let hours = Array(8..<20)

    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Text("").frame(width: 40)
                ForEach(days, id: \.self) { Text($0).font(.caption).frame(width: 30) }
            }
            ForEach(0..<hours.count, id: \.self) { h in
                HStack(spacing: 4) {
                    Text("\(hours[h]) :00").font(.caption).frame(width: 40)
                    ForEach(0..<7, id: \.self) { d in
                        Rectangle()
                            .fill(availability[d][h] ? Color.blue : Color.gray.opacity(0.2))
                            .frame(width: 30, height: 30)
                            .cornerRadius(4)
                            .onTapGesture { availability[d][h].toggle() }
                    }
                }
            }
        }
        .padding(8)
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
    }
}

// MARK: Views

struct InputFormView: View {
    @StateObject var vm = SchedulerViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Profile").font(.headline)) {
                    TextField("NetID", text: $vm.netid)
                    DatePicker("Graduation Date", selection: $vm.graduationDate, displayedComponents: .date)
                    Picker("Year", selection: $vm.yearSelection) {
                        ForEach(vm.yearOptions, id: \.self) { Text($0) }
                    }
                }

                Section(header: Text("Availability").font(.headline)) {
                    AvailabilityPickerView(availability: $vm.availability)
                }

                Section(header: Text("Preferences").font(.headline)) {
                    TextField("Interest (e.g. ML, PL)", text: $vm.interest)
                    TextField("Previous Courses", text: $vm.previousCourses)
                }

                Section {
                    Button("Get Schedule") { vm.submit() }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

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

struct ScheduleView: View {
    let schedule: Schedule

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(schedule.term).font(.title2).padding(.horizontal)
                ForEach(schedule.courses) { c in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(c.title).font(.headline)
                        Text(c.description).font(.subheadline).foregroundColor(.secondary)
                        Text(c.id).font(.caption).foregroundColor(.gray)
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 2))
                    .padding(.horizontal)
                }
            }
            .padding(.top)
        }
        .navigationTitle("Schedule")
    }
}

struct ChatView: View {
    @StateObject var vm = ChatViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(vm.messages) { m in
                                HStack {
                                    if m.role == "assistant" { Spacer() }
                                    Text(m.content)
                                        .padding(12)
                                        .background(m.role == "assistant"
                                                    ? Color.gray.opacity(0.2)
                                                    : Color.blue.opacity(0.2))
                                        .cornerRadius(8)
                                    if m.role == "user" { Spacer() }
                                }
                                .id(m.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .onChange(of: vm.messages.count) { _ in
                        if let last = vm.messages.last {
                            proxy.scrollTo(last.id, anchor: .bottom)
                        }
                    }
                }

                HStack {
                    TextField("Message…", text: $vm.inputText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: vm.send) {
                        Image(systemName: "paperplane.fill").font(.title2)
                    }
                    .padding(.leading, 4)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
            }
            .navigationTitle("Chat")
        }
    }
}

struct ContentView: View {
    var body: some View {
        TabView {
            InputFormView().tabItem { Label("Input", systemImage: "pencil") }
            ChatView().tabItem { Label("Chat", systemImage: "bubble.left.and.bubble.right") }
        }
        .accentColor(.blue)
    }
}

// Previews…

struct InputFormView_Previews: PreviewProvider {
    static var previews: some View {
        InputFormView()
    }
}
struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
