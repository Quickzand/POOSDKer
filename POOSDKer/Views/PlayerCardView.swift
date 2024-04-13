//
//  PlayerCardView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/13/24.
//

import SwiftUI



struct PlayerCardView : View{
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
                        .frame(width: 25, height:25)
                        .foregroundStyle(Color(hex: player.playerColor))
                    
                    
                    if appState.hostPeer?.id == player.id {
                        Image(systemName: "crown.fill")
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                Text(player.displayName)
                    .foregroundStyle(appState.gameController?.activePeer.id == player.id ? (Color(hex: player.playerColor)) : .black)
                    .font(.system(size: 14))
                    .fontWeight(.bold)
                    
                
                Spacer()
            }
                if appState.isInGame {
                    VStack (alignment: .leading) {
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("BAL: ")
                                    
                                Text("$\(player.money)")
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(.black, lineWidth: 1)
                                    )
                            }
                            .padding(.bottom, 5)
                               
                            HStack {
                                Text("BET: ")
                                    
                                Text("$\(player.bet)")
                                    .frame(maxWidth: .infinity)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 2)
                                            .stroke(.black, lineWidth: 1)
                                    )
                            }
                            
                            .foregroundStyle(.black)
                        }.opacity(!appState.isInGame ? 0 : 1)
                            .font(.system(size: 14))
                    }
                }
            }
                .frame(width: 150)
                .padding(.all, 8)
                .background(player.isFolded ? .black : Color("OutsetBackground"))
                .border(.black, width: 1)
                .clipShape(RoundedRectangle(cornerRadius: 4))
           )
       }
       
       var body: some View {
           playerView
       }
}

#Preview {
    PlayerCardView(index: 0).environmentObject(AppState())
}
