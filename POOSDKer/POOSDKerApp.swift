//
//  POOSDKerApp.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/17/24.
//

import SwiftUI

@main
    struct POOSDKerApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
        }
    }
}
