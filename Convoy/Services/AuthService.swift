import Foundation
import SwiftData

// MARK: - Auth Error

enum AuthError: LocalizedError {
    case invalidCredentials
    case userNotFound
    case sessionExpired
    case registrationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Incorrect username or password entered."
        case .userNotFound:
            return "No Convoy account found matching these details."
        case .sessionExpired:
            return "Your session has expired. Please sign in again."
        case .registrationFailed(let reason):
            return "Registration failed: \(reason)"
        }
    }
}

// MARK: - Auth Service Protocol

@MainActor
protocol AuthServiceProtocol: AnyObject {
    var isAuthenticated: Bool { get }
    var currentUser: User? { get }
    
    func signIn(username: String) async throws -> User
    func signUp(name: String, username: String, email: String, experience: RidingExperience) async throws -> User
    func signOut() async
    func restoreSession(from context: ModelContext) -> User?
}

// MARK: - Auth Service Implementation

@MainActor
final class AuthService: AuthServiceProtocol {
    static let shared = AuthService()
    
    private(set) var isAuthenticated: Bool = false
    private(set) var currentUser: User?
    
    private let userDefaultsKey = "convoy.authenticated.userId"
    
    init() {}
    
    func signIn(username: String) async throws -> User {
        // Simulated network delay
        try await Task.sleep(nanoseconds: 150_000_000)
        
        let user = User(
            name: username.capitalized,
            username: username.lowercased(),
            email: "\(username.lowercased())@convoy.app",
            ridingExperience: .intermediate
        )
        
        self.currentUser = user
        self.isAuthenticated = true
        UserDefaults.standard.set(user.id.uuidString, forKey: userDefaultsKey)
        return user
    }
    
    func signUp(name: String, username: String, email: String, experience: RidingExperience) async throws -> User {
        try await Task.sleep(nanoseconds: 150_000_000)
        
        let user = User(
            name: name,
            username: username.lowercased(),
            email: email,
            ridingExperience: experience
        )
        
        self.currentUser = user
        self.isAuthenticated = true
        UserDefaults.standard.set(user.id.uuidString, forKey: userDefaultsKey)
        return user
    }
    
    func signOut() async {
        self.isAuthenticated = false
        self.currentUser = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
    
    func restoreSession(from context: ModelContext) -> User? {
        guard let savedIdString = UserDefaults.standard.string(forKey: userDefaultsKey),
              let uuid = UUID(uuidString: savedIdString) else {
            return nil
        }
        
        var descriptor = FetchDescriptor<User>(predicate: #Predicate { $0.id == uuid })
        descriptor.fetchLimit = 1
        
        if let existing = try? context.fetch(descriptor).first {
            self.currentUser = existing
            self.isAuthenticated = true
            return existing
        }
        return nil
    }
}
