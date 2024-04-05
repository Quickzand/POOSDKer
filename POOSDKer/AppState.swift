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
    
    
    @Published var settings : Settings {
        didSet {
            saveSettings()
        }
    }
    //    WHO IS ACTUALLY IN THE CURRENT LOBBY
        @Published var connectedPeers : [Peer] = []
    
    
    var isHost : Bool {
        if let hostPeer = hostPeer {
            return hostPeer.id == UID
        }
        else {
            return false 
        }
    }
    
    
    @Published var isInGame : Bool = false
    @Published var showResultsView : Bool = false 
    
    var hostPeer : Peer? = nil
    
    
    var UID : String = UUID().uuidString
    var peerID: MCPeerID!
    
    @Published var networkingController : NetworkingController? = nil;
    @Published var gameController : GameController? = nil;
    
    init() {
        settings = Settings()
        // Load settings from UserDefaults upon initialization
        settings = loadSettings()
        networkingController = NetworkingController(appState: self)
        gameController = GameController(appState: self)
    }
    
    // Save settings to UserDefaults
    private func saveSettings() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: "settings")
        }
    }
    
    // Load settings from UserDefaults
    private func loadSettings() -> Settings {
        if let savedSettings = UserDefaults.standard.object(forKey: "settings") as? Data,
           let loadedSettings = try? JSONDecoder().decode(Settings.self, from: savedSettings) {
            return loadedSettings
        } else {
            return Settings() // Return default settings if none were saved
        }
    }
}






