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
    
    @State private var betInput = ""
    @State private var showBetSheet = false

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
            HStack {
                VStack {
                    Text("Balance")
                    Text("$\(appState.clientPeer.money)")
                }
    
            }
//            .padding(.top, 250)
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
//                            .background(Color("OutsetBackground"))
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
                
            }
            .padding()
            
        }
        .withBackground()
        .sheet(isPresented: $showBetSheet) {
            NumericInputView(numericInput: $betInput)
        }
    }
}

struct NumericInputView: View {
    @Binding var numericInput: String
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var appState : AppState
    @FocusState private var isInputFocused: Bool
    
    
    var body: some View {
        VStack {
            TextField("Enter number", text: $numericInput)
                           .keyboardType(.numberPad)
                           .focused($isInputFocused)
                           .padding()
                       
            
            Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            }
            Button("Done") {
                if(isBetValid()) {
                    appState.gameController?.bet(value: Int(numericInput) ?? 0)
                    presentationMode.wrappedValue.dismiss()
                }
                else {
                    print("Invalid bet...")
                }
            }
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { // Adjust the delay as needed
                isInputFocused = true
            }
        }
    }
    
    
    func isBetValid() -> Bool{
        if let bet = Int(numericInput) {
            if bet == 0 || bet < appState.currentHighestBet - appState.connectedPeers[appState.activePeerIndex].bet || bet > appState.connectedPeers[appState.activePeerIndex].money {
                return false
            }
            return true
        }
        else {
            return false
        }
      
    }
    
    
}

//#Preview {
//    PlayGameView().environmentObject(AppState())
//}
