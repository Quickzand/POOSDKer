//
//  TableView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/2/24.
//

import SwiftUI

struct TableView: View {
    @EnvironmentObject var appState: AppState
    
    let radius: CGFloat = 150 // Distance from the center circle
    
    var body: some View {
        if let hostPeer = appState.hostPeer {
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                
                // Central Circle
                Circle()
                    .frame(width: 200)
                    .position(center)
                    .foregroundStyle(Color("OutsetBackground"))
                
                // Calculate position for the first player (bottom left)
                let firstPlayerPosition = CGPoint(x: center.x - radius+50, y: center.y + radius)
                
                // Display the first player
                PlayerIconView(index: 0)
                    .position(firstPlayerPosition)
                
                // Position subsequent players to the right of the table then left
                ForEach(1..<appState.connectedPeers.count, id: \.self) { index in
                    // Calculate position based on index
                    let playerX = center.x + CGFloat(index) * radius
                    let playerY = center.y - radius
                    PlayerIconView(index: index)
                        .position(x: playerX, y: playerY)
                }
            }
        }
    }
}



struct PlayerIconView : View{
    @EnvironmentObject var appState : AppState
    var index : Int
    
    func isActivePeer() -> Bool {
        return appState.gameController?.activePeer.id ==   appState.connectedPeers[index].id
    }
    
    
    private var playerView: some View {
           guard appState.connectedPeers.indices.contains(index) else { return AnyView(EmptyView()) }
           let player = appState.connectedPeers[index]

           return AnyView(
            VStack {
            HStack {
                ZStack {
                    
                    Circle()
                        .frame(width: 40)
                        .foregroundStyle(Color(hex: player.playerColor))
                    
                    
                    if appState.hostPeer?.id == player.id {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Text(player.displayName)
                    .foregroundStyle(appState.gameController?.activePeer.id == player.id ? (Color(hex: player.playerColor)) : .white)
            }
                VStack (alignment: .leading) {
                    
                    VStack(alignment: .leading) {
                        Text(" Money: $\(player.money) ").foregroundStyle(.black)
                            //.padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.black, lineWidth: 2)
                            )
                        
                        Text(" Bet: $\(player.bet) ").foregroundStyle(.black)
                            //.padding()
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.black, lineWidth: 2)
                            )
                    }.opacity(!appState.isInGame ? 0 : 1)
                }
            }
                .background(player.isFolded ? .black : .white)
           )
       }
       
       var body: some View {
           playerView
       }
}

#Preview {
    TableView().environmentObject(AppState())
}
