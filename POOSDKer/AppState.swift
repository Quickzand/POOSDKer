//
//  AppState.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import Foundation


class AppState : ObservableObject {
    @Published var networkingController : NetworkingController = NetworkingController();
    @Published var settings : Settings = Settings()
    
}






