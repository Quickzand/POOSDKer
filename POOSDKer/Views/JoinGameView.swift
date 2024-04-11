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
            
            HeaderBanner(text: "Open Games", fullWidth: true)
            List {
                ForEach(appState.discoveredPeers) {
                    discoveredHostModel in
                    
                    DiscoveredHostView(discoveredPeer: discoveredHostModel)
                    
                }
                
            }
            .background(Color(hex: "F5F2EA"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                .stroke(Color(hex: "#8AA792"), lineWidth: 4)
                )
            .padding(.all, 20)
            .scrollContentBackground(.hidden)
            
            
            .onAppear {
                appState.networkingController?.startBrowsing()
            }
            .onDisappear {
                appState.networkingController?.stopBrowsing()
            }
        }
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
