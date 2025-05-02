import Foundation
import Combine

class SchedulerViewModel: ObservableObject {
    @Published var graduationDate = Date()
    @Published var yearSelection = "Freshman"
    let yearOptions = ["Freshman", "Sophomore", "Junior", "Senior"]

    @Published var availability = Array(repeating: Array(repeating: true, count: 12), count: 7)
    @Published var interest = ""
    @Published var previousCourses = ""
    @Published var recommended: Schedule?

    /// Called from InputFormView once the user is logged in.
    func submit(userId: Int) {
        generate(userId: userId)
    }

    private func generate(userId: Int) {
        APIService.shared.generateSchedule(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let sched) = result {
                    let courses = sched.sections.map { sec in
                        Course(
                            id: "\(sec.courseNumber)-\(sec.section)",
                            title: sec.courseNumber,
                            description: "\(sec.days) \(sec.startMin ?? 0)–\(sec.endMin ?? 0)"
                        )
                    }
                    self?.recommended = Schedule(term: "Fall 2025", courses: courses)
                }
            }
        }
    }
}
