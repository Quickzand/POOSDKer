//
//  BackgroundView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 3/10/24.
//

import SwiftUI

struct BackgroundView: View {
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [Color(hex: "#1E5C3A"), Color(hex: "#1E7C5A")]), startPoint: .top, endPoint: .bottom)
                           // Your noise texture image
                           Image("feltNoise")
                .resizable(resizingMode: .tile)
                
                               .opacity(0.35) // Adjust the opacity as needed
                               .blendMode(.softLight)
        
        }
        .frame(maxWidth:.infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    BackgroundView()
}
