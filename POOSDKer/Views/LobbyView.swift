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
            NavigationLink("Play Game", destination: PlayGameView())
        }
    }
}

#Preview {
    LobbyView()
}
