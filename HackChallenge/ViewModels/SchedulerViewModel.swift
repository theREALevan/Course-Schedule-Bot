import SwiftUI
import Combine

class SchedulerViewModel: ObservableObject {
    @Published var netid = ""
    @Published var graduationDate = Date()
    @Published var yearSelection = "Freshman"
    let yearOptions = ["Freshman", "Sophomore", "Junior", "Senior"]

    // Availability: 7 days × 12 hours
    @Published var availability =
        Array(repeating: Array(repeating: true, count: 12), count: 7)

    @Published var interest = ""
    @Published var previousCourses = ""
    @Published var recommended: Schedule?

    func submit() {
        let year = Calendar.current.component(.year, from: graduationDate)
        let gradYear = String(year)

        APIService.shared.createUser(
            netid: netid,
            graduationYear: gradYear,
            interests: interest,
            availability: matrixToString(availability)
        ) { [weak self] result in
            switch result {
            case .success(let userResp):
                self?.generate(userId: userResp.id)
            case .failure(let err):
                print("User creation error:", err)
            }
        }
    }

    private func generate(userId: Int) {
        APIService.shared.generateSchedule(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let sched):
                    let courses = sched.sections.map { sec in
                        Course(
                            id: "\(sec.courseNumber)-\(sec.section)",
                            title: sec.courseNumber,
                            description: "\(sec.days) \(sec.startMin ?? 0)–\(sec.endMin ?? 0)"
                        )
                    }
                    self?.recommended = Schedule(term: "Fall 2025", courses: courses)
                case .failure(let err):
                    print("Schedule generation error:", err)
                }
            }
        }
    }

    private func matrixToString(_ m: [[Bool]]) -> String {
        m.flatMap { $0 }.map { $0 ? "1" : "0" }.joined()
    }
}
