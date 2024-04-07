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
            
            HeaderBanner(text:"Lobby", fullWidth: true)
            Spacer()
            VStack {
                TableView()
            }
            Spacer()
            Button{
                appState.gameController?.startGame()
            }
        label: {
            Text("Start Game")
        }.disabled(!self.appState.isHost)
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
            if(!appState.isInGame) {
                if(appState.isHost) {
                    
                    appState.networkingController?.stopHosting();
                }
                else {
                    appState.networkingController?.disconnectFromHost()
                }
            }
        }
        .navigationDestination(isPresented: $appState.isInGame) {
            PlayGameView()  .navigationBarBackButtonHidden(true)
        }
        .navigationDestination(isPresented: $appState.showResultsView) {
            ResultsView()  .navigationBarBackButtonHidden(true)
        }
        .withBackground()
    }
}

#Preview {
    LobbyView().environmentObject(AppState())
}
