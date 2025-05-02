//
//  ScheduleView.swift
//  HackChallenge
//
//  Created by Zhang Yiwen Evan on 2025/5/2.
//  Updated by ChatGPT on 2025/05/02.
//

import SwiftUI

struct ScheduleView: View {
    let schedule: Schedule

    // MARK: –– Styling
    private let fullGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color.blue.opacity(0.85),
            Color.purple.opacity(0.85)
        ]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    var body: some View {
        ZStack {
            // Full‑screen background gradient
            fullGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Title & rationale section
                VStack(spacing: 4) {
                    Text("🗓️ Your Schedule")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)

                    Text(schedule.term)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))

                    // Newly added rationale text
                    Text(schedule.rationale)
                        .font(.subheadline)
                        .italic()
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)

                // Course list
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(schedule.courses) { course in
                            VStack(alignment: .leading, spacing: 8) {
                                // Course number and full name
                                Text("\(course.number): \(course.name)")
                                    .font(.title3)
                                    .fontWeight(.semibold)

                                // Full description, if available
                                if let desc = course.description {
                                    Text(desc)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }

                                // Section identifier at the bottom
                                Text(course.id)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color(.systemBackground))
                            .cornerRadius(16)
                            .shadow(color: Color.black.opacity(0.1),
                                    radius: 5, x: 0, y: 3)
                            .padding(.horizontal, 24)
                        }
                    }
                    .padding(.vertical, 24)
                }
                .background(Color(.systemGroupedBackground))
                .cornerRadius(24, corners: [.topLeft, .topRight])
                // Align to top of its container
                .frame(maxHeight: .infinity, alignment: .top)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible,  for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)
    }
}

// MARK: –– Preview

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        // Sample data for preview
        let sampleCourses = [
            Course(
                id: "CS 3110-A",
                number: "CS 3110",
                name: "Data Structures & Functional Programming",
                description: "Topics in functional programming, recursion, and algebraic data types."
            ),
            Course(
                id: "CS 2800-B",
                number: "CS 2800",
                name: "Discrete Structures",
                description: "Logic, proof techniques, set theory, and graph theory."
            )
        ]
        let sampleSchedule = Schedule(
            term: "Fall 2025",
            rationale: "Prioritized core classes, then ranked electives, then grad‑level if eligible.",
            courses: sampleCourses
        )

        ScheduleView(schedule: sampleSchedule)
    }
}

// MARK: –– RoundedCorner extension for specific corners

fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

fileprivate struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
