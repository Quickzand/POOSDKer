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
        List {
            ForEach(appState.networkingController.participantController.discoveredHosts) {
                discoveredHostModel in
                
                DiscoveredHostView(discoveredHostModel: discoveredHostModel)
                
            }
        }
        .onAppear {
            appState.networkingController.participantController.discoveredHosts = []
            appState.networkingController.participantController.startBrowsing()
        }
        .onDisappear {
            appState.networkingController.participantController.stopBrowsing()
        }
        .navigationTitle("Join Lobby")
        .toolbarTitleDisplayMode(.inlineLarge)
    }
}


struct DiscoveredHostView : View {
    
    var discoveredHostModel : DiscoveredHost
    
    var body : some View {
        Button {
            print(discoveredHostModel)
        } label : {
            Text(discoveredHostModel.displayName)
        }
    }
}

#Preview {
    JoinGameView().environmentObject(AppState())
}
