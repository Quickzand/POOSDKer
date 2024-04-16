//
//  NumericKeyboardView.swift
//  POOSDKer
//
//  Created by Amy Gonzalez on 4/15/24.
//

import Foundation
import SwiftUI

struct NumericInputView: View {
    @Binding var numericInput: String
    @EnvironmentObject var appState : AppState
    @FocusState private var isInputFocused: Bool
    @State private var showToast = false
    @State private var toastErrorType: ToastView.ToastErrorType = .zeroBet
    @Binding var shown: Bool
    
    var body: some View {
        VStack{
            Spacer()
            VStack(spacing: 20) {
                Spacer()
                HStack {
                    Spacer()
                    Text("Bet Amount: \(numericInput)")
                        .frame(minWidth: 100, alignment: .trailing)
                        .font(.system(size:30))
                    
                    Spacer()
                    Button("Bet!") {
                        if isBetValid() {
                            appState.gameController?.bet(value: Int(numericInput) ?? 0)
                            numericInput = ""
                            shown = false
                        } else {
                            print("Invalid bet...")
                        }
                        
                    }
                    .foregroundStyle(.black)
                    .font(.system(size:40))
                    .frame(width: 100, height: 60) // Standard size for all buttons
                    .background(Color.red.opacity(0.5)) // Button color
                    .cornerRadius(10) // Rounded corners
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2))
                    
                }
                
                // Numeric keypad layout for numbers 1 to 9
                VStack(spacing: 10) {
                    ForEach(0..<3) { row in
                        HStack(spacing: 50) {
                            ForEach(1..<4) { column in
                                Button("\(row * 3 + column)") {
                                    numericInput += "\(row * 3 + column)"
                                }
                                .foregroundStyle(.black)
                                .font(.system(size:40))
                                .frame(width: 100, height: 60) // Standard size for all buttons
                                .background(Color.white.opacity(0.6)) // Button color
                                .cornerRadius(10) // Rounded corners
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2) // Border details
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
                    .foregroundStyle(.black)
                    .font(.system(size:40))
                    .frame(width: 100, height: 60)
                    .background(Color.white.opacity(0.6))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                    )
                    Spacer()
                }
                
                // Cancel and Delete buttons
                cancelAndDelete
                
                Spacer()
            }
            .padding()
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isInputFocused = true
                    
                }
            }
            .toastView(toastErrorType: toastErrorType, shown: $showToast)
            .withBackground()
            .opacity(shown ? 1 : 0)
        }
    }
    
    var cancelAndDelete : some View {
        HStack {
            Button("Cancel") {
                shown = false
            }
            .padding()
            .foregroundStyle(.black)
            .font(.system(size:40))
            Spacer()
            Button {
                if !numericInput.isEmpty {
                    numericInput.removeLast()
                }
            } label:  {
                Image(systemName: "delete.left")
            }
            
            .padding()
            .foregroundStyle(.black)
            .font(.system(size:40))
        }
    }
    
    
    func isBetValid() -> Bool{
        if let bet = Int(numericInput) {
            if bet == 0 {
                toastErrorType = .zeroBet
                print("Zero bet detected")
                showToast = true
                return false
            }
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
    
    extension View {
        func KeyboardView(numericInput: Binding<String>,shown: Binding<Bool>) -> some View {
            // Overlay the ToastView on any View using this modifier
            overlay(
                NumericInputView(numericInput: numericInput, shown: shown)
                    .animation(.easeInOut(duration: 0.5), value: shown.wrappedValue)
                    .transition(.move(edge: .top))
            )
        }
    }
    

