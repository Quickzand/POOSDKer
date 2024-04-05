//
//  GameController.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/5/24.
//

import Foundation



class GameController {
    var appState : AppState
    
    init(appState: AppState) {
        self.appState = appState
    }
    
    func endGame() {
        self.appState.networkingController
    }
}
