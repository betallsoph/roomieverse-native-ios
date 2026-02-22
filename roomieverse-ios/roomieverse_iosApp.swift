//
//  roomieverse_iosApp.swift
//  roomieverse-ios
//

import SwiftUI

@main
struct roomieverse_iosApp: App {
    // Note: Firebase configuration would go here
    // init() {
    //     FirebaseApp.configure()
    // }

    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
}
