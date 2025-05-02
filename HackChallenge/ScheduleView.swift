//  ScheduleView.swift
//  HackChallenge
//  Created by Zhang Yiwen Evan on 2025/5/2.

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
            // Full‑screen gradient
            fullGradient
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Title bar
                VStack(spacing: 4) {
                    Text("🗓️ Your Schedule")
                        .font(.system(size: 34, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                    Text(schedule.term)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.top, 60)
                .padding(.bottom, 20)
                .frame(maxWidth: .infinity)

                // Content sheet
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(schedule.courses) { course in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(course.title)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Text(course.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
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
                // constrain to its content and align to top
                .frame(maxHeight: .infinity, alignment: .top)
                // remove edgesIgnoringSafeArea so it stops above the bottom safe area
            }
        }
        .navigationBarHidden(true)
    }
}

// CornerRadius extension for specific corners

fileprivate extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
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
