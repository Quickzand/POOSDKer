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
    
    var smallBlind = 1
    var bigBling = 2
    
    var cardDeck : Deck = Deck()
    
    var roundIndex : Int = 0 // 0 = pre, 1 = flop, 2 = turn, 3 = river
    
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
    
    var dealerButtonIndex: Int {
        get {
            return appState.dealerButtonIndex
        }
        
        set {
            appState.dealerButtonIndex = newValue
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
    
    
    var dealerButtonPeer : Peer {
        get {
            guard appState.connectedPeers.indices.contains(dealerButtonIndex) else { return appState.connectedPeers[0] }
            return appState.connectedPeers[dealerButtonIndex]
        }
        
        set {
            appState.connectedPeers[dealerButtonIndex] = newValue
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
        
        //self.appState.communityCards = [cardDeck.draw(),cardDeck.draw(),cardDeck.draw(), cardDeck.draw(),cardDeck.draw()]
        
        
        //self.appState.networkingController?.broadcastUpdateCommunityCards()
        if appState.connectedPeers.count == 1 {
            appState.activePeerIndex = appState.dealerButtonIndex + 0
        }
        else if appState.connectedPeers.count == 2 {
            appState.connectedPeers[appState.dealerButtonIndex + 1].bet = 2
            appState.connectedPeers[appState.dealerButtonIndex + 1].money -= 2
            appState.activePeerIndex = appState.dealerButtonIndex
            if appState.activePeerIndex >= appState.connectedPeers.count {
                appState.activePeerIndex = 0
            }
        }
        else if appState.connectedPeers.count == 3 {
            appState.connectedPeers[appState.dealerButtonIndex + 1].bet = 1
            appState.connectedPeers[appState.dealerButtonIndex + 1].money -= 1
            appState.connectedPeers[appState.dealerButtonIndex + 2].bet = 2
            appState.connectedPeers[appState.dealerButtonIndex + 2].money -= 2
            appState.activePeerIndex = appState.dealerButtonIndex + 2
            if appState.activePeerIndex >= appState.connectedPeers.count {
                appState.activePeerIndex = 0
            }
        }
        else {
            appState.activePeerIndex = appState.dealerButtonIndex + 3
            appState.connectedPeers[appState.dealerButtonIndex + 1].bet = 1
            appState.connectedPeers[appState.dealerButtonIndex + 1].money -= 1
            appState.connectedPeers[appState.dealerButtonIndex + 2].bet = 2
            appState.connectedPeers[appState.dealerButtonIndex + 2].money -= 2
            if appState.activePeerIndex >= appState.connectedPeers.count {
                appState.activePeerIndex = 0
            }
        }
    }
    
    // playing the pre round true if completed false if not
    func matchingBetsCheck() -> Bool {
        if appState.connectedPeers.count <= 1 {
            return true
        }
        // check if current player matches the prevPlayer bet
        var index = activePeerIndex - 1
        if index < 0 {
            index = activePeerIndex
        }
        
        while true {
            if activePeerIndex > appState.connectedPeers.count {
                activePeerIndex = 0;
            }
            if index < 0 {
                index = activePeerIndex
            }
            // all players have matching bets
            if index == activePeerIndex{
                return true
            }
            // skips folded players
            if !appState.connectedPeers[index].isFolded {
                index -= 1
            }
            // if bets match continue until a bet doesn't match
            else if (appState.connectedPeers[index].prevBet == appState.connectedPeers[activePeerIndex].prevBet) {
                index -= 1
            }
            // breaks and returns false when we find a bet that doesnt match
            else{
                break
            }
        }
       
        return false
    }
    
    // checks if all players are ready to move onto the next round
    func arePlayersReady() -> Bool {
        if appState.connectedPeers.count <= 1 {
            return true
        }
        for i in 0...appState.connectedPeers.count - 1 {
            if appState.connectedPeers[i].waiting {
                print(appState.connectedPeers[i].displayName)
                return false
            }
        }
        return true
    }
    
    func distributeCards() {
        cardDeck = Deck()
        cardDeck.shuffle()
        for i in 0...appState.connectedPeers.count - 1 {
            appState.activePeerIndex = i
            appState.connectedPeers[i].cards = [cardDeck.draw(), cardDeck.draw()]
            print("Giving out the cards \(appState.connectedPeers[i].cards)")
            appState.networkingController?.broadcastUpdatePlayerCards()
            
        }
        
        activePeerIndex = 0
    }
    
    func bet(value : Int) {
        if !self.appState.isHost {
            activePeer.bet = value
            self.appState.networkingController?.sendBetToHost()
            return;
        }
        
        
        

        
        print(value)
        print(appState.currentHighestBet)
        if value == appState.currentHighestBet {
            self.appState.connectedPeers[activePeerIndex].waiting = false
        }
        else {
            // when someone bets every player that is alive will now be waiting
            for i in 0...appState.connectedPeers.count - 1{
                if i == activePeerIndex {
                    continue
                }
                appState.connectedPeers[i].waiting = true
            }
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
        
        self.appState.connectedPeers[activePeerIndex].waiting = false
        
        print("\(activePeer.displayName) \t Is Checking...")
        
        appState.connectedPeers[activePeerIndex].money -= appState.currentHighestBet - appState.connectedPeers[activePeerIndex].prevBet
        appState.connectedPeers[activePeerIndex].prevBet = appState.currentHighestBet
      
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
    
    func newRoundStart() {
        if roundIndex == 1 {
            cardDeck.draw()
            self.appState.communityCards.append(cardDeck.draw())
            self.appState.communityCards.append(cardDeck.draw())
            self.appState.communityCards.append(cardDeck.draw())
            self.appState.networkingController?.broadcastUpdateCommunityCards()
            appState.activePeerIndex = appState.dealerButtonIndex + 1
            if appState.activePeerIndex >= appState.connectedPeers.count {
                appState.activePeerIndex = 0
            }
        }
        if roundIndex == 2 {
            cardDeck.draw()
            self.appState.communityCards.append(cardDeck.draw())
            self.appState.networkingController?.broadcastUpdateCommunityCards()
            appState.activePeerIndex = appState.dealerButtonIndex + 1
            if appState.activePeerIndex >= appState.connectedPeers.count {
                appState.activePeerIndex = 0
            }
        }
        if roundIndex == 3 {
            cardDeck.draw()
            self.appState.communityCards.append(cardDeck.draw())
            self.appState.networkingController?.broadcastUpdateCommunityCards()
        }
    }
    func incrementActivePeer() {
        self.activePeerIndex += 1 ;
        if activePeerIndex >= appState.connectedPeers.count {
            activePeerIndex = 0;
        }
        let startingPeerIndex = self.activePeerIndex
        

        while(activePeer.isFolded) {
            if(activePeerIndex == startingPeerIndex) {
//                MARK: CODE FOR ending round since everyhone else is folded
                roundIndex = 5
                break;
            }
            if activePeerIndex >= appState.connectedPeers.count {
                activePeerIndex = 0;
            }
            self.activePeerIndex += 1;
        }
        
        // if a player folds then a special round is played where the remaining player wins the money
        if roundIndex == 5 {
            appState.connectedPeers[activePeerIndex].money += appState.getTotalPot()
            
            // clear deck and create a new deck and shuffle
            self.startNewRound()
        }
        
        // this checks if every player bets match
        else if self.matchingBetsCheck() && self.arePlayersReady() {
            roundIndex += 1
            self.newRoundStart()
            for i in  0...appState.connectedPeers.count - 1 {
                appState.connectedPeers[i].waiting = true
            }
        }
        if roundIndex >= 4 {
            // determing winner and end game
            var rankedPlayer: [Peer] = []
            rankedPlayer = orderPeersByHand(peers: appState.connectedPeers)
            
            // gets the index of the sorted ranked players
            var index = appState.connectedPeers.firstIndex(where: {$0.id == rankedPlayer[0].id}) ?? 0
            appState.connectedPeers[index].money += appState.getTotalPot()
            
            // clear deck and create a new deck and shuffle
            self.startNewRound()
        }
    }
    
    func resetPlayers(index: Int) {
        appState.connectedPeers[index].bet = 0
        appState.connectedPeers[index].isFolded = false
        appState.connectedPeers[index].cards = []
        appState.connectedPeers[index].prevBet = 0
        appState.connectedPeers[index].waiting = true
        
        self.appState.networkingController?.broadcastUpdatePeerBet()
        self.appState.networkingController?.broadcastUpdatePlayerFoldState()
    }
    
    func endGame() {
        self.activePeerIndex = 0
        self.appState.networkingController?.broadcastEndGame()
    }
    
    
    func startNewRound() {
        
        // now return all player attributes to original
        for i in 0...appState.connectedPeers.count - 1 {
            resetPlayers(index: i)
        }
        
        // reset round index and move the dealer button to the next player
        roundIndex = 0
        dealerButtonIndex += 1
        if dealerButtonIndex >= appState.connectedPeers.count {
            dealerButtonIndex = 0
        }
        
        
        appState.communityCards = []
        self.appState.networkingController?.broadcastUpdateCommunityCards()
        self.cardDeck = Deck()
        self.cardDeck.shuffle()
        self.distributeCards()
        
        // do the blinds
        if appState.connectedPeers.count == 2 {
            if appState.dealerButtonIndex == appState.connectedPeers.count - 1 {
                appState.connectedPeers[0].bet = 2
                appState.connectedPeers[0].money -= 2
            }
            else{
                appState.connectedPeers[appState.dealerButtonIndex + 1].bet = 2
                appState.connectedPeers[appState.dealerButtonIndex + 1].money -= 2
            }
        }
        else {
            if appState.dealerButtonIndex == appState.connectedPeers.count - 1 {
                appState.connectedPeers[0].bet = 1
                appState.connectedPeers[0].money -= 1
                appState.connectedPeers[1].bet = 2
                appState.connectedPeers[1].money -= 2
            }
            else if appState.dealerButtonIndex == appState.connectedPeers.count - 2 {
                appState.connectedPeers[appState.connectedPeers.count - 1].bet = 1
                appState.connectedPeers[appState.connectedPeers.count - 1].money -= 1
                appState.connectedPeers[0].bet = 2
                appState.connectedPeers[0].money -= 2
            }
            else{
                appState.connectedPeers[appState.dealerButtonIndex + 1].bet = 1
                appState.connectedPeers[appState.dealerButtonIndex + 1].money -= 1
                appState.connectedPeers[appState.dealerButtonIndex + 2].bet = 2
                appState.connectedPeers[appState.dealerButtonIndex + 2].money -= 2
            }
        }
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
