import Foundation
import XCTest

// MARK: - Models

struct UserProfile: Sendable {
    let id: Int
    let name: String
    let email: String
}

struct Post: Sendable {
    let id: Int
    let title: String
    let content: String
}

struct NotificationItem: Sendable {
    let id: Int
    let message: String
    let isRead: Bool
}

struct UserDashboardData: Sendable {
    let profile: UserProfile
    let posts: [Post]
    let notifications: [NotificationItem]
    
    var metrics: [String: Int] {
        return [
            "postsCount": posts.count,
            "unreadNotificationsCount": notifications.filter { !$0.isRead }.count,
            "totalNotificationsCount": notifications.count
        ]
    }
}

// MARK: - Custom Errors

enum UserServiceError: Error, LocalizedError {
    case userNotFound
    case networkTimeout
    
    var errorDescription: String? {
        switch self {
        case .userNotFound: return "User not found"
        case .networkTimeout: return "Network timeout"
        }
    }
}

enum PostServiceError: Error, LocalizedError {
    case networkError
    case invalidResponse
    
    var errorDescription: String? {
        switch self {
        case .networkError: return "Network error while fetching posts"
        case .invalidResponse: return "Invalid response format"
        }
    }
}

enum NotificationServiceError: Error, LocalizedError {
    case noConnection
    case unauthorized
    
    var errorDescription: String? {
        switch self {
        case .noConnection: return "No network connection"
        case .unauthorized: return "Unauthorized access"
        }
    }
}

// MARK: - Services

protocol UserServiceProtocol: Sendable {
    func fetchUserProfile(userId: Int) async throws -> UserProfile
}

protocol PostServiceProtocol: Sendable {
    func fetchRecentPosts(userId: Int) async throws -> [Post]
}

protocol NotificationServiceProtocol: Sendable {
    func fetchUnreadNotifications(userId: Int) async throws -> [NotificationItem]
}

struct UserService: UserServiceProtocol, Sendable {
    func fetchUserProfile(userId: Int) async throws -> UserProfile {
        print("🔍 Fetching user profile for ID: \(userId)")
        
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        if Int.random(in: 1...20) == 1 {
            throw UserServiceError.userNotFound
        }
        
        print("✅ User profile fetched successfully")
        return UserProfile(
            id: userId,
            name: "Dor Luzgarten",
            email: "dorluzgarten@gmail.com"
        )
    }
}

struct PostService: PostServiceProtocol, Sendable {
    func fetchRecentPosts(userId: Int) async throws -> [Post] {
        print("📝 Fetching recent posts for user: \(userId)")
        
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        if Int.random(in: 1...33) == 1 {
            throw PostServiceError.networkError
        }
        
        print("✅ Posts fetched successfully")
        return [
            Post(id: 1, title: "Post 1", content: "Post 1 countent"),
            Post(id: 2, title: "Post 2", content: "Post 2 content"),
            Post(id: 3, title: "Post 3", content: "Post 3 content"),
        ]
    }
}

struct NotificationService: NotificationServiceProtocol, Sendable {
    func fetchUnreadNotifications(userId: Int) async throws -> [NotificationItem] {
        print("🔔 Fetching notifications for user: \(userId)")
        
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        if Int.random(in: 1...50) == 1 {
            throw NotificationServiceError.noConnection
        }
        
        print("✅ Notifications fetched successfully")
        return [
            NotificationItem(id: 1, message: "You have a new follower", isRead: false),
            NotificationItem(id: 2, message: "Someone liked your post", isRead: false),
            
        ]
    }
}

// MARK: - Dashboard Aggregator

struct UserDashboardAggregator: Sendable {
    private let userService: UserServiceProtocol
    private let postService: PostServiceProtocol
    private let notificationService: NotificationServiceProtocol
    
    init(
        userService: UserServiceProtocol = UserService(),
        postService: PostServiceProtocol = PostService(),
        notificationService: NotificationServiceProtocol = NotificationService()
    ) {
        self.userService = userService
        self.postService = postService
        self.notificationService = notificationService
    }
    
    func loadUserDashboardData(userId: Int) async throws -> UserDashboardData {
        print("🚀 Starting parallel data fetch for user: \(userId)")
        let startTime = Date()
        
        async let profile = userService.fetchUserProfile(userId: userId)
        async let posts = postService.fetchRecentPosts(userId: userId)
        async let notifications = notificationService.fetchUnreadNotifications(userId: userId)
        
        let (fetchedProfile, fetchedPosts, fetchedNotifications) = try await (profile, posts, notifications)
        
        let endTime = Date()
        let duration = endTime.timeIntervalSince(startTime)
        print("⏱️ Total fetch time: \(String(format: "%.2f", duration)) seconds")
        
        return UserDashboardData(
            profile: fetchedProfile,
            posts: fetchedPosts,
            notifications: fetchedNotifications
        )
    }
}

