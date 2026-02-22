//
//  Models.swift
//  roomieverse-ios
//

import Foundation
import SwiftUI
import Combine

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default: (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(.sRGB, red: Double(r)/255, green: Double(g)/255, blue: Double(b)/255, opacity: Double(a)/255)
    }
}

// MARK: - Brand Colors

extension Color {
    // Category colors matching web app
    static let roommateColor   = Color(hex: "#60A5FA") // blue-400
    static let roomshareColor  = Color(hex: "#F472B6") // pink-400
    static let shortTermColor  = Color(hex: "#FBBF24") // amber-400
    static let subleaseColor   = Color(hex: "#34D399") // emerald-400

    // Community colors
    static let communityTips   = Color(hex: "#EAB308") // yellow-500
    static let communityDrama  = Color(hex: "#EF4444") // red-500
    static let communityReview = Color(hex: "#6366F1") // indigo-500
    static let communityPassDo = Color(hex: "#22C55E") // green-500
    static let communityBlog   = Color(hex: "#A855F7") // purple-500

    // Brand pink (logo color)
    static let brandPink = Color(hex: "#F9A8D4") // pink-300
}

// MARK: - Listing Category

enum ListingCategory: String, CaseIterable, Codable {
    case roommate = "roommate"
    case roomshare = "roomshare"
    case shortTerm = "short-term"
    case sublease = "sublease"

    var displayName: String {
        switch self {
        case .roommate: return "Tìm bạn cùng phòng"
        case .roomshare: return "Phòng trọ"
        case .shortTerm: return "Ngắn hạn"
        case .sublease: return "Sang nhượng"
        }
    }

    var color: Color {
        switch self {
        case .roommate:  return .roommateColor
        case .roomshare: return .roomshareColor
        case .shortTerm: return .shortTermColor
        case .sublease:  return .subleaseColor
        }
    }

    var icon: String {
        switch self {
        case .roommate: return "person.2.fill"
        case .roomshare: return "house.fill"
        case .shortTerm: return "clock.fill"
        case .sublease: return "key.fill"
        }
    }
}

// MARK: - Roommate Type

enum RoommateType: String, Codable {
    case haveRoom = "have-room"
    case findPartner = "find-partner"

    var displayName: String {
        switch self {
        case .haveRoom: return "Có phòng trống"
        case .findPartner: return "Tìm phòng ghép"
        }
    }
}

// MARK: - Room Listing

struct RoomListing: Identifiable {
    let id: String
    var title: String
    var authorId: String?
    var authorName: String
    var authorAvatar: String
    var category: ListingCategory
    var roommateType: RoommateType?
    var price: Int
    var location: String
    var district: String
    var city: String
    var moveInDate: String
    var description: String
    var introduction: String?
    var images: [String]?
    var amenities: [String]
    var phone: String
    var zalo: String?
    var facebook: String?
    var roomSize: String?
    var currentOccupants: String?
    var status: ListingStatus
    var viewCount: Int
    var favoriteCount: Int
    var createdAt: Date
    var isFeatured: Bool

    // Roommate preferences
    var preferredGender: String?
    var preferredStatus: String?
    var schedule: String?
    var cleanliness: String?
    var habits: [String]
    var pets: String?
}

// MARK: - Community Post Category

enum CommunityCategory: String, CaseIterable {
    case tips, drama, review
    case passDo = "pass-do"
    case blog

    var displayName: String {
        switch self {
        case .tips: return "Tips"
        case .drama: return "Drama"
        case .review: return "Review"
        case .passDo: return "Pass đồ"
        case .blog: return "Blog"
        }
    }

    var color: Color {
        switch self {
        case .tips:   return .communityTips
        case .drama:  return .communityDrama
        case .review: return .communityReview
        case .passDo: return .communityPassDo
        case .blog:   return .communityBlog
        }
    }

    var icon: String {
        switch self {
        case .tips: return "lightbulb.fill"
        case .drama: return "flame.fill"
        case .review: return "star.fill"
        case .passDo: return "arrow.triangle.2.circlepath"
        case .blog: return "doc.text.fill"
        }
    }
}

// MARK: - Community Post

struct CommunityPost: Identifiable {
    let id: String
    var authorId: String
    var authorName: String
    var authorAvatar: String
    var category: CommunityCategory
    var title: String
    var preview: String
    var content: String
    var images: [String]?
    var likes: Int
    var comments: Int
    var views: Int
    var isHot: Bool
    var createdAt: Date
}

// MARK: - App Tab

enum AppTab: Int, Hashable {
    case home = 0
    case search = 1
    case community = 2
    case profile = 3
    case post = 4
}

// MARK: - App State

class AppState: ObservableObject {
    @Published var favoriteListingIds: Set<String> = []
    @Published var selectedTab: AppTab = .home
    
    private let listingService = ListingService.shared
    private let authService = AuthService.shared

    func toggleFavorite(listingId: String) {
        let wasFavorite = favoriteListingIds.contains(listingId)
        
        if wasFavorite {
            favoriteListingIds.remove(listingId)
        } else {
            favoriteListingIds.insert(listingId)
        }
        
        // Sync with Firebase
        Task {
            guard let userId = authService.currentUser?.uid else { return }
            
            do {
                if wasFavorite {
                    try await listingService.removeFavorite(userId: userId, listingId: listingId)
                } else {
                    try await listingService.addFavorite(userId: userId, listingId: listingId)
                }
            } catch {
                // Revert on error
                await MainActor.run {
                    if wasFavorite {
                        self.favoriteListingIds.insert(listingId)
                    } else {
                        self.favoriteListingIds.remove(listingId)
                    }
                }
            }
        }
    }

    func isFavorite(listingId: String) -> Bool {
        favoriteListingIds.contains(listingId)
    }
    
    func loadFavorites() {
        Task {
            guard let userId = authService.currentUser?.uid else { return }
            
            let favorites = await listingService.fetchUserFavorites(userId: userId)
            
            await MainActor.run {
                self.favoriteListingIds = Set(favorites.map { $0.id })
            }
        }
    }
}
