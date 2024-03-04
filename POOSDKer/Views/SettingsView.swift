//
//  Settings.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState : AppState
     
    @State var selectedPlayerColor : Color = .black
    
    var body: some View {
        VStack {
            TextField("Display Name", text: $appState.settings.displayName)
                .frame(maxWidth:.infinity)
                .multilineTextAlignment(.center)
            
            
            HStack {
                Spacer()
                Text("Player Color: ")
                Spacer()
                ColorPicker("", selection: $selectedPlayerColor)
                Spacer()
            }
        }.onChange(of: selectedPlayerColor) {
            appState.settings.playerColor = selectedPlayerColor.toHexString()
        }
        .onAppear {
            selectedPlayerColor = Color(hex:appState.settings.playerColor)
        }
        
        
        
        
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
