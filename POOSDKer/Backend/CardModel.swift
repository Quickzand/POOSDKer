//
//  Card.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/10/24.
//

import Foundation


struct CardModel : Codable, Hashable {
    var suit : Suit
    var face : Face
    
    
    static func < (lhs: CardModel, rhs: CardModel) -> Bool {
        return lhs.face.rawValue < rhs.face.rawValue
    }
    
    static func == (lhs: CardModel, rhs: CardModel) -> Bool {
        return lhs.face.rawValue == rhs.face.rawValue
    }
    

}
func cardToDictionary(card: CardModel) -> [String: Any] {
    return ["suit": card.suit.rawValue, "face": card.face.rawValue]
}

enum Suit : String, Codable {
    case Hearts = "suit.heart.fill"
    case Spades = "suit.spade.fill"
    case Diamonds = "suit.diamond.fill"
    case Clubs = "suit.club.fill"
}

enum Face : String, Codable {
    case Two = "2"
    case Three = "3"
    case Four = "4"
    case Five = "5"
    case Six = "6"
    case Seven = "7"
    case Eight = "8"
    case Nine = "9"
    case Ten = "10"
    case Jack = "J"
    case Queen = "Q"
    case King = "K"
    case Ace = "A"
}


func FaceToNum(face : Face) -> Int {
    switch face {
    case .Two:
        return 2
    case .Three:
        return 3
    case .Four:
        return 4
    case .Five:
        return 5
    case .Six:
        return 6
    case .Seven:
        return 7
    case .Eight:
        return 8
    case .Nine:
        return 9
    case .Ten:
        return 10
    case .Jack:
        return 11
    case .Queen:
        return 12
    case .King:
        return 13
    case .Ace:
        return 14
    }
}


enum HandRank: Int, Comparable {
    case highCard = 1, onePair, twoPair, threeOfAKind, straight, flush, fullHouse, fourOfAKind, straightFlush, royalFlush
    
    static func < (lhs: HandRank, rhs: HandRank) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

func rankHand(hand: [CardModel]) -> HandRank {
    let sortedHand = hand.sorted(by: { $0.face.rawValue < $1.face.rawValue })
    let suits = Set(hand.map { $0.suit })
    let ranks = sortedHand.map { FaceToNum(face:$0.face) }
    let isFlush = suits.count == 1
    let rankCounts = Dictionary(ranks.map { ($0, 1) }, uniquingKeysWith: +)
    let counts = rankCounts.values.sorted(by: >)
    
    let isStraight = ranks.enumerated().allSatisfy { index, value in
        index == 0 || ranks[index - 1] + 1 == value
    } || ranks == [2, 3, 4, 5, 14] // Special case for A-2-3-4-5 straight

    if isFlush && isStraight && ranks.contains(14) {
        return .royalFlush
    }
    if isFlush && isStraight {
        return .straightFlush
    }
    if counts.first == 4 {
        return .fourOfAKind
    }
    if counts == [3, 2] {
        return .fullHouse
    }
    if isFlush {
        return .flush
    }
    if isStraight {
        return .straight
    }
    if counts.first == 3 {
        return .threeOfAKind
    }
    if counts == [2, 2] {
        return .twoPair
    }
    if counts.first == 2 {
        return .onePair
    }
    return .highCard
}


func compareHands(hand1: [CardModel], hand2: [CardModel]) -> String {
    let rank1 = rankHand(hand: hand1)
    let rank2 = rankHand(hand: hand2)
    
    if rank1 > rank2 {
        return "Hand 1 wins with \(rank1)"
    } else if rank2 > rank1 {
        return "Hand 2 wins with \(rank2)"
    } else {
        // For hands of the same rank, you'll need to implement tie-breakers based on the rank
        return "It's a tie. Further tie-breaking needed."
    }
}
/*
 Return a rank value and store it activePeer attribute called self.rankValue
 */
func orderPeersByHand(peers: [Peer]) -> [Peer] {
    return peers.sorted { (peer1: Peer, peer2: Peer) -> Bool in
        let handRank1 = rankHand(hand: peer1.cards)
        let handRank2 = rankHand(hand: peer2.cards)
        return handRank1 > handRank2
    }
}


func orderPeersByHand(peers: [Peer]) -> [Peer] {
    return peers.sorted { (peer1: Peer, peer2: Peer) -> Bool in
        let handRank1 = rankHand(hand: peer1.cards)
        let handRank2 = rankHand(hand: peer2.cards)
        return handRank1 > handRank2
    }
}
