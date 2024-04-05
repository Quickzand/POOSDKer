//
//  DemonstrationView.swift
//  POOSDKer
//
//  Created by Matthew Sand on 4/4/24.
//

import SwiftUI

struct DemonstrationView: View {
    @State var Count : Int = 0
    
    
    var body: some View {
        HStack {
            Text(String(Count))
            
            
            Button {
                Count += 1
                
            } label: {
                Text("Add 1")
            }
        }
    }
}

#Preview {
    DemonstrationView()
}
