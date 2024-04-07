//
//  TableView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/2/24.
//

import SwiftUI


struct TableView: View {
    @EnvironmentObject var appState : AppState
    
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
                
                // Surrounding Circles
                ForEach(0..<appState.connectedPeers.count, id: \.self) { index in
                    PlayerIconView(index: index)
                    .position(x: center.x + radius * cos(CGFloat(index) * 2 * .pi / CGFloat(appState.connectedPeers.count) - .pi / 2.0),
                              y: center.y + radius * sin(CGFloat(index) * 2 * .pi / CGFloat(appState.connectedPeers.count) - .pi / 2.0))
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
            HStack {
                ZStack {
                    Circle()
                        .frame(width: 60)
                        .foregroundStyle(Color(hex: player.playerColor))
                        .padding()
                    
                    if appState.hostPeer?.id == player.id {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Color.secondary)
                    }
                }
                VStack {
                    Text(player.displayName)
                        .foregroundStyle(appState.gameController?.activePeer.id == player.id ? .green : .white)
                    Text("$\(player.money)").foregroundStyle(.white)
                }
            }
           )
       }
       
       var body: some View {
           playerView
       }
}

#Preview {
    TableView().environmentObject(AppState())
}
