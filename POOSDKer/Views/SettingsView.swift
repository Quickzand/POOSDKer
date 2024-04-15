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
    @State var selectedPlayerIcon : String = ""
    let textLim = 1
    
    var body: some View {
        VStack {
            HeaderBanner(text:"Settings", fullWidth: true)
                .padding(.bottom, 10)
            
            HStack {
                Text("Player Name:")
                    .padding(.leading, 30)
                    .foregroundStyle(Color(hex: "F5F2EA"))
                
                TextField("Player Display Name", text: $appState.settings.displayName)
                    .textFieldStyle(DisplayNameTextField())
                    .padding(.trailing, 20)
            }
            
            HStack {
                Text("Player Background Color: ")
                    .padding(.leading, 30)
                    .foregroundStyle(Color(hex: "F5F2EA"))
                
                ColorPicker("", selection: $selectedPlayerColor)
                    .padding(.trailing, 200)
            }
            
            HStack {
                Text("Player Icon: ")
                    .padding(.leading, 30)
                    .foregroundStyle(Color(hex: "F5F2EA"))
                
                // Emoji Picker
                TextField("Icon", text: $selectedPlayerIcon)
                    .textFieldStyle(PlayerIconTextField())
                    .padding(.trailing, 20)
                    .onChange(of: selectedPlayerIcon) {
                        selectedPlayerIcon = String(selectedPlayerIcon.prefix(1))
                    }
            }
            
            
            Spacer()
        }.onChange(of: selectedPlayerColor) {
            appState.settings.playerColor = selectedPlayerColor.toHexString()
        }.onAppear {
            selectedPlayerColor = Color(hex:appState.settings.playerColor)
        }.onChange(of: selectedPlayerIcon) {
            appState.settings.playerIcon = selectedPlayerIcon
        }.onAppear {
            selectedPlayerIcon = appState.settings.playerIcon
        }
        
        .withBackground()
    }
}

// Text Field Style for Player Name textfield
struct DisplayNameTextField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(Color(hex: "F5F2EA"))
                    .stroke(Color.black, lineWidth: 1)
            ).padding(.trailing, 20)
    }
}

// Text Field Style for Player Icon textfield
struct PlayerIconTextField: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .size(width: 50.0, height: 40)
                    .fill(Color(hex: "F5F2EA"))
                    .stroke(Color.black, lineWidth: 1)
            ).padding(.trailing, 20)
    }
}


#Preview {
    SettingsView().environmentObject(AppState())
}
