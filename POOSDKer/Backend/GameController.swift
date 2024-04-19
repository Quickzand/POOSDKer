//
//  GameController.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/5/24.
//

import Foundation



class GameController {
    var appState : AppState
    
    var handController : HandController? = nil
    
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
        self.handController = HandController(gameController: self)
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
        
        self.appState.communityCards = []
        self.appState.networkingController?.broadcastUpdateCommunityCards()
        self.activePeerIndex = 0
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
            activePeer.totalBets = value
            self.appState.networkingController?.sendBetToHost()
            return;
        }
        
        
        print("Betting val: \(value) \t HighestBet \(appState.currentHighestBet)")
        if value != appState.currentHighestBet {
            for i in 0...appState.connectedPeers.count - 1 {
                print("Restting all peer's have acted")
                appState.connectedPeers[i].hasActed = false
            }
        }

        activePeer.bet += value
        activePeer.totalBets += value
        appState.totalPot += value

        activePeer.money -= value
        
        appState.networkingController?.broadcastUpdatePeerBet()
        
        appState.networkingController?.broadcastUpdatePeerMoney()
        
        
  
        
        
        
        
        print("\(activePeer.displayName) \t Is Betting...")
        
       
        
        self.endTurn()
        
        
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
        
        self.endTurn()
        
        appState.triggerViewUpdate.toggle()
        networkingController.broadcastUpdateGameState()
    }
    
    
    func endTurn() {
        appState.connectedPeers[activePeerIndex].hasActed = true
        appState.networkingController?.broadcastUpdatePot()
        handController?.determineIfHandEnded()
        handController?.determineIfRoundEnded()
    }

    func compareFinalHands() -> Int {
        // Placeholder for the logic to compare the hands of the players who have not folded.
        // Return the player who wins the hand.
        let notFolded = appState.connectedPeers.filter { !$0.isFolded }
        
        let winner = orderPeersByHand(peers: notFolded)[0]
        
        let winnerIndex = appState.connectedPeers.firstIndex(where: {peer in
            return peer.id == winner.id
        })
        
        return winnerIndex ?? 0
    }
    
    func incrementActivePeer() {
        let startingIndex = activePeerIndex
        self.activePeerIndex += 1 ;
        if activePeerIndex >= appState.connectedPeers.count {
            activePeerIndex = 0;
        }
        
        print("HERE \(appState.connectedPeers[self.activePeerIndex].isFolded) \t \(appState.connectedPeers[self.activePeerIndex].displayName)")
        
        while appState.connectedPeers[self.activePeerIndex].isFolded {
            print("Enjoying men at this point \(appState.connectedPeers[self.activePeerIndex].displayName)")
            self.activePeerIndex += 1 ;
            if activePeerIndex >= appState.connectedPeers.count {
                activePeerIndex = 0;
            }
            self.networkingController.broadcastUpdateGameState()
            if startingIndex == activePeerIndex {
                handController?.determineIfHandEnded()
                break
            }
        }
        
        
    }
    
    func resetPlayersRound() {
        for i in 0...appState.connectedPeers.count - 1 {
            appState.connectedPeers[i].bet = 0
            appState.connectedPeers[i].prevBet = 0
            appState.connectedPeers[i].hasActed = false
            appState.networkingController?.broadcastUpdatePeerBet()
        }
        
        activePeerIndex = 0
        while appState.connectedPeers[self.activePeerIndex].isFolded {
            print("Enjoying men at this point \(appState.connectedPeers[self.activePeerIndex].displayName)")
            self.activePeerIndex += 1 ;
            if activePeerIndex >= appState.connectedPeers.count {
                activePeerIndex = 0;
            }
            self.networkingController.broadcastUpdateGameState()
            if 0 == activePeerIndex {
                handController?.determineIfHandEnded()
                break
            }
        }
    }
    
    
    func resetPlayersHand() {
        for i in 0...appState.connectedPeers.count - 1 {
            appState.connectedPeers[i].bet = 0
            appState.connectedPeers[i].isFolded = false
            appState.connectedPeers[i].cards = [cardDeck.draw(), cardDeck.draw()]
            appState.connectedPeers[i].prevBet = 0
            appState.connectedPeers[i].hasActed = false
            activePeerIndex = i
            appState.networkingController?.broadcastUpdatePeerBet()
            appState.networkingController?.broadcastUpdatePlayerFoldState()
            appState.networkingController?.broadcastUpdatePlayerCards()
        }
        
        
        activePeerIndex = 0
    }
    
    

    
    func endGame() {
        self.activePeerIndex = 0
        self.appState.networkingController?.broadcastEndGame()
    }
}


