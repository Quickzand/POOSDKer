//
//  GameController.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/5/24.
//

import Foundation



class GameController {
    var appState : AppState
    
    var roundNumber : Int = 0
    
    var networkingController : NetworkingController {
        return appState.networkingController!
    }
    
    var activePeerIndex : Int {
        get {
            return appState.activePeerIndex
        }
        
        set {
            appState.activePeerIndex = newValue
        }
    }
    
    var activePeer : Peer {
        get {
            guard appState.connectedPeers.indices.contains(activePeerIndex) else { return appState.connectedPeers[0] }
            return appState.connectedPeers[activePeerIndex]
        }
        
        set {
            appState.connectedPeers[activePeerIndex] = newValue
        }
       }
    
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func startGame() {
        
        
    //  Go through all peers and ensure their game values are set to inital
        for i in 0...appState.connectedPeers.count - 1 {
//            appState.connectedPeers[i].money = 200
        }
        
        
        appState.isInGame = true
        appState.networkingController?.broadcastCommandToPeers(broadcastCommandType: .startGame)
    }
    
    func bet() {
        if !self.appState.isHost {
            self.appState.networkingController?.sendBetToHost()
            return;
        }
        
        activePeer.money += 20
        appState.networkingController?.broadcastUpdatePeerMoney()
        
        print("\(activePeer.displayName) \t Is Checking...")
        activePeerIndex += 1;
        
        
        if activePeerIndex >= appState.connectedPeers.count {
            activePeerIndex = 0;
        }
        
        appState.triggerViewUpdate.toggle()
        
        
        networkingController.broadcastUpdateGameState()
    }
    
    
    func check() {
        if !self.appState.isHost {
            self.appState.networkingController?.sendCheckToHost()
            return;
        }
        
        print("\(activePeer.displayName) \t Is Checking...")
        activePeerIndex += 1;
        
        
        if activePeerIndex >= appState.connectedPeers.count {
            activePeerIndex = 0;
        }
        
        appState.triggerViewUpdate.toggle()
        
        
        networkingController.broadcastUpdateGameState()
    }
    
    func endGame() {
        self.activePeerIndex = 0
        self.appState.networkingController?.broadcastEndGame()
    }
}



class Player {
    
}


