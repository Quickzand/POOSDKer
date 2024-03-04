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
            Text("Lobby").font(.title)
                .padding()
            Spacer()
            VStack {
                TableView()
            }
            Spacer()
            NavigationLink("Start Game", destination: PlayGameView()).disabled(!self.appState.isHost)
        }
        .onAppear {
            if let peerHost = peerHost {
                appState.networkingController?.requestToJoinHost(hostPeer: peerHost)
            }
            else {
                appState.networkingController?.startHosting();
            }
        }
        .onDisappear {
            if(appState.isHost) {
                appState.networkingController?.stopHosting();
            }
            else {
                appState.networkingController?.disconnectFromHost()
            }
        }
    }
}

#Preview {
    LobbyView().environmentObject(AppState())
}
