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
                VStack(alignment:.center) {
                    Spacer()
                    VStack {
                        titleCard
                            .padding(.bottom, 30)
                            .padding(.top, -60)
                        VStack {
                            VStack {
                                NavigationLink("Host Game", destination: HostGameView())
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("OutsetBackground"))
                                    .foregroundColor(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                    .padding(.vertical, 10)
                                NavigationLink("Join Game", destination: JoinGameView())
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color("OutsetBackground"))
                                    .foregroundColor(.black)
                                    .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                    .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                            }
                            NavigationLink("Settings", destination: SettingsView())
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color("OutsetBackground"))
                                .foregroundColor(.black)
                                .clipShape(RoundedRectangle(cornerRadius: 10.0))
                                .shadow(radius: /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                                .padding(.vertical, 30)
                                
                        }
                        .frame(width: 200)
                        .padding(.vertical)
                            
                    }
                    Spacer()
                    Text("[POOSD @ Spring 2024 || Aintzane Perez Masache, Amy Gonzalez, Gavin Cruz, Matthew Sand, Maximus Smith]").font(.footnote)
                    
                        .padding(.bottom, 0)
                }
                .frame(maxWidth:.infinity)
                .withBackground()
            }
        }
        
    }
    
    
    var titleCard : some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
            titleCardBorder
            HeaderBanner(text:"POOSDKER")
            titleCardBorder
        }

    }
    
    
    
    var titleCardBorder : some View {
        HStack {
            Image(systemName: Suit.Diamonds.rawValue)
                .foregroundColor(Color("Diamonds"))
            Image(systemName: Suit.Hearts.rawValue)
                .foregroundColor(Color("Hearts"))
            Image(systemName: Suit.Clubs.rawValue)
                .foregroundColor(Color("Clubs"))
            Image(systemName: Suit.Spades.rawValue)
                .foregroundColor(Color("Spades"))
            Image(systemName: Suit.Diamonds.rawValue)
                .foregroundColor(Color("Diamonds"))
            Image(systemName: Suit.Hearts.rawValue)
                .foregroundColor(Color("Hearts"))
            Image(systemName: Suit.Clubs.rawValue)
                .foregroundColor(Color("Clubs"))
            Image(systemName: Suit.Spades.rawValue)
                .foregroundColor(Color("Spades"))
            Image(systemName: Suit.Diamonds.rawValue)
                .foregroundColor(Color("Diamonds"))
            Image(systemName: Suit.Hearts.rawValue)
                .foregroundColor(Color("Hearts"))

      
        }
        .font(.system(size: 20))
    }
}

#Preview {
    ContentView()
}
