//
//  PlayingCard.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/5/24.
//

import SwiftUI

struct PlayingCard: View {
    
    enum Suit : String {
        case Hearts = "heart.slash.fill"
        case Spades = "suit.spade.fill"
        case Diamonds = "suit.diamond.fill"
        case Clubs = "suit.club.fill"
    }
    
    enum Face : String {
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
    
    
    
    
    var suit : Suit
    
    var face : Face
    
    
    private var faceColor : Color {
        if suit == .Hearts || suit == .Diamonds {
            return Color.red
        }
        return Color.purple
    }
    
    
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: suit.rawValue)
                Text(face.rawValue)
                Spacer()
            }
            Spacer()
            HStack {
                Image(systemName: suit.rawValue)
                    .scaleEffect(3)
            }
            Spacer()
            HStack {
                Spacer()
                Text(face.rawValue)
                Image(systemName: suit.rawValue)
            }
        }
        .padding()
        .foregroundStyle(faceColor)
        .frame(width: 200, height: 300)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
        .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
        
    }
}

#Preview {
    PlayingCard(suit: .Diamonds, face: .Two)
}
