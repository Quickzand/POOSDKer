//
//  TableView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/2/24.
//

import SwiftUI


struct TableView: View {
    @EnvironmentObject var appState : AppState
    
    
    
    // For an actual game we set this to true
    var isPreview = false
    
    
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
                    ZStack {
                        Circle()
                            .frame(width: 60)
                            .foregroundStyle(Color(hex:appState.connectedPeers[index].playerColor))
                        if(hostPeer.id == appState.connectedPeers[index].id) {
                            Image(systemName: "crown.fill")
                                .foregroundStyle(Color.secondary)
                        }
                        Text(appState.connectedPeers[index].displayName)
                            .foregroundStyle(Color(.white))
                    }
                    .position(x: center.x + radius * cos(CGFloat(index) * 2 * .pi / CGFloat(appState.connectedPeers.count) - .pi / 2.0),
                              y: center.y + radius * sin(CGFloat(index) * 2 * .pi / CGFloat(appState.connectedPeers.count) - .pi / 2.0))
                }
            }
        }
    }
}

#Preview {
    TableView().environmentObject(AppState())
}
