//
//  Bible_ChatApp.swift
//  Bible Chat
//
//  Created by LMGAJ on 7/1/26.
//

import SwiftUI

@main
struct Bible_ChatApp: App {
    @StateObject private var app = AppState()
    @StateObject private var settings = SettingsStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(app)
                .environmentObject(settings)
                .tint(Theme.brown)
                .preferredColorScheme(settings.colorScheme)
        }
    }
}
