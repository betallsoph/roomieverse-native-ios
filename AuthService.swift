//
//  AuthService.swift
//  roomieverse-ios
//
//  Authentication service for Google Sign-In and user management
//

import Foundation
import Combine
import SwiftUI

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: APIUserProfile?
    @Published var isAuthenticated = false
    @Published var isAdmin = false
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let firebaseManager = FirebaseManager.shared
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Subscribe to Firebase auth state changes
        firebaseManager.$currentUser
            .sink { [weak self] user in
                self?.currentUser = user
                self?.isAuthenticated = user != nil
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Sign In
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let user = try await firebaseManager.signInWithGoogle()
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                self.isLoading = false
            }
            
            // Check admin status
            await checkAdminStatus()
            
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        do {
            try firebaseManager.signOut()
            currentUser = nil
            isAuthenticated = false
            isAdmin = false
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Admin Check
    
    func checkAdminStatus() async {
        guard isAuthenticated else {
            isAdmin = false
            return
        }
        
        do {
            let adminStatus = try await firebaseManager.checkAdminStatus()
            await MainActor.run {
                self.isAdmin = adminStatus
            }
        } catch {
            await MainActor.run {
                self.isAdmin = false
            }
        }
    }
    
    // MARK: - User Profile
    
    func fetchUserProfile() async {
        guard let userId = currentUser?.uid else { return }
        
        do {
            let profile = try await firebaseManager.fetchUserProfile(userId: userId)
            await MainActor.run {
                self.currentUser = profile
                self.isAdmin = profile.role == .admin
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
    
    func updateUserProfile(
        displayName: String? = nil,
        gender: String? = nil,
        birthYear: String? = nil,
        occupation: String? = nil,
        lifestyle: LifestylePreferences? = nil
    ) async throws {
        guard var user = currentUser else {
            throw NSError(domain: "Auth", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "No user logged in"
            ])
        }
        
        // Apply updates
        if let displayName = displayName {
            user = APIUserProfile(
                uid: user.uid,
                email: user.email,
                displayName: displayName,
                photoURL: user.photoURL,
                gender: gender ?? user.gender,
                birthYear: birthYear ?? user.birthYear,
                occupation: occupation ?? user.occupation,
                lifestyle: lifestyle ?? user.lifestyle,
                role: user.role,
                createdAt: user.createdAt,
                updatedAt: ISO8601DateFormatter().string(from: Date())
            )
        }
        
        try await firebaseManager.updateUserProfile(user)
        
        await MainActor.run {
            self.currentUser = user
        }
    }
    
    // MARK: - Token Management
    
    func getIdToken() async throws -> String {
        return try await firebaseManager.getCurrentUserToken()
    }
}

// MARK: - Auth View Models

extension AuthService {
    var isSignedIn: Bool {
        isAuthenticated && currentUser != nil
    }
    
    var userDisplayName: String {
        currentUser?.displayName ?? "User"
    }
    
    var userEmail: String {
        currentUser?.email ?? ""
    }
    
    var userPhotoURL: String? {
        currentUser?.photoURL
    }
}
