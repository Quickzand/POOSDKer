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
        
        // Generate or retrieve a unique identifier for the host
        let hostID = "someUniqueIdentifier" // This should be uniquely generated or retrieved
        
        // Setup advertiser with discovery info including both displayName and a unique ID
        let discoveryInfo = ["displayName": appState.peerID.displayName, "hostID": hostID]
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: appState.peerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        self.serviceAdvertiser.delegate = self
        
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
        appState.connectedPeers = []
        appState.connectedPeers.append(Peer(id: appState.UID, displayName: appState.settings.displayName, mcPeerID:appState.peerID))
        appState.isHost = true
        serviceAdvertiser.startAdvertisingPeer()
     
    }
    
    func stopHosting() {
        print("Stopping hosting...")
        serviceAdvertiser.stopAdvertisingPeer()
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
    
    
    func invitePeer(_ peer: MCPeerID) {
        appState.isHost = false
        let infoToSend = ["displayName": UIDevice.current.name, "id": appState.UID]
        if let context = try? JSONEncoder().encode(infoToSend) {
            serviceBrowser.invitePeer(peer, to: mcSession, withContext: context, timeout: 30)
        }
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        if let context = context, let receivedInfo = try? JSONDecoder().decode([String: String].self, from: context) {
            // Now you have the additional info
            if let displayName = receivedInfo["displayName"], let uniqueID = receivedInfo["id"] {
                self.appState.connectedPeers.append(Peer(id: uniqueID, displayName: displayName, mcPeerID: peerID))
                print("Connecting user with id: " + uniqueID)
            }
        }
        
        // You can decide whether to accept the invitation based on the received information
        invitationHandler(true, mcSession)
    }
    
    
    // !! It may make sense in the future to abstract out the process of broadcasting
    func broadcastConnectedPeersList() {
        let peersToSend = appState.connectedPeers.map { Peer(id: $0.id, displayName: $0.displayName) }
        do {
            let data = try JSONEncoder().encode(peersToSend)
            try mcSession.send(data, toPeers: mcSession.connectedPeers, with: .reliable)
        } catch {
            print("Error encoding or sending peers: \(error)")
        }
    }
 
}



extension NetworkingController : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        if let info = info {
            let displayName = info["displayName"] ?? "Unknown"
            let hostID = info["hostID"] ?? "UnknownID"
            
            print("Discovered a peer: \(displayName) with ID: \(hostID)")
            if(!self.appState.discoveredPeers.contains(where: {tempPeer in
                return tempPeer.id == hostID
            })) {
                self.appState.discoveredPeers.append(Peer(id: hostID, displayName: displayName, mcPeerID: peerID))
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
                                 self.broadcastConnectedPeersList()
                             }
            case .connecting:
                print("Connecting: \(peerID.displayName)")
            case .notConnected:
                print("Not Connected: \(peerID.displayName)")
                self.appState.connectedPeers.removeAll { $0.mcPeerID == peerID }
                self.broadcastConnectedPeersList()
            @unknown default:
                fatalError("Unknown state received: \(state)")
            }
        }
    }
      
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        DispatchQueue.main.async {
            do {
                let decodedPeers = try JSONDecoder().decode([Peer].self, from: data)
                self.appState.connectedPeers = decodedPeers
            } catch {
                print("Error decoding peer data: \(error)")
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
    var mcPeerID: MCPeerID?

    // Since MCPeerID is not Codable, we exclude it from the encoding process
    enum CodingKeys: String, CodingKey {
        case id
        case displayName
    }

    // Initialize with MCPeerID optionally
    init(id: String, displayName: String, mcPeerID: MCPeerID? = nil) {
        self.id = id
        self.displayName = displayName
        self.mcPeerID = mcPeerID
    }
}
