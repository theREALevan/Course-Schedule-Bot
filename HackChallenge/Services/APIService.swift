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
        let payload = CreateUserRequest(netid: netid,
                                        graduationYear: graduationYear,
                                        interests: interests,
                                        availability: availability)
        do { req.httpBody = try encoder.encode(payload) }
        catch { return completion(.failure(error)) }

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "CreateUser", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "CreateUser",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(UserResponse.self, from: d))) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    public func fetchAllUsers(
        completion: @escaping (Result<[UserResponse], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "FetchAllUsers", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "FetchAllUsers",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(UsersListResponse.self, from: d).users)) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    public func fetchUser(
        id: Int,
        completion: @escaping (Result<UserResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(id)")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "FetchUser", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "FetchUser",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(UserResponse.self, from: d))) }
            catch { completion(.failure(error)) }
        }.resume()
    }

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
        let payload = UpdateUserRequest(graduationYear: graduationYear,
                                        interests: interests,
                                        availability: availability)
        do { req.httpBody = try encoder.encode(payload) }
        catch { return completion(.failure(error)) }

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "UpdateUser", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "UpdateUser",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(UserResponse.self, from: d))) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    // MARK: –– Completed Courses

    public func fetchCompletedCourses(
        userId: Int,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(userId)/completions")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "FetchCompletedCourses", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "FetchCompletedCourses",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(CompletedCoursesResponse.self, from: d).completedCourses)) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    public func addCompletedCourse(
        userId: Int,
        courseNumber: String,
        completion: @escaping (Result<AddCompletionResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(userId)/completions")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["course_number": courseNumber]
        do { req.httpBody = try encoder.encode(body) }
        catch { return completion(.failure(error)) }

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "AddCompletedCourse", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "AddCompletedCourse",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(AddCompletionResponse.self, from: d))) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    // MARK: –– Core Courses

    public func fetchCoreCourses(
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("core-sets")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "FetchCoreCourses", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "FetchCoreCourses",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(CoreCoursesResponse.self, from: d).courses)) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    // MARK: –– Courses

    public func fetchAllCourses(
        completion: @escaping (Result<[CourseDTO], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("courses")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "FetchAllCourses", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "FetchAllCourses",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(CoursesResponse.self, from: d).courses)) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    public func fetchCourse(
        number: String,
        completion: @escaping (Result<CourseDTO, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("courses/\(number)")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "FetchCourse", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "FetchCourse",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(CourseDTO.self, from: d))) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    // MARK: –– Schedule

    public func generateSchedule(
        userId: Int,
        completion: @escaping (Result<ScheduleResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("schedules/generate")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["user_id": userId]
        do { req.httpBody = try encoder.encode(body) }
        catch { return completion(.failure(error)) }

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "GenerateSchedule", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "GenerateSchedule",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(ScheduleResponse.self, from: d))) }
            catch { completion(.failure(error)) }
        }.resume()
    }

    public func fetchSchedules(
        userId: Int,
        completion: @escaping (Result<[ScheduleInfoDTO], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("schedules/\(userId)")
        var req = URLRequest(url: url)
        req.httpMethod = "GET"

        URLSession.shared.dataTask(with: req) { data, resp, err in
            if let e = err { return completion(.failure(e)) }
            guard let http = resp as? HTTPURLResponse, let d = data else {
                return completion(.failure(NSError(domain: "FetchSchedules", code: 0)))
            }
            guard (200...299).contains(http.statusCode) else {
                let body = String(data: d, encoding: .utf8) ?? ""
                return completion(.failure(NSError(
                    domain: "FetchSchedules",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(body)"]
                )))
            }
            do { completion(.success(try self.decoder.decode(SchedulesListResponse.self, from: d).schedules)) }
            catch { completion(.failure(error)) }
        }.resume()
    }
}
