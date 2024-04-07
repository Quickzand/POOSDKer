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
        
        
    var body: some View {
        VStack {
            Text("Play Game")
            Spacer()
            TableView()
            
            Spacer()
            VStack {
                HStack {
                    Button {
                        appState.gameController?.bet()
                    } label: {
                        Text("Bet")
                    }
                    
                    Button {
                        appState.gameController?.check()
                    } label: {
                        Text("Check")
                    }
                    Button {
                        appState.gameController?.check()
                    } label: {
                        Text("Fold")
                    }
                }.disabled(!isActivePeer())
                
                
//                Text(String(appState.clientPeer.money))
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
    }
}

#Preview {
    PlayGameView().environmentObject(AppState())
}
