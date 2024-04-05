//
//  ResultsView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var appState : AppState
    
    var body: some View {
        VStack {
            Text("Results")
            Button {
                appState.showResultsView = false
            } label: {
                Text("Finish")
            }
        }
    }
}

#Preview {
    ResultsView()
}
