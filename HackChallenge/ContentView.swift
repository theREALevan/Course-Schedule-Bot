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
    @StateObject private var schedulerVM = SchedulerViewModel()

    var body: some View {
        NavigationStack {
            InputFormView()
                .environmentObject(schedulerVM)
                .navigationTitle("Input")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(
                    isPresented: Binding(
                        get: { schedulerVM.recommended != nil },
                        set: { if !$0 { schedulerVM.recommended = nil } }
                    )
                ) {
                    if let sched = schedulerVM.recommended {
                        ScheduleView(schedule: sched)
                    }
                }
        }
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
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
