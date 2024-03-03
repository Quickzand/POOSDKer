//
//  NetworkingController.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import Foundation
import MultipeerConnectivity

class NetworkingController: NSObject, MCNearbyServiceAdvertiserDelegate, MCNearbyServiceBrowserDelegate {
    
    var peerID: MCPeerID!
    var mcSession: MCSession!
    var serviceAdvertiser: MCNearbyServiceAdvertiser!
    var serviceBrowser: MCNearbyServiceBrowser!
    let serviceType = "poosdker"
    
    @Published var connectedPeers : [ConnectedPeer] = [];
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        // Accept invitations automatically or based on user input
        invitationHandler(true, self.mcSession)
    }
    
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
            // Automatically send a connection request or based on user input
            browser.invitePeer(peerID, to: self.mcSession, withContext: nil, timeout: 10)
        }
        
        func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
            print("Lost connection to peer " + peerID.displayName)
        }
 
    
    override init() {
        super.init()
        
        // Setup peer and session
        self.peerID = MCPeerID(displayName: UIDevice.current.name)
        self.mcSession = MCSession(peer: peerID, securityIdentity: nil, encryptionPreference: .required)
        self.mcSession.delegate = self
        
        // Setup advertiser and browser
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        self.serviceAdvertiser.delegate = self
        
        self.serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        self.serviceBrowser.delegate = self
    }
    
    
    
    func updatePeers() {
          // Clear the current list
          connectedPeers.removeAll()
          
          // Add all connected peers to the list
          for peer in mcSession.connectedPeers {
              let connectedPeer = ConnectedPeer(id: peer)
              connectedPeers.append(connectedPeer)
          }
          
          // Notify the UI or whoever needs to know that the list has been updated
          // This could be via NotificationCenter, a delegate pattern, or SwiftUI's @Published property wrapper, etc.
      }
    
    
    func startHosting() {
        print("Starting hosting...")
        serviceAdvertiser.startAdvertisingPeer()
    }
    
    func stopHosting() {
        print("Stopping hosting...")
        serviceAdvertiser.stopAdvertisingPeer()
    }
    
    func startBrowsing() {
        print("Starting browsing...")
        serviceBrowser.startBrowsingForPeers()
    }
    
    func stopBrowsing() {
        print("Stopping browsing...")
        serviceBrowser.stopBrowsingForPeers()
    }
}


// All session control code
extension NetworkingController : MCSessionDelegate {
    
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
          DispatchQueue.main.async { [weak self] in
              self?.updatePeers()
              
              // Optionally, post a notification or call a delegate method here to inform other parts of your app
          }
      }
      
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("Here")
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


struct ConnectedPeer : Identifiable {
    var id: MCPeerID
    var displayName: String {
        return id.displayName
    }
}
