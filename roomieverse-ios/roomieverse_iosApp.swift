//
//  roomieverse_iosApp.swift
//  roomieverse-ios
//

import SwiftUI

@main
struct roomieverse_iosApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .environmentObject(appState)
        }
    }
}
