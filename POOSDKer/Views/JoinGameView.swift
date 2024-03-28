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
            List {
                ForEach(appState.discoveredPeers) {
                    discoveredHostModel in
                    
                    DiscoveredHostView(discoveredPeer: discoveredHostModel)
                    
                }
            }
            .onAppear {
                appState.networkingController?.startBrowsing()
            }
            .onDisappear {
                appState.networkingController?.stopBrowsing()
            }
        }
        .navigationTitle("Join Lobby")
        .toolbarTitleDisplayMode(.inlineLarge)
        .withBackground()
    }
}


struct DiscoveredHostView : View {
    @EnvironmentObject var appState : AppState
    var discoveredPeer : Peer
    
    var body : some View {
        NavigationLink(discoveredPeer.displayName, destination: LobbyView(peerHost: discoveredPeer))
    }
}

#Preview {
    JoinGameView().environmentObject(AppState())
}
