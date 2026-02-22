//
//  AuthenticationView.swift
//  roomieverse-ios
//
//  Wrapper that shows LoginView or MainTabView based on auth state
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var authService = AuthService.shared
    @StateObject private var appState = AppState()
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                MainTabView()
                    .environmentObject(appState)
                    .environmentObject(authService)
            } else {
                LoginView()
            }
        }
    }
}

#Preview {
    AuthenticationView()
}
