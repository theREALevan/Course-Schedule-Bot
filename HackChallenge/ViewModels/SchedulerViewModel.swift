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
          guard case .success(let schedResponse) = result else { return }
          let rationale = schedResponse.rationale
          let sections  = schedResponse.sections

          APIService.shared.fetchAllCourses { courseResult in
            DispatchQueue.main.async {
              // 1) Build a normalized catalog:
              var catalog: [String: CourseDTO] = [:]
              if case .success(let all) = courseResult {
                catalog = Dictionary(
                  uniqueKeysWithValues: all.map { dto in
                    let key = dto.number
                      .trimmingCharacters(in: .whitespacesAndNewlines)
                      .lowercased()
                    return (key, dto)
                  }
                )
              }

              // Debug print to verify matching
              print("📚 catalog has \(catalog.count) entries")
              for sec in sections {
                let raw = sec.courseNumber
                let norm = raw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                print("  looking up “\(raw)” → “\(norm)” →",
                      catalog[norm] != nil ? "FOUND" : "nil")
              }

              // 2) Map sections into Course, using the normalized lookup:
              let courses = sections.map { sec -> Course in
                let lookupKey = sec.courseNumber
                  .trimmingCharacters(in: .whitespacesAndNewlines)
                  .lowercased()

                if let dto = catalog[lookupKey] {
                  return Course(
                    id: "\(dto.number)-\(sec.section)",
                    number: dto.number,
                    name: dto.name,
                    description: dto.description
                  )
                } else {
                  // fallback if still missing
                  return Course(
                    id: "\(sec.courseNumber)-\(sec.section)",
                    number: sec.courseNumber,
                    name: sec.courseNumber,
                    description: "\(sec.days) \(sec.startMin ?? 0)–\(sec.endMin ?? 0)"
                  )
                }
              }

              // 3) Debug-print your final schedule before publishing
              print("🗓️ Final mapped courses:")
              for c in courses {
                print("  • \(c.number): \(c.name) — \(c.description ?? "")")
              }

              // 4) Publish
              self?.recommended = Schedule(
                term: "Fall 2025",
                rationale: rationale,
                courses: courses
              )
            }
          }
        }
      }
    }


}
