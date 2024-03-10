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
        ZStack {
            NavigationStack {
                VStack {
                titleCard
                    
                    Spacer()
                    NavigationLink("Host Game", destination: HostGameView())
                        .padding()
                        .background(Color("OutsetBackground"))
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    NavigationLink("Join Game", destination: JoinGameView())
                        .padding()
                        .background(Color("OutsetBackground"))
                        .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                        NavigationLink("Settings", destination: SettingsView())
                            .padding()
                            .background(Color("OutsetBackground"))
                            .foregroundColor(.black)
                        .clipShape(RoundedRectangle(cornerRadius: 10.0))
                    Spacer()
                    Text("[POOSD @ Spring 2024 || Aintzane Perez Masache, Amy Gonzalez, Gavin Cruz, Matthew Sand, Maximus Smith]").font(.footnote)
                    
                        .padding(.bottom, 0)
                }
                .frame(maxWidth:.infinity)
                .background(BackgroundView())
            }
        }
        
    }
    
    
    var titleCard : some View {
        HStack {
            Text("POOSDKER")
                .padding()
                .background(Color("OutsetBackground"))
        }
    }
}

#Preview {
    ContentView()
}
