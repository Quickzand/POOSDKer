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
    
    var cardDeck : Deck = Deck()
    
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
        appState.isInGame = true
        appState.networkingController?.broadcastCommandToPeers(broadcastCommandType: .startGame)
        for i in 0...appState.connectedPeers.count - 1 {
            appState.activePeerIndex = i
            appState.connectedPeers[i].money = 200
            appState.networkingController?.broadcastUpdatePeerMoney()
        }
        
        self.distributeCards()
        
        
        appState.activePeerIndex = 0
    }
    
    
    func distributeCards() {
        cardDeck = Deck()
        cardDeck.shuffle()
        print("HERE1")
        for i in 0...appState.connectedPeers.count - 1 {
            appState.activePeerIndex = i
            print("HERE2")
            appState.connectedPeers[i].cards = [cardDeck.draw(), cardDeck.draw()]
            print("HERE3")
            print("Giving our the cards \(appState.connectedPeers[i].cards)")
            appState.networkingController?.broadcastUpdatePlayerCards()
            print("HERE4")
            
        }
        
        activePeerIndex = 0
    }
    
    func bet(value : Int) {
        if !self.appState.isHost {
            activePeer.bet = value
            self.appState.networkingController?.sendBetToHost()
            return;
        }
        
        activePeer.bet += value
        activePeer.money -= value
        appState.networkingController?.broadcastUpdatePeerBet()
        appState.networkingController?.broadcastUpdatePeerMoney()
        
        print("\(activePeer.displayName) \t Is Checking...")
       
        
        self.incrementActivePeer()
        
        appState.triggerViewUpdate.toggle()
        
        
        networkingController.broadcastUpdateGameState()
    }
    
    
    func check() {
        if !self.appState.isHost {
            self.appState.networkingController?.sendCheckToHost()
            return;
        }
        
        print("\(activePeer.displayName) \t Is Checking...")
      
        self.incrementActivePeer()
        
        appState.triggerViewUpdate.toggle()
        
        
        networkingController.broadcastUpdateGameState()
    }
    
    func fold() {
        if !self.appState.isHost {
            self.appState.networkingController?.sendFoldToHost()
            return;
        }
        
        print("\(activePeer.displayName) \t Is Folding...")
        activePeer.isFolded = true
        
        appState.networkingController?.broadcastUpdatePlayerFoldState()
        
        self.incrementActivePeer()
        
        appState.triggerViewUpdate.toggle()
        networkingController.broadcastUpdateGameState()
    }
    
    
    func incrementActivePeer() {
        var startingPeerIndex = self.activePeerIndex
        self.activePeerIndex += 1 ;
        if activePeerIndex >= appState.connectedPeers.count {
            activePeerIndex = 0;
        }
        while(activePeer.isFolded) {
            if(activePeerIndex == startingPeerIndex) {
//                MARK: CODE FOR ending round since everyhone else is folded
                break;
            }
            if activePeerIndex >= appState.connectedPeers.count {
                activePeerIndex = 0;
            }
            self.activePeerIndex += 1;
        }
        
        
        
    }
    
    func endGame() {
        self.activePeerIndex = 0
        self.appState.networkingController?.broadcastEndGame()
    }
}


struct Deck {
    private var cards: [CardModel] = []
    
    init() {
        self.fillDeck()
    }
    
    // Fills the deck with 52 cards
    private mutating func fillDeck() {
        for suit in [Suit.Hearts, Suit.Diamonds, Suit.Clubs, Suit.Spades] {
            for face in [Face.Two, Face.Three, Face.Four, Face.Five, Face.Six, Face.Seven, Face.Eight, Face.Nine, Face.Ten, Face.Jack, Face.Queen, Face.King, Face.Ace] {
                let card = CardModel(suit: suit, face: face)
                self.cards.append(card)
            }
        }
    }
    
    // Shuffles the deck
    mutating func shuffle() {
        self.cards.shuffle()
    }
    
    // Draws a card from the top of the deck
    mutating func draw() -> CardModel {
        return self.cards.popLast()!
    }
    
    // Check if the deck is empty
    func isEmpty() -> Bool {
        return self.cards.isEmpty
    }
}
