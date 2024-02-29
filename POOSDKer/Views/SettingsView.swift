//
//  Settings.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState : AppState
    var body: some View {
        VStack {
            
            TextField("Display Name", text: $appState.settings.displayName)
                .frame(maxWidth:.infinity)
                .multilineTextAlignment(.center)
        }
        
    }
}

#Preview {
    SettingsView().environmentObject(AppState())
}
