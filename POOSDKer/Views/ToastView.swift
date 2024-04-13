//
//  Toast.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/13/24.
//

import SwiftUI

struct ToastView: View {
    enum ToastErrorType: String {
        case lowBet = "Bet Must Meet Current Minimum Bet"
        
        case exceedFunds = "The bet exceeds your funds."
        
        case zeroBet = "Cannot bet 0. Look into checking."
    }
    
    var errorType: ToastErrorType
    @Binding var shown: Bool
    
    var body: some View {
            VStack {
                HStack {
                    Spacer()
                    Text(errorType.rawValue)
                        .font(.caption)
                        .padding()
                        .foregroundColor(.white)
                        .fontWeight(.bold)
                        .background(Color(hex: "#CF8181"))
                        .clipShape(RoundedRectangle(cornerRadius: 25.0))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .transition(.move(edge: .top)) // Transition from the top
                .animation(.easeInOut(duration: 0.5), value: shown) // Apply the animation
                .offset(y: shown ? 0 : -100) // Offset to control the slide in effect
                .opacity(shown ? 1 : 0)
                Spacer()
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Set the delay to 2 seconds
                    withAnimation {
                        shown = false // This will hide the toast after 2 seconds
                    }
                }
            }
            .onChange(of:shown) {
                if shown {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // Set the delay to 2 seconds
                        withAnimation {
                            shown = false // This will hide the toast after 2 seconds
                        }
                    }
                }
            }
    }
}



extension View {
    func toastView(toastErrorType: ToastView.ToastErrorType, shown: Binding<Bool>) -> some View {
        // Overlay the ToastView on any View using this modifier
        overlay(
            ToastView(errorType: toastErrorType, shown: shown)
                .animation(.easeInOut(duration: 0.5), value: shown.wrappedValue)
                .transition(.move(edge: .top))
        )
    }
}


struct ToastPreview: View {
    @State private var showToast = false
    
    var body: some View {
        VStack {
            Spacer()
            Button("Your mother and your father") {
                showToast.toggle()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(Capsule())
            Spacer()
        }
        .toastView(toastErrorType: .zeroBet, shown: $showToast)
    }
}


#Preview {
   ToastPreview()
}
