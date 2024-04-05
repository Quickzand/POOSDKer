//
//  PlayGameView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct PlayGameView: View {
    @EnvironmentObject var appState : AppState
    var body: some View {
        VStack {
            Text("Play Game")
            
            Button {
                appState.networkingController?.broadcastEndGame()
            } label: {
                Text("END GAME")
            }
        }
    }
}

#Preview {
    PlayGameView()
}
