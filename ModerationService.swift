//
//  ModerationService.swift
//  roomieverse-ios
//
//  Service for content moderation (admin/mod/tester only)
//

import Foundation
import Combine

class ModerationService: ObservableObject {
    static let shared = ModerationService()
    
    @Published var pendingListings: [RoomListing] = []
    @Published var pendingPosts: [CommunityPost] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firestore = FirestoreService.shared
    private let auth = AuthService.shared
    
    private init() {}
    
    // MARK: - Listing Moderation
    
    func fetchPendingListings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let apiListings = try await firestore.fetchListings(
                category: nil,
                status: .pending
            )
            
            await MainActor.run {
                // Convert to app models using ListingService converter
                self.pendingListings = apiListings.compactMap { 
                    ListingService.shared.convertToAppModel($0)
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func approveListing(_ listingId: String) async throws {
        guard let adminUid = auth.currentUser?.uid else {
            throw NSError(domain: "Auth", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Not authenticated"
            ])
        }
        
        // Real implementation:
        // let db = Firestore.firestore()
        // try await db.collection(APIConfig.Collection.listings).document(listingId).updateData([
        //     "status": ListingStatus.active.rawValue,
        //     "moderatedBy": adminUid,
        //     "moderatedAt": FieldValue.serverTimestamp()
        // ])
        
        // Remove from pending list
        await MainActor.run {
            pendingListings.removeAll { $0.id == listingId }
        }
    }
    
    func rejectListing(_ listingId: String, reason: String, note: String? = nil) async throws {
        guard let adminUid = auth.currentUser?.uid else {
            throw NSError(domain: "Auth", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Not authenticated"
            ])
        }
        
        // Real implementation:
        // let db = Firestore.firestore()
        // var updateData: [String: Any] = [
        //     "status": ListingStatus.rejected.rawValue,
        //     "moderatedBy": adminUid,
        //     "moderatedAt": FieldValue.serverTimestamp(),
        //     "rejectionReason": reason
        // ]
        // if let note = note {
        //     updateData["moderationNote"] = note
        // }
        // try await db.collection(APIConfig.Collection.listings).document(listingId).updateData(updateData)
        
        // Remove from pending list
        await MainActor.run {
            pendingListings.removeAll { $0.id == listingId }
        }
    }
    
    func fetchRejectedListings() async throws -> [RoomListing] {
        let apiListings = try await firestore.fetchListings(
            category: nil,
            status: .rejected
        )
        
        return apiListings.compactMap { ListingService.shared.convertToAppModel($0) }
    }
    
    // MARK: - Community Post Moderation
    
    func fetchPendingPosts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let apiPosts = try await firestore.fetchCommunityPosts(
                category: nil,
                hot: nil
            )
            
            // Filter for pending status
            let pending = apiPosts.filter { $0.status == .pending }
            
            await MainActor.run {
                self.pendingPosts = pending.compactMap {
                    CommunityService.shared.convertToAppModel($0)
                }
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    func approveCommunityPost(_ postId: String) async throws {
        guard let adminUid = auth.currentUser?.uid else {
            throw NSError(domain: "Auth", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Not authenticated"
            ])
        }
        
        // Real implementation:
        // let db = Firestore.firestore()
        // try await db.collection(APIConfig.Collection.communityPosts).document(postId).updateData([
        //     "status": PostStatus.active.rawValue,
        //     "moderatedBy": adminUid
        // ])
        
        await MainActor.run {
            pendingPosts.removeAll { $0.id == postId }
        }
    }
    
    func rejectCommunityPost(_ postId: String, reason: String) async throws {
        guard let adminUid = auth.currentUser?.uid else {
            throw NSError(domain: "Auth", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Not authenticated"
            ])
        }
        
        // Real implementation:
        // let db = Firestore.firestore()
        // try await db.collection(APIConfig.Collection.communityPosts).document(postId).updateData([
        //     "status": PostStatus.rejected.rawValue,
        //     "moderatedBy": adminUid,
        //     "rejectionReason": reason
        // ])
        
        await MainActor.run {
            pendingPosts.removeAll { $0.id == postId }
        }
    }
    
    func hardDeleteCommunityPost(_ postId: String) async throws {
        guard auth.currentUser?.role == .admin else {
            throw NSError(domain: "Auth", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Only admins can permanently delete posts"
            ])
        }
        
        // Real implementation:
        // let db = Firestore.firestore()
        // try await db.collection(APIConfig.Collection.communityPosts).document(postId).delete()
        
        await MainActor.run {
            pendingPosts.removeAll { $0.id == postId }
        }
    }
    
    // MARK: - Statistics
    
    func getModerationStats() async throws -> ModerationStats {
        // Real implementation would fetch counts from Firestore
        // For now, return based on loaded data
        
        return ModerationStats(
            pendingListings: pendingListings.count,
            pendingPosts: pendingPosts.count,
            rejectedListings: 0,
            totalReports: 0
        )
    }
}

// MARK: - Models

struct ModerationStats {
    let pendingListings: Int
    let pendingPosts: Int
    let rejectedListings: Int
    let totalReports: Int
}


