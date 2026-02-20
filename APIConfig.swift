//
//  APIConfig.swift
//  roomieverse-ios
//

import Foundation

struct APIConfig {
    // Firebase Configuration
    static let firebaseAPIKey = "AIzaSyB5XNQbA_hW8FhFUQq-mn29CmiEA15EGfU"
    static let firebaseAuthDomain = "roomieverse-antt.firebaseapp.com"
    static let firebaseProjectID = "roomieverse-antt"
    static let firebaseStorageBucket = "roomieverse-antt.firebasestorage.app"
    static let firebaseAppID = "1:YOUR_APP_ID:ios:YOUR_IOS_APP_ID" // Update with actual iOS app ID
    
    // Cloudflare R2 (Image CDN)
    static let r2PublicURL = "https://pub-fe2d599758ec4a498432d6c58ffe03b3.r2.dev"
    
    // API Base (if needed for custom endpoints)
    static let apiBaseURL = "https://roomieverse.vercel.app" // Production URL
    
    // Feature Flags
    static let moderationEnabled = true
    
    // Firestore Collections
    enum Collection {
        static let listings = "listings"
        static let users = "users"
        static let communityPosts = "community_posts"
        static let communityComments = "community_comments"
        static let communityLikes = "community_likes"
        static let favorites = "favorites"
        static let reports = "reports"
    }
}

// MARK: - API Models

enum ListingStatus: String, Codable {
    case active
    case pending
    case rejected
    case hidden
    case deleted
}

enum PostStatus: String, Codable {
    case active
    case pending
    case hidden
    case deleted
}

enum UserRole: String, Codable {
    case user
    case admin
}

// Extended RoomListing to match API schema
struct APIRoomListing: Codable, Identifiable {
    let id: String
    let title: String
    let author: String
    let price: String
    let location: String
    let city: String?
    let district: String?
    let specificAddress: String?
    let buildingName: String?
    let moveInDate: String
    let timeNegotiable: Bool?
    let description: String
    let introduction: String?
    let category: String // "roommate", "roomshare", "short-term", "sublease"
    let roommateType: String? // "have-room", "find-partner"
    let propertyTypes: [String]?
    let phone: String
    let zalo: String?
    let facebook: String?
    let instagram: String?
    let images: [String]?
    let amenities: [String]?
    let userId: String?
    let status: ListingStatus?
    let costs: RoomCosts?
    let preferences: APIRoommatePreferences?
    let roomSize: String?
    let currentOccupants: String?
    let totalRooms: String?
    let minContractDuration: String?
    let viewCount: Int?
    let favoriteCount: Int?
    let moderatedBy: String?
    let rejectionReason: String?
    let createdAt: String?
    let updatedAt: String?
}

struct RoomCosts: Codable {
    let rent: String?
    let deposit: String?
    let electricity: String?
    let water: String?
    let internet: String?
    let service: String?
    let parking: String?
    let management: String?
    let other: String?
}

struct APIRoommatePreferences: Codable {
    let gender: [String]?
    let status: [String]?
    let schedule: [String]?
    let cleanliness: [String]?
    let habits: [String]?
    let pets: [String]?
    let moveInTime: [String]?
    let other: String?
}

struct APIUserProfile: Codable {
    let uid: String
    let email: String
    let displayName: String
    let photoURL: String?
    let gender: String?
    let birthYear: String?
    let occupation: String?
    let lifestyle: LifestylePreferences?
    let role: UserRole?
    let createdAt: String?
    let updatedAt: String?
}

struct LifestylePreferences: Codable {
    let sleepSchedule: String?
    let cleanliness: String?
    let smoking: Bool?
    let pets: Bool?
    let cooking: Bool?
    let guests: String?
}

struct APICommunityPost: Codable, Identifiable {
    let id: String?
    let authorId: String
    let authorName: String
    let authorPhoto: String?
    let category: String // "tips", "drama", "review", "pass-do", "blog"
    let title: String
    let content: String
    let preview: String
    let likes: Int
    let comments: Int
    let views: Int
    let hot: Bool?
    let location: String?
    let rating: Int?
    let price: String?
    let images: [String]?
    let status: PostStatus
    let moderatedBy: String?
    let rejectionReason: String?
    let createdAt: String?
    let updatedAt: String?
}

struct APICommunityComment: Codable, Identifiable {
    let id: String?
    let postId: String
    let authorId: String
    let authorName: String
    let authorPhoto: String?
    let content: String
    let likes: Int
    let status: String // "active", "hidden", "deleted"
    let createdAt: String?
}

struct APIFavorite: Codable, Identifiable {
    let id: String?
    let userId: String
    let listingId: String
    let createdAt: String?
}

struct APIReport: Codable, Identifiable {
    let id: String?
    let listingId: String
    let reportedBy: String
    let reason: String
    let details: String?
    let status: String // "pending", "reviewed", "resolved"
    let reviewedBy: String?
    let createdAt: String?
    let reviewedAt: String?
}

// MARK: - API Response Wrappers

struct ImageUploadResponse: Codable {
    let url: String
    let key: String
}

struct AdminCheckResponse: Codable {
    let isAdmin: Bool
}

struct SeedResponse: Codable {
    let success: Bool
    let message: String
    let ids: [String]
}