// MARK: - Main Execution

func runDashboardDemo() async {
    let aggregator = UserDashboardAggregator()
    
    do {
        print(String(repeating: "=", count: 50))
        print("🎯 User Dashboard Data Aggregation Demo")
        print(String(repeating: "=", count: 50))
        
        let dashboard = try await aggregator.loadUserDashboardData(userId: 123)
        
        print("\n📊 Dashboard Results:")
        print("👤 User: \(dashboard.profile.name) (\(dashboard.profile.email))")
        print("📝 Posts (\(dashboard.posts.count)):")
        for post in dashboard.posts {
            print("   • \(post.title)")
        }
        print("🔔 Notifications (\(dashboard.notifications.count)):")
        for notification in dashboard.notifications {
            let status = notification.isRead ? "📖" : "🆕"
            print("   \(status) \(notification.message)")
        }
        print("📈 Metrics: \(dashboard.metrics)")
        
    } catch {
        print("❌ Error loading dashboard: \(error.localizedDescription)")
    }
}

// MARK: - Unit Tests

class UserDashboardTests: XCTestCase {
    
    // Mock services for testing
    struct MockUserService: UserServiceProtocol {
        var shouldThrow = false
        
        func fetchUserProfile(userId: Int) async throws -> UserProfile {
            if shouldThrow {
                throw UserServiceError.userNotFound
            }
            return UserProfile(id: userId, name: "Test User", email: "test@example.com")
        }
    }
    
    struct MockPostService: PostServiceProtocol {
        var shouldThrow = false
        
        func fetchRecentPosts(userId: Int) async throws -> [Post] {
            if shouldThrow {
                throw PostServiceError.networkError
            }
            return [Post(id: 1, title: "Test Post", content: "Test content")]
        }
    }
    
    struct MockNotificationService: NotificationServiceProtocol {
        var shouldThrow = false
        
        func fetchUnreadNotifications(userId: Int) async throws -> [NotificationItem] {
            if shouldThrow {
                throw NotificationServiceError.noConnection
            }
            return [
                NotificationItem(id: 1, message: "Test notification", isRead: false),
                NotificationItem(id: 2, message: "Read notification", isRead: true)
            ]
        }
    }
    
    func testSuccessfulDataAggregation() async throws {
        let mockUserService = MockUserService()
        let mockPostService = MockPostService()
        let mockNotificationService = MockNotificationService()
        
        let aggregator = UserDashboardAggregator(
            userService: mockUserService,
            postService: mockPostService,
            notificationService: mockNotificationService
        )
        
        let dashboard = try await aggregator.loadUserDashboardData(userId: 1)
        
        XCTAssertEqual(dashboard.profile.id, 1)
        XCTAssertEqual(dashboard.profile.name, "Test User")
        XCTAssertEqual(dashboard.posts.count, 1)
        XCTAssertEqual(dashboard.notifications.count, 2)
        XCTAssertEqual(dashboard.metrics["postsCount"], 1)
        XCTAssertEqual(dashboard.metrics["unreadNotificationsCount"], 1)
        XCTAssertEqual(dashboard.metrics["totalNotificationsCount"], 2)
    }
    
    func testErrorHandling() async {
        var mockUserService = MockUserService()
        mockUserService.shouldThrow = true
        
        let aggregator = UserDashboardAggregator(
            userService: mockUserService,
            postService: MockPostService(),
            notificationService: MockNotificationService()
        )
        
        do {
            _ = try await aggregator.loadUserDashboardData(userId: 1)
            XCTFail("Should have thrown an error")
        } catch {
            XCTAssertTrue(error is UserServiceError)
        }
    }
}

// MARK: - Demo Execution

Task {
    await runDashboardDemo()
    
    print("\n" + String(repeating: "=", count: 50))
    print("🧪 Running Unit Tests")
    print(String(repeating: "=", count: 50))
    
    let tests = UserDashboardTests()
    
    do {
        try await tests.testSuccessfulDataAggregation()
        print("✅ testSuccessfulDataAggregation passed")
    } catch {
        print("❌ testSuccessfulDataAggregation failed: \(error)")
    }
    
    await tests.testErrorHandling()
    print("✅ testErrorHandling passed")
    
    print("\n🎉 Demo completed!")
}
