//
//  NetworkingController.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import Foundation
import MultipeerConnectivity

class NetworkingController: NSObject,ObservableObject, MCNearbyServiceAdvertiserDelegate {
    
    var appState : AppState
    
    
    
    var mcSession: MCSession!
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!
    let serviceType = "poosdker"
    
    init(appState: AppState) {
        self.appState = appState
        super.init()
        
        // Setup peer and session
        self.appState.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.mcSession = MCSession(peer: appState.peerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self
        
        
        // Setup browser
        self.serviceBrowser = MCNearbyServiceBrowser(peer: appState.peerID, serviceType: serviceType)
        self.serviceBrowser.delegate = self
    }
    
    func sendData(_ data: Data) {
        guard !mcSession.connectedPeers.isEmpty else { return }
        
        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch let error {
            print("Error sending data: \(error.localizedDescription)")
        }
    }
    
    func sendDataToAllPeers(_ data: Data) {
        guard !mcSession.connectedPeers.isEmpty else { return }
        
        do {
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("Error sending data to all peers: \(error)")
        }
    }
    
    func updateAndBroadcastConnectedUsers() {
        let connectedPeers = mcSession.connectedPeers.map { $0.displayName }
        
        // Encode the list of connected peer names into Data
        do {
            let data = try JSONEncoder().encode(connectedPeers)
            sendDataToAllPeers(data)
        } catch {
            print("Error encoding connected peers: \(error)")
        }
    }
    
    
    
    
    
    func startHosting() {
        print("Starting hosting...")
        // Setup advertiser with discovery info including both displayName and a unique ID
        let discoveryInfo = ["displayName": appState.settings.displayName, "hostID": self.appState.UID]
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: appState.peerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        self.serviceAdvertiser.delegate = self
        appState.connectedPeers = []
        appState.connectedPeers.append(Peer(id: appState.UID, displayName: appState.settings.displayName, playerColor: appState.settings.playerColor, mcPeerID:appState.peerID))
        appState.hostPeer = appState.connectedPeers[0]
        serviceAdvertiser.startAdvertisingPeer()
        
        
     
    }
    
    func stopHosting() {
        print("Stopping hosting...")
        serviceAdvertiser.stopAdvertisingPeer()
        appState.hostPeer = nil
    }
    
    func startBrowsing() {
        print("Starting browsing...")
        appState.discoveredPeers = []
        serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        print("Stopping browsing...")
        serviceBrowser.stopBrowsingForPeers()
    }
    
    
    func requestToJoinHost(hostPeer: Peer) {
        let infoToSend = ["displayName": appState.settings.displayName, "id": appState.UID, "playerColor": appState.settings.playerColor]
        if let peerID = hostPeer.mcPeerID {
            if let context = try? JSONEncoder().encode(infoToSend) {
                serviceBrowser.invitePeer(peerID, to: mcSession, withContext: context, timeout: 30)
                appState.hostPeer = hostPeer;
            }
        }
        else {
            print("Attempting to connect to host without knowledge of mcPeerID")
        }
    }
    
    
    func disconnectFromHost() {
        mcSession.disconnect()
        appState.hostPeer = nil;
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if let context = context, let receivedInfo = try? JSONDecoder().decode([String: String].self, from: context) {
            // Now you have the additional info
            if let displayName = receivedInfo["displayName"], let uniqueID = receivedInfo["id"], let playerColor = receivedInfo["playerColor"] {
                self.appState.connectedPeers.append(Peer(id: uniqueID, displayName: displayName, playerColor: playerColor, mcPeerID: peerID))
                print("Connecting user with name: " + displayName)
            }
        }
        
        // You can decide whether to accept the invitation based on the received information
        invitationHandler(true, mcSession)
    }
    
    
    
    
    struct BroadcastData: Decodable {
        let commandType: String
        let peers: [Peer]?
    }
    
    
//    MARK: All types of commands that can be sent
    enum BroadcastCommandType : String {
        case shareConnectedPeerList = "sharePeerList"
        case startGame = "startGame"
    }
    
    
    func broadcastCommandToPeers(broadcastCommandType: BroadcastCommandType) {
        var broadcastData: [String: Any] = [:] // Change to [String: Any] to handle various data types
        broadcastData["commandType"] = broadcastCommandType.rawValue
        
        switch broadcastCommandType {
        case .shareConnectedPeerList:
            // Prepare the list of peers to be shared
            let peersToSend = appState.connectedPeers.map {
                ["id": $0.id, "displayName": $0.displayName, "playerColor": $0.playerColor]
            }
            broadcastData["peers"] = peersToSend
            print("Sharing peer list...")
            
        case .startGame:
            print("Starting game...")
            // Additional command-specific data can be added here if necessary
            
        default:
            print("Unrecognized Command")
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: broadcastData, options: [])
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("Error encoding or sending command: \(error)")
        }
    }
    
