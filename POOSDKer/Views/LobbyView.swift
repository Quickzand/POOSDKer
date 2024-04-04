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
                appState.isInGame = true
                appState.networkingController?.broadcastCommandToPeers(broadcastCommandType: .startGame)
            }
        label: {
            Text("Join Game")
                .foregroundStyle(.black)
                .frame(width: UIScreen.main.bounds.width*0.4, height: 50, alignment: .center)
                .background(RoundedRectangle(cornerRadius: 5).fill(Color(hex: "F5F2EA")))
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
            if(appState.isHost) {
                appState.networkingController?.stopHosting();
            }
            else {
                appState.networkingController?.disconnectFromHost()
            }
        }
        .navigationDestination(isPresented: $appState.isInGame) {
            PlayGameView()  .navigationBarBackButtonHidden(true)
        }
        .withBackground()
    }
}

#Preview {
    LobbyView().environmentObject(AppState())
}
