//
//  PlayGameView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct PlayGameView: View {
    @EnvironmentObject var appState : AppState
    
    func isActivePeer() -> Bool {
        return appState.gameController?.activePeer.id ==  appState.UID
    }
    
    @State private var betInput = ""
    @State private var showBetSheet = false
        
        
    var body: some View {
        VStack {
            Text("Play Game")
            HStack {
//                ForEach(appState.communityCards) {card in
//                    
//                }
            }
            Spacer()
            TableView()
            
            Spacer()
            VStack {
                HStack {
                    if appState.clientPeer.cards.count >= 2 {
                                  let firstCard = appState.clientPeer.cards[0]
                                  let secondCard = appState.clientPeer.cards[1]

                        PlayingCard(suit: firstCard.suit, face: firstCard.face)
                        PlayingCard(suit: secondCard.suit, face: secondCard.face)
                              } else {
                                  Text("Not enough cards")
                              }
                    
                }
                HStack {
                    Button {
                        showBetSheet = true
//                        appState.gameController?.bet()
                    } label: {
                        Text("Bet")
                    }
                    
                    Button {
                        appState.gameController?.check()
                    } label: {
                        Text("Check")
                    }
                    Button {
                        appState.gameController?.fold()
                    } label: {
                        Text("Fold")
                    }
                }.disabled(!isActivePeer())
                
            }
            .padding()
            
            
            Spacer()
            
            Button {
                appState.gameController?.endGame()
            } label: {
                Text("END GAME")
            }
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

#Preview {
    PlayGameView().environmentObject(AppState())
}
