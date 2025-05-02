// APIService.swift

import Foundation

public final class APIService {
    public static let shared = APIService()
    private let baseURL = URL(string: "http://35.245.67.146/")!

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
        let url = baseURL.appendingPathComponent("users/")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let payload = CreateUserRequest(
            netid: netid,
            graduationYear: graduationYear,
            interests: interests,
            availability: availability
        )
        do { req.httpBody = try encoder.encode(payload) }
        catch { return completion(.failure(error)) }

        let task = URLSession.shared.dataTask(with: req) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let user = try self.decoder.decode(UserResponse.self, from: d)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    public func fetchAllUsers(
        completion: @escaping (Result<[UserResponse], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/")
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let resp = try self.decoder.decode(UsersListResponse.self, from: d)
                completion(.success(resp.users))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    public func fetchUser(
        id: Int,
        completion: @escaping (Result<UserResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(id)/")
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let user = try self.decoder.decode(UserResponse.self, from: d)
                completion(.success(user))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: –– Completed Courses

    public func fetchCompletedCourses(
        userId: Int,
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(userId)/completions/")
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let resp = try self.decoder.decode(CompletedCoursesResponse.self, from: d)
                completion(.success(resp.completedCourses))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    public func addCompletedCourse(
        userId: Int,
        courseNumber: String,
        completion: @escaping (Result<AddCompletionResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("users/\(userId)/completions/")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["course_number": courseNumber]
        do { req.httpBody = try encoder.encode(body) }
        catch { return completion(.failure(error)) }

        let task = URLSession.shared.dataTask(with: req) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let resp = try self.decoder.decode(AddCompletionResponse.self, from: d)
                completion(.success(resp))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: –– Core Courses

    public func fetchCoreCourses(
        completion: @escaping (Result<[String], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("core-sets/")
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let resp = try self.decoder.decode(CoreCoursesResponse.self, from: d)
                completion(.success(resp.courses))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: –– Courses

    public func fetchAllCourses(
        completion: @escaping (Result<[CourseDTO], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("courses/")
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let resp = try self.decoder.decode(CoursesResponse.self, from: d)
                completion(.success(resp.courses))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    public func fetchCourse(
        number: String,
        completion: @escaping (Result<CourseDTO, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("courses/\(number)/")
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let course = try self.decoder.decode(CourseDTO.self, from: d)
                completion(.success(course))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    // MARK: –– Schedule

    public func generateSchedule(
        userId: Int,
        completion: @escaping (Result<ScheduleResponse, Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("schedules/generate/")
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let body = ["user_id": userId]
        do { req.httpBody = try encoder.encode(body) }
        catch { return completion(.failure(error)) }

        let task = URLSession.shared.dataTask(with: req) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let sched = try self.decoder.decode(ScheduleResponse.self, from: d)
                completion(.success(sched))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }

    public func fetchSchedules(
        userId: Int,
        completion: @escaping (Result<[ScheduleInfoDTO], Error>) -> Void
    ) {
        let url = baseURL.appendingPathComponent("schedules/\(userId)/")
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            if let e = error { return completion(.failure(e)) }
            guard let d = data else { return completion(.failure(NSError())) }
            do {
                let resp = try self.decoder.decode(SchedulesListResponse.self, from: d)
                completion(.success(resp.schedules))
            } catch {
                completion(.failure(error))
            }
        }
        task.resume()
    }
}
