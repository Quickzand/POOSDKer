//
//  HostGame.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct HostGameView: View {
    var body: some View {
        VStack {
            Text("Host game")
            NavigationLink("Lobby", destination: LobbyView())
        }
    }
}

#Preview {
    HostGameView()
}
