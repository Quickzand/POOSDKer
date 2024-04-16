//
//  Peer.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/7/24.
//

import Foundation
import MultipeerConnectivity

struct Peer: Identifiable, Codable, Equatable {
    var id: String // Use a unique identifier that you can match with MCPeerID.displayName
    var displayName: String
    var playerColor : String
    var playerIcon: String
    
    var money : Int
    var bet : Int
    var totalBets : Int = 0
    
    var isFolded : Bool
    
    var cards : [CardModel]
    
    var prevBet : Int = 0
    
    var waiting : Bool = false
    
    var mcPeerID: MCPeerID?
    
    
    func isOut() -> Bool {
        if money == 0 {
            return true
        }
        
        return false
    }

    // Since MCPeerID is not Codable, we exclude it from the encoding process
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case playerColor
        case playerIcon
        case money
        case bet
        case isFolded
        case cards
    }
    
    
    // Initialize with MCPeerID optionally
    init(id: String, displayName: String, playerColor: String , playerIcon: String, mcPeerID: MCPeerID? = nil) {
        self.id = id
        self.displayName = displayName
        self.playerColor = playerColor
        self.playerIcon = playerIcon
        self.mcPeerID = mcPeerID
        self.money = 0
        self.bet = 0 
        self.isFolded = false
        self.cards = []
        self.prevBet = 0
        self.waiting = true
    }
}


