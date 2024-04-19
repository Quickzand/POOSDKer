//
//  RoundWinnerView.swift
//  POOSDKer
//
//  Created by Aintzane Perez on 4/15/24.
//

import SwiftUI
import ConfettiSwiftUI

struct RoundWinnerView: View {
    @EnvironmentObject var appState : AppState
    @State private var counter: Int = 0
    
    var body: some View {
        VStack {
            HStack (spacing: 0) {
                Rectangle()
                    .fill(Color(hex: "#CEB064"))
                    .frame(width: 50, height: 90)
                Text(appState.connectedPeers[appState.winnerIndex].displayName + " Wins!")
                    .font(.caption)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .frame(width: 260, height: 80)
                    .background(Color(hex: "#1E5C3A"))
                    .clipShape(RoundedRectangle(cornerRadius: 2))
                    .padding(20)
                    .background(Color(hex: "#F5F2EA"))
                Rectangle()
                    .fill(Color(hex: "#CEB064"))
                    .frame(width: 50, height: 90)
            }
            .confettiCannon(counter: $counter, num: 50, openingAngle: Angle(degrees: 0), closingAngle: Angle(degrees: 360), radius: 200)
            .frame(maxWidth: .infinity)
            .transition(.move(edge: .top)) // Transition from the top
            .animation(.easeInOut(duration: 0.5), value: appState.trackWinnerDisplay) // Apply the animation
            .offset(y: appState.trackWinnerDisplay ? 0 : -100) // Offset to control the slide in effect
            .opacity(appState.trackWinnerDisplay ? 1 : 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Set the delay to 2 seconds
                withAnimation {
                    appState.trackWinnerDisplay = false // This will hide the toast after 2 seconds
                }
            }
        }
        .onChange(of: appState.trackWinnerDisplay) {
            if appState.trackWinnerDisplay {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Set the delay to 2 seconds
                    withAnimation {
                        appState.trackWinnerDisplay = false // This will hide the toast after 2 seconds
                    }
                }
                counter += 1
            }
        }
        .animation(.easeInOut(duration: 0.5), value: appState.trackWinnerDisplay)
        .transition(.move(edge: .top))
    }
}

extension View {
    func roundWinnerView(shown: Bool) -> some View {
        overlay(
            RoundWinnerView()
        )
    }
}

struct RoundWinnerPreview: View {
    @EnvironmentObject var appState : AppState
    @State private var showRoundWinner = false
    
    var body: some View {
        VStack {
            Spacer()
            Button("Testing Button") {
                showRoundWinner.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            Spacer()
        }
        .roundWinnerView(shown: appState.trackWinnerDisplay)
    }
}

#Preview {
    RoundWinnerPreview()
}
