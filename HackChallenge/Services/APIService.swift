// APIService.swift

import Foundation

public final class APIService {
    public static let shared = APIService()
    private let baseURL = URL(string: "http://35.245.67.146")!

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        return d
    }()

    private let encoder: JSONEncoder = {
        let e = JSONEncoder()
        e.keyEncodingStrategy = .convertToSnakeCase
        return e
    }()

    // MARK: –– Users

    /// Create a new user
    public func createUser(
        netid: String,
        graduationYear: String,
        interests: String?,
        availability: String,
        completion: @escaping (Result<UserResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = CreateUserRequest(
            netid: netid,
            graduationYear: graduationYear,
            interests: interests,
            availability: availability
        )
        do {
            req.httpBody = try encoder.encode(payload)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "CreateUser", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "CreateUser", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let user = try self.decoder.decode(UserResponse.self, from: d)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Fetch all users
    public func fetchAllUsers(
        completion: @escaping (Result<[UserResponse], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "FetchAllUsers", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "FetchAllUsers", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let respObj = try self.decoder.decode(UsersListResponse.self, from: d)
                completion(.success(respObj.users))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Fetch a single user by ID
    public func fetchUser(
        id: Int,
        completion: @escaping (Result<UserResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(id)")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "FetchUser", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "FetchUser", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let user = try self.decoder.decode(UserResponse.self, from: d)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Update an existing user’s profile
    public func updateUser(
        id: Int,
        graduationYear: String,
        interests: String?,
        availability: String,
        completion: @escaping (Result<UserResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(id)")
        var req = URLRequest(url: url)
        req.httpMethod = "PATCH"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = CreateUserRequest(
            netid: "",
            graduationYear: graduationYear,
            interests: interests,
            availability: availability
        )
        do {
            req.httpBody = try encoder.encode(payload)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "UpdateUser", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "UpdateUser", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let user = try self.decoder.decode(UserResponse.self, from: d)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: –– Completed Courses

    /// Fetch completed courses for a user
    public func fetchCompletedCourses(
        userId: Int,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(userId)/completions")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "FetchCompletedCourses", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "FetchCompletedCourses", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let respObj = try self.decoder.decode(CompletedCoursesResponse.self, from: d)
                completion(.success(respObj.completedCourses))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Add a completed course for a user
    public func addCompletedCourse(
        userId: Int,
        courseNumber: String,
        completion: @escaping (Result<AddCompletionResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(userId)/completions")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyDict = ["course_number": courseNumber]
        do {
            req.httpBody = try encoder.encode(bodyDict)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "AddCompletedCourse", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "AddCompletedCourse", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let respObj = try self.decoder.decode(AddCompletionResponse.self, from: d)
                completion(.success(respObj))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: –– Core Courses

    /// Fetch core course numbers
    public func fetchCoreCourses(
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("core-sets")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "FetchCoreCourses", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "FetchCoreCourses", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let respObj = try self.decoder.decode(CoreCoursesResponse.self, from: d)
                completion(.success(respObj.courses))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: –– Courses

    /// Fetch all courses
    public func fetchAllCourses(
        completion: @escaping (Result<[CourseDTO], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("courses")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "FetchAllCourses", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "FetchAllCourses", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let respObj = try self.decoder.decode(CoursesResponse.self, from: d)
                completion(.success(respObj.courses))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Fetch a single course
    public func fetchCourse(
        number: String,
        completion: @escaping (Result<CourseDTO, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("courses/\(number)")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "FetchCourse", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "FetchCourse", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let course = try self.decoder.decode(CourseDTO.self, from: d)
                completion(.success(course))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    // MARK: –– Schedule

    /// Generate a schedule for a user
    public func generateSchedule(
        userId: Int,
        completion: @escaping (Result<ScheduleResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("schedules/generate")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let bodyDict = ["user_id": userId]
        do {
            req.httpBody = try encoder.encode(bodyDict)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "GenerateSchedule", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "GenerateSchedule", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let sched = try self.decoder.decode(ScheduleResponse.self, from: d)
                completion(.success(sched))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    /// Fetch all generated schedules for a user
    public func fetchSchedules(
        userId: Int,
        completion: @escaping (Result<[ScheduleInfoDTO], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("schedules/\(userId)")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, error in
            if let e = error { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                let err = NSError(domain: "FetchSchedules", code: 0,
                                  userInfo: [NSLocalizedDescriptionKey: "No response"])
                return completion(.failure(err))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                let err = NSError(domain: "FetchSchedules", code: http.statusCode,
                                  userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"])
                return completion(.failure(err))
            }
            do {
                let respObj = try self.decoder.decode(SchedulesListResponse.self, from: d)
                completion(.success(respObj.schedules))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
