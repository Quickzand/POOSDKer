//
//  Peer.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/7/24.
//

import Foundation
import MultipeerConnectivity

struct Peer: Identifiable, Codable {
    var id: String // Use a unique identifier that you can match with MCPeerID.displayName
    var displayName: String
    var playerColor : String
    
    var money : Int
    var bet : Int
    
    var isFolded : Bool
    
    var cards : [CardModel]
    
    
    var mcPeerID: MCPeerID?

    // Since MCPeerID is not Codable, we exclude it from the encoding process
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case playerColor
        case money
        case bet
        case isFolded
        case cards
    }
    
    
    // Initialize with MCPeerID optionally
    init(id: String, displayName: String, playerColor: String , mcPeerID: MCPeerID? = nil) {
        self.id = id
        self.displayName = displayName
        self.playerColor = playerColor
        self.mcPeerID = mcPeerID
        self.money = 0
        self.bet = 0 
        self.isFolded = false
        self.cards = []
    }
}


