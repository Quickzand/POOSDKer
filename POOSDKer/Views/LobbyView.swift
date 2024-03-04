//
//  LobbyView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct LobbyView: View {
    @EnvironmentObject var appState : AppState
    
    var peerHost : Peer? = nil
    
    var body: some View {
        VStack {
            Text("Lobby")
            VStack {
                TableView()
            }
            NavigationLink("Start Game", destination: PlayGameView())
        }
        .onAppear {
            if let peerHost = peerHost {
                appState.networkingController?.invitePeer(peerHost.mcPeerID!)
            }
            else {
                appState.networkingController?.startHosting();
            }
        }
        .onDisappear {
            appState.networkingController?.stopHosting();
        }
    }
}

#Preview {
    LobbyView()
}
