//
//  TableView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/2/24.
//

import SwiftUI

struct TableView: View {
    @EnvironmentObject var appState: AppState
    
    @State private var displayedPeersList : [Peer] = []
    
    
    var body: some View {
        VStack {
            HStack {
                PlayerCardView(index:0, displayedPeersList: $displayedPeersList)
            }
            Spacer()
            HStack {
                PlayerCardView(index:1, displayedPeersList: $displayedPeersList)
                Spacer()
                PlayerCardView(index:2, displayedPeersList: $displayedPeersList)
            }
            Spacer()
            HStack {
                PlayerCardView(index:3, displayedPeersList: $displayedPeersList)
                Spacer()
                PlayerCardView(index:4, displayedPeersList: $displayedPeersList)
            }
            
        }
        .background {
            Ellipse()
                .frame(width:300, height:500)
                .foregroundStyle(.brown)
        }
        .frame(minWidth: 300, minHeight: 500)
        .onAppear {
            if appState.isInGame {
                displayedPeersList = appState.connectedPeers.filter({peer in
                    if peer.id == appState.clientPeer.id {
                        return false
                    }
                    return true
                })
            }
            else {
                displayedPeersList = appState.connectedPeers
            }
        }
    }
}



#Preview {
    TableView().environmentObject(AppState())
}
