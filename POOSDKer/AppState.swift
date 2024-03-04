//
//  AppState.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import Foundation
import MultipeerConnectivity


class AppState : ObservableObject {
    
    @Published var discoveredPeers : [Peer] = [];
    
    
    @Published var settings : Settings = Settings();
    
    //    WHO IS ACTUALLY IN THE CURRENT LOBBY
        @Published var connectedPeers : [Peer] = []
    
    
    var isHost : Bool = false
    
    
    
    var UID : String = UUID().uuidString
    var peerID: MCPeerID!
    
    @Published var networkingController : NetworkingController? = nil;
    
    init() {
        networkingController = NetworkingController(appState: self)
    }
}






