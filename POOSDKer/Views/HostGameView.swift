//
//  HostGame.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct HostGameView: View {
    @EnvironmentObject var appState : AppState
    var body: some View {
        VStack {
            Button {
                appState.networkingController.hostController.startService()
                
            } label: {
                Text("Start Host")
            }
            NavigationLink("Lobby", destination: LobbyView())
        }
    }
}

#Preview {
    HostGameView()
}
