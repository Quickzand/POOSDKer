//
//  TableView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/2/24.
//

import SwiftUI


struct Player {
   var displayName : String
}

struct TableView: View {
    let players : [Player] = [Player(displayName: "Test"), Player(displayName: "Test2"),Player(displayName: "Test2"),Player(displayName: "Test2"),Player(displayName: "Test2")]
     let radius: CGFloat = 150 // Distance from the center circle
    
     var body: some View {
         GeometryReader { geometry in
             let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
             
             // Central Circle
             Circle()
                 .frame(width: 200)
                 .position(center)
             
             // Surrounding Circles
             ForEach(0..<players.count, id: \.self) { index in
                 ZStack {
                     Circle()
                         .frame(width: 60)
                     Text("Test")
                         .foregroundStyle(Color(.white))
                 }
                 .position(x: center.x + radius * cos(CGFloat(index) * 2 * .pi / CGFloat(players.count) - .pi / 2.0),
                               y: center.y + radius * sin(CGFloat(index) * 2 * .pi / CGFloat(players.count) - .pi / 2.0))
             }
         }
     }
}

#Preview {
    TableView()
}
