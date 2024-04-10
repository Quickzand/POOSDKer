//
//  POOSDKerApp.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/17/24.
//

import SwiftUI

@main
struct POOSDKerApp: App {
    @StateObject private var appState = AppState()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .onAppear {
                    
                    var hand2 = [CardModel(suit: .Clubs, face: .Ace),CardModel(suit: .Spades, face: .Queen),CardModel(suit: .Hearts, face: .Jack),CardModel(suit: .Clubs, face: .King),CardModel(suit: .Clubs, face: .Ten), CardModel(suit: .Spades, face: .Queen),CardModel(suit: .Clubs, face: .Queen)]

                    var hand1 = [CardModel(suit: .Spades, face: .Two),CardModel(suit: .Clubs, face: .Seven),CardModel(suit: .Clubs, face: .Nine),CardModel(suit: .Clubs, face: .King),CardModel(suit: .Clubs, face: .Queen),CardModel(suit: .Clubs, face: .Queen),CardModel(suit: .Clubs, face: .Queen)]


                    print(compareHands(hand1: hand1, hand2: hand2))
                    
                }
        }
    }
}
