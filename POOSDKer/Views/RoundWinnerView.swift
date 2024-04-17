//
//  RoundWinnerView.swift
//  POOSDKer
//
//  Created by Aintzane Perez on 4/15/24.
//

import SwiftUI
import ConfettiSwiftUI

struct RoundWinnerView: View {
    @Binding var shown: Bool
    @State private var counter: Int = 0
    
    var body: some View {
        VStack {
            HStack (spacing: 0) {
                Rectangle()
                    .fill(Color(hex: "#CEB064"))
                    .frame(width: 50, height: 90)
                Text("Round Winner")
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
            .animation(.easeInOut(duration: 0.5), value: shown) // Apply the animation
            .offset(y: shown ? 0 : -100) // Offset to control the slide in effect
            .opacity(shown ? 1 : 0)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Set the delay to 2 seconds
                withAnimation {
                    shown = false // This will hide the toast after 2 seconds
                }
            }
        }
        .onChange(of:shown) {
            if shown {
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { // Set the delay to 2 seconds
                    withAnimation {
                        shown = false // This will hide the toast after 2 seconds
                    }
                }
                counter += 1
            }
        }
    }
}

extension View {
    func roundWinnerView(shown: Binding<Bool>) -> some View {
        overlay(
            RoundWinnerView(shown: shown)
                .animation(.easeInOut(duration: 0.5), value: shown.wrappedValue)
                .transition(.move(edge: .top))
        )
    }
}

struct RoundWinnerPreview: View {
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
        .roundWinnerView(shown: $showRoundWinner)
    }
}

#Preview {
    RoundWinnerPreview()
}