    func getUserDataFromPeerID(peerID: MCPeerID) -> Peer?  {
        return self.appState.connectedPeers.first(where: {peer in
            return peer.mcPeerID == peerID
        })
    }
    
    
    
    

 
}



extension NetworkingController : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info {
            let displayName = info["displayName"] ?? "Unknown"
            let hostID = info["hostID"] ?? "UnknownID"
            let playerColor = info["playerColor"] ?? "UnknownID"
            
            print("Discovered a peer: \(displayName) with ID: \(hostID)")
            if(!self.appState.discoveredPeers.contains(where: {tempPeer in
                return tempPeer.id == hostID
            })) {
                print("Discovered host ")
                self.appState.discoveredPeers.append(Peer(id: hostID, displayName: displayName, playerColor: playerColor, mcPeerID: peerID))
            }
            
        }
    }

    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            self.appState.discoveredPeers.removeAll { $0.mcPeerID == peerID }
        }
    }
    
}


// All session control code
extension NetworkingController : MCSessionDelegate {
    
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        DispatchQueue.main.async {
            switch state {
            case .connected:
                print("Connected: \(peerID.displayName)")
                if self.appState.isHost {
                    self.broadcastCommandToPeers(broadcastCommandType: .shareConnectedPeerList)
                             }
            case .connecting:
                print("Connecting: \(peerID.displayName)")
            case .notConnected:
                if let disconnectingUser = self.getUserDataFromPeerID(peerID: peerID) {
                    print("Not Connected: \(disconnectingUser.displayName)")
                }
                else {
                    print("Unknown user disconnecting....")
                }
                
                self.appState.connectedPeers.removeAll { $0.mcPeerID == peerID }
                self.broadcastCommandToPeers(broadcastCommandType: .shareConnectedPeerList)
            @unknown default:
                fatalError("Unknown state received: \(state)")
            }
        }
    }
      
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            do {
                // Decode the data into your structured format
                let decodedData = try JSONDecoder().decode(BroadcastData.self, from: data)
                
                // Handle the command based on the commandType
                switch decodedData.commandType {
                case BroadcastCommandType.shareConnectedPeerList.rawValue:
                    if let peers = decodedData.peers {
                        // Update your app state with the decoded peers
                        self.appState.connectedPeers = peers
                        print("Updated peer list received.")
                    }
                    
                case BroadcastCommandType.startGame.rawValue:
                    print("Start game command received.")
                    self.appState.isInGame = true
                    
                default:
                    print("Unrecognized command received.")
                }
                
            } catch {
                print("Error decoding received data: \(error)")
            }
        }
    }
    
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("Here")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("Here")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("Here")
    }
    
}


struct Peer: Identifiable, Codable {
    var id: String // Use a unique identifier that you can match with MCPeerID.displayName
    var displayName: String
    var playerColor : String
    var mcPeerID: MCPeerID?

    // Since MCPeerID is not Codable, we exclude it from the encoding process
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
        case playerColor
    }

    // Initialize with MCPeerID optionally
    init(id: String, displayName: String, playerColor: String , mcPeerID: MCPeerID? = nil) {
        self.id = id
        self.displayName = displayName
        self.playerColor = playerColor
        self.mcPeerID = mcPeerID
    }
}
