//
//  JoinGame.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct JoinGameView: View {
    @EnvironmentObject var appState : AppState
    var body: some View {
        VStack {
            Button {
                appState.networkingController.participantController.startBrowsing()
            }
        label: {
            Text("Start searching...")
        }
            NavigationLink("Lobby", destination: LobbyView())
        }
    }
}

#Preview {
    JoinGameView()
}
