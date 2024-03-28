//
//  HeaderBanner.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/18/24.
//

import SwiftUI

struct HeaderBanner: View {
    
    var text : String
    
    var fullWidth : Bool = false
    
    var body : some View {
        HStack {
            PlayingCard(suit: .Spades, face: .Ace)
                .frame(width: 20)
                .font(.system(size: 8))
                .scaleEffect(0.45)
                .offset(x: 5, y:5)
                .zIndex(-1)
                .rotationEffect(Angle(degrees: -20))
                .padding(.leading, 20)
            PlayingCard(suit: .Diamonds, face: .Ace)
                .frame(width: 20)
                .font(.system(size: 8))
                .scaleEffect(0.45)
                .offset(x: 5)
            Text(text)
                .padding()
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .background(Color("OutsetBackground"))
                .zIndex(10)
                .shadow(radius: 10)
                .font(.largeTitle)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            PlayingCard(suit: .Hearts, face: .Ace)
                .frame(width: 20)
                .font(.system(size: 8))
                .scaleEffect(0.45)
                .offset(x: -5)
            PlayingCard(suit: .Clubs, face: .Ace)
                .frame(width: 20)
                .font(.system(size: 8))
                .scaleEffect(0.45)
                .offset(x: -5, y:5)
                .zIndex(-1)
                .rotationEffect(Angle(degrees: 20))
                .padding(.trailing, 20)
        }
        .frame(height: 75)
    }
}

#Preview {
    HeaderBanner(text: "Test")
}
