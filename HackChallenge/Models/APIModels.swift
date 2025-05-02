// Models.swift

import Foundation

// MARK: –– Course DTOs

public struct CourseDTO: Codable {
    public let number: String
    public let name: String
    public let description: String?
    public let credits: Int
    public let sections: [CourseSectionDTO]
    public let prereqs: [PrereqDTO]
    public let requiredBy: [RequiredByDTO]
}

public struct CourseSectionDTO: Codable {
    public let id: Int
    public let courseNumber: String
    public let section: String
    public let days: String
    public let startMin: Int?
    public let endMin: Int?
}

public struct PrereqDTO: Codable {
    public let prereqNumber: String
}

public struct RequiredByDTO: Codable {
    public let courseNumber: String
}

public struct CoursesResponse: Codable {
    public let courses: [CourseDTO]
}

// MARK: –– Core Courses

public struct CoreCoursesResponse: Codable {
    public let courses: [String]
}

// MARK: –– User DTOs

/// POST /users/ request body
public struct CreateUserRequest: Codable {
    public let netid: String
    public let graduationYear: String    // now a String
    public let interests: String?
    public let availability: String
}

/// Response for POST /users/ and GET /users/{id}/
public struct UserResponse: Codable {
    public let id: Int
    public let netid: String
    public let graduationYear: String   // now a String
    public let interests: String?
    public let availability: String
}

public struct UsersListResponse: Codable {
    let users: [UserResponse]
}

// MARK: –– Completed Courses

public struct CompletedCoursesResponse: Codable {
    public let completedCourses: [String]
}

public struct AddCompletionResponse: Codable {
    public let courseNumber: String
    public let userId: Int
}

// MARK: –– Schedule DTOs

public struct ScheduleResponse: Codable {
    public let id: Int
    public let userId: Int
    public let score: Double
    public let rationale: String
    public let sections: [CourseSectionDTO]
}

public struct ScheduleInfoDTO: Codable {
    public let id: Int
    public let userId: Int
    public let rationale: String
}

public struct SchedulesListResponse: Codable {
    public let schedules: [ScheduleInfoDTO]
}
