//
//  PlayGameView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//  Edited by Maximus Smith on 4/13/24.

import SwiftUI

struct PlayGameView: View {
    @EnvironmentObject var appState : AppState
    
    func isActivePeer() -> Bool {
        return appState.gameController?.activePeer.id ==  appState.UID
    }
    @State private var numericInput: String = ""
    @State private var isInputFocused: Bool = false
    @State private var betInput = ""
    @State private var showBetSheet = false
    @State private var hueRotation = 0.0

    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()


    func isCheckValid() -> Bool{
        guard appState.connectedPeers.indices.contains(appState.activePeerIndex) else { return false}
        return true
        // check if MaxBet - currentBet > UserMoney -> disable check button
        if(appState.currentHighestBet - appState.connectedPeers[appState.activePeerIndex].bet
           > appState.connectedPeers[appState.activePeerIndex].money){
            return false
        }
        return true;
    }
        
    var body: some View {

        VStack {
            HStack {
                ForEach(appState.communityCards, id: \.self) {cardModel in
                    PlayingCard(suit: cardModel.suit, face: cardModel.face)
                        .frame(width:50)
                        .font(.system(size: 16))
                    
                }
            }
            .frame(height:125)
            .padding(.top, 75)
            HStack {
                VStack {
                    Text("Balance")
                    Text("$\(appState.clientPeer.money)")
                }
                .frame(maxWidth: .infinity)
                .background(Color("OutsetBackground"))
                .clipShape(RoundedRectangle(cornerRadius: 15.0))
                .padding(.horizontal, 0.25)
                .padding(.top, 4)
                .shadow(color: isActivePeer() ? Color.blue.opacity(0.7) : Color.clear, radius: isActivePeer() ? 10 : 0, x: 0, y: 0) // This line makes the button glow conditionally
                .hueRotation(Angle(degrees: hueRotation)) // This line rotates the hue of the button's color
                .onReceive(timer) { _ in
                    if isActivePeer() {
                        hueRotation += 10
                        if hueRotation >= 360 {
                            hueRotation = 0
                        }
                    }
                    
                }
                
                VStack {
                    Text("Pot")
                    Text("$\(appState.totalPot)")
                }.frame(maxWidth: .infinity)
                    .background(Color("OutsetBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    .padding(.horizontal, 0.25)
                    .padding(.top, 4)
                    .shadow(color: isActivePeer() ? Color.blue.opacity(0.7) : Color.clear, radius: isActivePeer() ? 10 : 0, x: 0, y: 0) // This line makes the button glow conditionally
                    .hueRotation(Angle(degrees: hueRotation)) // This line rotates the hue

            }
            .padding(.top, 5)
      
            ZStack {
                TableView()
                VStack {
                    Spacer()
                    HStack {
                        if appState.clientPeer.cards.count >= 2 {
                            let firstCard = appState.clientPeer.cards[0]
                            let secondCard = appState.clientPeer.cards[1]
                            
                            PlayingCard(suit: firstCard.suit, face: firstCard.face)
                                .frame(width:50)
                                .rotationEffect(Angle(degrees: -10))
                            PlayingCard(suit: secondCard.suit, face: secondCard.face)
                                .frame(width:50)
                                .rotationEffect(Angle(degrees: 10))
                        } else {
                            Text("Not enough cards")
                        }
                        
                    }
                    .offset(y:100)
                }
            }
            
            Spacer()
            VStack {
                HStack {
                    Button {
                        showBetSheet = true
                    } label: {
                        Text("Bet")
                            .padding()
                            .background(Color("OutsetBackground"))
                    }
                    
                    Button {
                        // check implementation
                        if(isCheckValid()){
                            // bets the difference between the current highest bet and the current peer's bet
                            appState.gameController?.bet(value: appState.currentHighestBet - appState.connectedPeers[appState.activePeerIndex].bet)
                        }else{
                            print("Poor person detected...") // poor person detected
                        }

                    } label: {
                        Text("Check")
                            .padding()
                            .background(Color("OutsetBackground"))
                    }.disabled(!isCheckValid()) // disables button if check is not valid
                    Button {
                        appState.gameController?.fold()
                    } label: {
                        Text("Fold")
                            .padding()
                            .background(Color("OutsetBackground"))
                    }
                }.disabled(!isActivePeer())
                    .padding(.bottom, 30)
                    .cornerRadius(10)
                    // set height
                    .frame(height: 10)
                    .shadow(color: isActivePeer() ? Color.blue.opacity(0.5) : Color.clear, radius: isActivePeer() ? 10 : 0, x: 0, y: 0) // This line makes the button glow conditionally
                    .hueRotation(Angle(degrees: hueRotation)) // This line rotates the hue
                    .padding()
            }
            .padding()
            
        }
        .withBackground()
        .KeyboardView(numericInput: $betInput, shown: $showBetSheet)
        .roundWinnerView(shown: appState.trackWinnerDisplay)
    }
}

//#Preview {
//    PlayGameView().environmentObject(AppState())
//}
