//
//  ContentView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/17/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState : AppState
    var body: some View {
        NavigationStack {
                VStack {
                    VStack {
                        Text("POOSDker")
                            .font(.title)
                        Text("Vesion: 0.0.1")
                            .font(.subheadline)
                    }
                    .padding()
                    Spacer()
                    NavigationLink("Host Game", destination: HostGameView())
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    NavigationLink("Join Game", destination: JoinGameView())
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    NavigationLink("Settings", destination: SettingsView())
                        .padding()
                        .background(.regularMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    Spacer()
                    Text("[POOSD @ Spring 2024 || Aintzane Perez Masache, Amy Gonzalez, Gavin Cruz, Matthew Sand, Maximus Smith]").font(.footnote)
                        
                        .padding(.bottom, 0)
                }
                
        }
    }
}

#Preview {
    ContentView()
}