class HandController {
    var gameController : GameController
    var appState : AppState {
        get {
            gameController.appState
        }
    }
    
    
    enum Round {
        case preFlop
        case flop
        case turn
        case river
    }
    
    var currentRound : Round = .preFlop
    
    init(gameController: GameController) {
        self.gameController = gameController
    }
    
    func startNextRound() {
        switch currentRound {
        case .preFlop:
            appState.communityCards = [gameController.cardDeck.draw(), gameController.cardDeck.draw(), gameController.cardDeck.draw()]
            currentRound = .flop
            break
        case .flop:
            appState.communityCards.append(gameController.cardDeck.draw())
            currentRound = .turn
            break
        case .turn:
            appState.communityCards.append(gameController.cardDeck.draw())
            currentRound = .river
            break
        case .river:
            concludeHand()
            startNewHand()
            currentRound = .preFlop
            break
        }
        
        gameController.activePeerIndex = 0
        
        gameController.resetPlayersRound()
        
        
        appState.networkingController?.broadcastUpdateCommunityCards()
    }
    
//    Should go through and seee if the next round is ready to be gone to, and if so, start next round. If not, just increment active player
    func determineIfRoundEnded() {
        // Check if all active players have acted
        let activePlayers = appState.connectedPeers.filter { !$0.isFolded && $0.money > 0 }
        let allHaveActed = activePlayers.allSatisfy { $0.hasActed }
        print("HOWDY \(allHaveActed)")
        
        if allHaveActed {
            if activePlayers.allSatisfy({ $0.bet == appState.currentHighestBet }) {
                print("All active players have matched the current highest bet or folded. Moving to the next round.")
                startNextRound()
            } else {
                // Reset hasActed for the next round of betting if necessary
                for index in appState.connectedPeers.indices {
                    appState.connectedPeers[index].hasActed = false
                }
            }
        } else {
            
            gameController.incrementActivePeer() // Use existing method to move to the next active peer
        }
    }


    
    
    func determineIfHandEnded() {
        // Check if only one player hasn't folded
        let activePlayers = appState.connectedPeers.filter { !$0.isFolded }
        if activePlayers.count == 1 {
            print("\(activePlayers[0].displayName) wins this hand.")
            let winnerIndex = appState.connectedPeers.firstIndex(where: {peer in
                return peer.id == activePlayers[0].id
            })
            endHand(winnerIndex: winnerIndex ?? 0)
            return
        }
    }
    
    func checkForGameOver() -> Bool {
        if (gameController.appState.connectedPeers.filter({peer in
            peer.money != 0
        }).count <= 1) {
            return true
        }
        return false
    }
    
    
//    Just distributing winnings
    func endHand(winnerIndex: Int) {
        print("\(appState.connectedPeers[winnerIndex].displayName) collects the pot.")
        appState.connectedPeers[winnerIndex].money += appState.totalPot
        appState.totalPot = 0

        
        var oldActivePeerIndex = gameController.activePeerIndex
        for i in 0...gameController.appState.connectedPeers.count - 1 {
            if gameController.appState.connectedPeers[i].money == 0 {
                gameController.appState.connectedPeers[i].isOut = true
                gameController.activePeerIndex = i
                gameController.appState.networkingController?.broadcastUpdatePlayerOutState()
            }
        }
        gameController.activePeerIndex = oldActivePeerIndex
        
        
        if(checkForGameOver()) {
            gameController.endGame()
        }
        else {
            startNewHand()
        }
    }
    
    
//    Actually doing comparisons and junk
    func concludeHand() {
        print("Concluding hand. Comparing final hands.")
        let winnerIndex = gameController.compareFinalHands()
        endHand(winnerIndex: winnerIndex)
    }
    
    func startNewHand() {
        gameController.cardDeck = Deck()
        gameController.cardDeck.shuffle()
        appState.communityCards = []
        appState.networkingController?.broadcastUpdateCommunityCards()
        gameController.resetPlayersHand()
        currentRound = .preFlop
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
