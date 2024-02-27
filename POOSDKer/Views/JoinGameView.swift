//
//  JoinGame.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct JoinGameView: View {
    var body: some View {
        VStack {
            Text("Join Game")
            NavigationLink("Lobby", destination: LobbyView())
        }
    }
}

#Preview {
    JoinGameView()
}
