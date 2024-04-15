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
        VStack {
            HStack {
                PlayerCardView(index:0)
            }
            Spacer()
            HStack {
                PlayerCardView(index:1)
                Spacer()
                PlayerCardView(index:2)
            }
            Spacer()
            HStack {
                PlayerCardView(index:3)
                Spacer()
                PlayerCardView(index:4)
            }
            
        }
        .background {
            Ellipse()
                .frame(width:300, height:500)
                .foregroundStyle(.brown)
        }
        .frame(minWidth: 300, minHeight: 500)
    }
}



#Preview {
    TableView().environmentObject(AppState())
}
