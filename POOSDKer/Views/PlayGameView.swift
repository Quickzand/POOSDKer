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
                .padding(.horizontal, 1)
                    .padding(.top, 4)
                
                VStack {
                    Text("Pot")
                    Text("$\(appState.getTotalPot())")
                }.frame(maxWidth: .infinity)
                    .background(Color("OutsetBackground"))
                    .clipShape(RoundedRectangle(cornerRadius: 15.0))
                    .padding(.horizontal, 1)
                        .padding(.top, 4)
                    

            }
      
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
    @State private var showToast = false
    @State private var toastErrorType: ToastView.ToastErrorType = .zeroBet
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            HStack {
                Spacer()
                Text("Bet Amount: \(numericInput)")
                    .frame(minWidth: 100, alignment: .trailing)
                Spacer()
                Button("Bet!") {
                    if isBetValid() {
                        print("++ \(appState.activePeerIndex)")
                        appState.gameController?.bet(value: Int(numericInput) ?? 0)
                        numericInput = ""
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Invalid bet...")
                    }
                }
                .padding(.horizontal)
            }

            // Numeric keypad layout for numbers 1 to 9
            VStack(spacing: 10) {
                ForEach(0..<3) { row in
                    HStack(spacing: 10) {
                        ForEach(1..<4) { column in
                            Button("\(row * 3 + column)") {
                                numericInput += "\(row * 3 + column)"
                            }
                            .frame(width: 60, height: 60) // Standard size for all buttons
                            .background(Color.gray.opacity(0.2)) // Button color
                            .cornerRadius(10) // Rounded corners
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.green, lineWidth: 2) // Border details
                            )
                        }
                    }
                }
            }

            // Button for number 0, centered
            HStack {
                Spacer()
                Button("0") {
                    numericInput += "0"
                }
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.green, lineWidth: 2)
                )
                Spacer()
            }
            
            // Cancel and Delete buttons
            HStack {
                Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding()
                Spacer()
                Button("Delete") {
                    if !numericInput.isEmpty {
                        numericInput.removeLast()
                    }
                }
                .padding()
            }
            Spacer()
        }
        .padding()
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isInputFocused = true
            }
        }
        .toastView(toastErrorType: toastErrorType, shown: $showToast)
    }

    
    func isBetValid() -> Bool{
        if let bet = Int(numericInput) {
            if bet == 0 {
                toastErrorType = .zeroBet
                print("Zero bet detected")
                showToast = true
                return false
            }
            print(appState.activePeerIndex)
            if bet < appState.currentHighestBet - appState.connectedPeers[appState.activePeerIndex].bet{
                toastErrorType = .lowBet
                print("Low bet detected")
                showToast = true
                return false
            }
            if bet > appState.connectedPeers[appState.activePeerIndex].money {
                toastErrorType = .exceedFunds
                print("Poor person detected")
                showToast = true
                return false
            }
            showToast = false
            return true
        }
        else {
            showToast = false
            return false
        }
      
    }
    
    
}

//#Preview {
//    PlayGameView().environmentObject(AppState())
//}
