//
//  LobbyView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct LobbyView: View {
    var body: some View {
        VStack {
            Text("Lobby")
            VStack {
                TableView()
            }
            NavigationLink("Play Game", destination: PlayGameView())
        }
    }
}

#Preview {
    LobbyView()
}
