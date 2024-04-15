//
//  ResultsView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var appState : AppState
    
    
    var body: some View {
        VStack {
            HeaderBanner(text: "Results", fullWidth: true)
            List {
                // ForEach - Leaderboard, List Player win points
                // Your Bets/Your Earnings - HStack?
                VStack {
                    Text(appState.getGameWinner().displayName + " Wins!")
                    HStack {
                        VStack {
                            Text("Winner Bets")
                            Text("$" + (String)(appState.getGameWinner().totalBets))
                        }
                        Spacer()
                        VStack {
                            Text("Winner Earnings")
                            Text(
                                "$"+(String)(appState.getGameWinner().money))
                        }
                    }
                }
                .padding(.vertical, 50)
                VStack {
                    Text(appState.clientPeer.displayName + " Stats")
                    HStack {
                        VStack {
                            Text("Your Bets")
                            Text("$" + (String)(appState.clientPeer.totalBets))
                        }
                        Spacer()
                        VStack {
                            Text("Your Earnings")
                            Text("$" + (String)(appState.clientPeer.money))
                        }
                    }
                }
                .padding(.vertical, 50)
            }
            .background(Color(hex: "F5F2EA"))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(hex: "#8AA792"), lineWidth: 4)
            )
            .padding(.all, 20)
            .padding(.bottom, 70)
            .scrollContentBackground(.hidden)
            
            Button {
                appState.showResultsView = false
            } label: {
                Text("Finish")
            }
            .foregroundStyle(.black)
            .frame(width: UIScreen.main.bounds.width*0.5, height: 50, alignment: .center)
            .background(RoundedRectangle(cornerRadius: 5)
                .fill(Color(hex: "F5F2EA"))
                .stroke(Color(hex: "#8AA792"), lineWidth: 3))
            
        }
        .withBackground()
    }
}

#Preview {
    ResultsView()
}
