//
//  ContentView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/17/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState : AppState
    var body: some View {
        NavigationStack {
            VStack {
                NavigationLink("Host Game", destination: HostGameView())
                    .padding()
                NavigationLink("Join Game", destination: JoinGameView())
                    .padding()
                NavigationLink("Settings", destination: SettingsView())
                    .padding()
            }
        }
    }
}

#Preview {
    ContentView()
}
