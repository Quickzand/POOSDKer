//
//  PlayingCard.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/5/24.
//

import SwiftUI


enum Suit : String {
    case Hearts = "suit.heart.fill"
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






struct PlayingCard: View {
    

    
    
    var suit : Suit
    
    var face : Face
    
    
    private var faceColor : Color {
        switch suit {
        case .Hearts:
            Color("Hearts")
        case .Spades:
            Color("Spades")
        case .Diamonds:
            Color("Diamonds")
        case .Clubs:
            Color("Clubs")
        }
    }
    
    
    @State var isFlipped : Bool = false
    
    @State var topRotation = 0.0
    @State var backRotation = -90.0
    
    
    
    var body: some View {
        ZStack {
            
        
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
        .aspectRatio(2/3, contentMode: .fit) 
        .background(Color("OutsetBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 10.0))
        
        .rotation3DEffect(
            Angle(degrees: topRotation),
                                  axis: (x: 0.0, y: 1.0, z: 0.0)
        )
            HStack {
                Spacer()
                VStack {
                    Spacer()
                    Image(systemName: Suit.Diamonds.rawValue)
                        .foregroundColor(Color("Diamonds"))
                        .padding(.all, 10)
                    Image(systemName: Suit.Hearts.rawValue)
                        .foregroundColor(Color("Hearts"))
                        .padding(.all, 10)
                    Image(systemName: Suit.Clubs.rawValue)
                        .foregroundColor(Color("Clubs"))
                        .padding(.all, 10)
                    Image(systemName: Suit.Spades.rawValue)
                        .foregroundColor(Color("Spades"))
                        .padding(.all, 10)
                    Spacer()
                }
                Spacer()
            }
            .font(.system(size: 30.0))
            .padding()
            .foregroundStyle(faceColor)
            .aspectRatio(2/3, contentMode: .fit)
            .background(Color("OutsetBackground"))
            .border(Color(hex: "#CEB064"), width: 25)
            .border(Color(hex: "#3B3B3B"), width: 20)
            .clipShape(RoundedRectangle(cornerRadius: 10.0))
            .rotation3DEffect(
                Angle(degrees: backRotation),
                                      axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            
         
        }.shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
            .onChange(of: isFlipped) {
                setFlipped()
            }
            .onAppear {
                setFlipped(useAnimation: false)
            }
    }
    
    func setFlipped(useAnimation : Bool = true) {
        var animationDuration = !useAnimation ? 0 : 0.25
        if !isFlipped {
            withAnimation(.linear(duration:animationDuration).delay(animationDuration)) {
                topRotation = 0
            }
            
            withAnimation(.linear(duration:animationDuration)) {
                backRotation = -90
            }
            
            
        }
        else {
            withAnimation(.linear(duration:animationDuration)) {
                topRotation = 90
            }
            
            withAnimation(.linear(duration:animationDuration).delay(animationDuration)) {
                backRotation = 0
            }
        }
    }
}

#Preview {
    PlayingCard(suit: .Clubs, face: .Queen)
}



