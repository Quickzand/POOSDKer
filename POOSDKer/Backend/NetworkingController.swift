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
    
    var isJoinable = false
    
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
        isJoinable = true
        // Setup advertiser with discovery info including both displayName and a unique ID
        let discoveryInfo = ["displayName": appState.settings.displayName, "hostID": self.appState.UID, "isJoinable": self.isJoinable ? "true" : "false"]
        self.serviceAdvertiser = MCNearbyServiceAdvertiser(peer: appState.peerID, discoveryInfo: discoveryInfo, serviceType: serviceType)
        self.serviceAdvertiser.delegate = self
        appState.connectedPeers = []
        appState.connectedPeers.append(Peer(id: appState.UID, displayName: appState.settings.displayName, playerColor: appState.settings.playerColor, mcPeerID:appState.peerID))
        appState.hostPeer = appState.connectedPeers[0]
        serviceAdvertiser.startAdvertisingPeer()
        
        
        
    }
    
    func stopHosting() {
        print("Stopping hosting...")
        isJoinable = false
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
        let commandType: String?
        let peers: [Peer]?
        let activePeerIndex: Int?
        let dealerButtonIndex : Int?
        let peerID : String?
        let money : Int?
        let bet : Int?
        let isFolded : Bool?
        let cards : [CardModel]?
        
        enum CodingKeys: String, CodingKey {
            case commandType, peers, activePeerIndex, dealerButtonIndex, peerID, money, bet, isFolded, cards
        }
        
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            commandType = try container.decodeIfPresent(String.self, forKey: .commandType)
            peers = try container.decodeIfPresent([Peer].self, forKey: .peers)
            activePeerIndex = try container.decodeIfPresent(Int.self, forKey: .activePeerIndex)
            dealerButtonIndex = try container.decodeIfPresent(Int.self, forKey: .activePeerIndex)
            peerID = try container.decodeIfPresent(String.self, forKey: .peerID)
            money = try container.decodeIfPresent(Int.self, forKey: .money)
            bet =  try container.decodeIfPresent(Int.self, forKey: .bet)
            isFolded = try container.decodeIfPresent(Bool.self, forKey: .isFolded)
            cards = try container.decodeIfPresent([CardModel].self, forKey: .cards)
        }
    }
    
    
    
    //    MARK: All types of commands that can be sent
    enum BroadcastCommandType : String {
        case shareConnectedPeerList = "sharePeerList"
        case startGame = "startGame"
        case endGame = "endGame"
        case updateGameState = "updateGameState"
        case updatePlayerMoney = "updatePlayerMoney"
        case updatePlayerBet = "updatePlayerBet"
        case updatePlayerFoldState = "updatePlayerFoldState"
        case updatePlayerCards = "updatePlayerCards"
        case updateCommunityCards = "updateCommunityCards"
        case updateDealerButton = "updateDealerButton"
    }
    
    
    func broadcastCommandToPeers(broadcastCommandType: BroadcastCommandType) {
        if !appState.isHost {
            return
        }
        var broadcastData: [String: Any] = [:]
        broadcastData["commandType"] = broadcastCommandType.rawValue
        
        switch broadcastCommandType {
        case .shareConnectedPeerList:
            // Prepare the list of peers to be shared
            let peersToSend = appState.connectedPeers.map {
                ["id": $0.id, "displayName": $0.displayName, "playerColor": $0.playerColor, "money": $0.money, "bet": $0.bet, "isFolded": $0.isFolded, "cards": $0.cards]
            }
            broadcastData["peers"] = peersToSend
            print("Sharing peer list...")
            
        case .startGame:
            print("Starting game...")
            // Additional command-specific data can be added here if necessary
        case .updateGameState:
            broadcastData["activePeerIndex"] = appState.activePeerIndex
        case .updatePlayerMoney:
            broadcastData["money"] = appState.connectedPeers[appState.activePeerIndex].money
            broadcastData["peerID"] = appState.connectedPeers[appState.activePeerIndex].id
        case .updatePlayerBet:
            broadcastData["bet"] = appState.connectedPeers[appState.activePeerIndex].bet
            broadcastData["peerID"] = appState.connectedPeers[appState.activePeerIndex].id
        case .updatePlayerFoldState:
            broadcastData["peerID"] = appState.connectedPeers[appState.activePeerIndex].id
            broadcastData["isFolded"] = appState.connectedPeers[appState.activePeerIndex].isFolded
        case .updatePlayerCards:
            broadcastData["peerID"] = appState.connectedPeers[appState.activePeerIndex].id
            let cardsArray = appState.connectedPeers[appState.activePeerIndex].cards.map { cardToDictionary(card: $0) }
            broadcastData["cards"] = cardsArray
        case .updateCommunityCards:
            let cardsArray = appState.communityCards.map { cardToDictionary(card: $0) }
            broadcastData["cards"] = cardsArray
        case .updateDealerButton:
            let dealerButtonIndex = appState.dealerButtonIndex
            broadcastData["dealerButtonIndex"] = appState.dealerButtonIndex
        case .endGame:
            print("Ending game...")
        default:
            print("Unable to send unrecognized Command")
        }
        
        do {
            print("Sending command to... ")
            print(mcSession.connectedPeers)
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
            let isJoinableString = info["isJoinable"] ?? "false"
            
            var isJoinable = false
            
            if isJoinableString == "true" {
                isJoinable = true
            }
            
            print("Discovered a peer: \(displayName) with ID: \(hostID)")
            if(!self.appState.discoveredPeers.contains(where: {tempPeer in
                return tempPeer.id == hostID
            })) {
                print("Discovered host ")
                if !isJoinable {
                    return
                }
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
                    
                    
                case BroadcastCommandType.endGame.rawValue:
                    print("END GAME COMMAND RECEIVED")
                    self.appState.isInGame = false
                    self.appState.showResultsView = true
                    
                case BroadcastCommandType.updateGameState.rawValue:
                    print("Updating game data...")
                    if let activePeerIndex = decodedData.activePeerIndex {
                        self.appState.activePeerIndex = activePeerIndex
                        print(activePeerIndex)
                    }
                    
                case BroadcastCommandType.updatePlayerMoney.rawValue:
                    print("Updating player money...")
                    print(decodedData)
                    if let peerID = decodedData.peerID, let money = decodedData.money {
                        if let index = self.appState.connectedPeers.firstIndex(where: { $0.id == peerID }) {
                            self.appState.connectedPeers[index].money = money
                            self.appState.triggerViewUpdate.toggle()
                        } else {
                            print("Peer with ID \(peerID) not found.")
                        }
                        
                    }
                    
                case BroadcastCommandType.updatePlayerBet.rawValue:
                    print("Updating player bet...")
                    print(decodedData)
                    if let peerID = decodedData.peerID, let bet = decodedData.bet {
                        if let index = self.appState.connectedPeers.firstIndex(where: { $0.id == peerID }) {
                            self.appState.connectedPeers[index].bet = bet
                            self.appState.connectedPeers[index].totalBets = bet
                            self.appState.triggerViewUpdate.toggle()
                        } else {
                            print("Peer with ID \(peerID) not found.")
                        }
                        
                    }
                    
                case BroadcastCommandType.updatePlayerFoldState.rawValue:
                    print("Updating player fold state...")
                    print(decodedData)
                    if let peerID = decodedData.peerID, let isFolded = decodedData.isFolded {
                        if let index = self.appState.connectedPeers.firstIndex(where: { $0.id == peerID }) {
                            print("HERE")
                            self.appState.connectedPeers[index].isFolded = isFolded
                            self.appState.triggerViewUpdate.toggle()
                        } else {
                            print("Peer with ID \(peerID) not found.")
                        }
                        
                    }
                    
                case BroadcastCommandType.updatePlayerCards.rawValue:
                    print("Updating player cards...")
                    print(decodedData)
                    if let peerID = decodedData.peerID, let cards = decodedData.cards {
                        if let index = self.appState.connectedPeers.firstIndex(where: { $0.id == peerID }) {
                            self.appState.connectedPeers[index].cards = cards
                            self.appState.triggerViewUpdate.toggle()
                        } else {
                            print("Peer with ID \(peerID) not found.")
                        }
                        
                    }
                    
                case BroadcastCommandType.updateCommunityCards.rawValue:
                    print("Updating communtiy cards...")
                    print(decodedData)
                    if let cards = decodedData.cards {
                        self.appState.communityCards = cards
                        print(self.appState.communityCards)
                        self.appState.triggerViewUpdate.toggle()
                    }
                    
                    
                case BroadcastCommandType.updateDealerButton.rawValue:
                    print("Updating dealer button...")
                    print(decodedData)
                    if let dealerButtonIndex = decodedData.dealerButtonIndex {
                        self.appState.dealerButtonIndex = dealerButtonIndex
                        self.appState.triggerViewUpdate.toggle()
                    }
                    
                    //                MARK: ALL COMMANDS TO BE RECEIVED FROM HOST
                case PeerToHostCommandType.check.rawValue:
                    if !self.appState.isHost {
                        print("Received host command when not host... ")
                        return;
                    }
                    print("Receiving command to check...")
                    self.appState.gameController?.check()
                    
                case PeerToHostCommandType.bet.rawValue:
                    if !self.appState.isHost {
                        print("Received host command when not host... ")
                        return;
                    }
                    print("Receiving command to check...")
                    if let bet = decodedData.bet {
                        self.appState.gameController?.bet(value: bet)
                        print("BETTING \(bet)")
                        self.appState.triggerViewUpdate.toggle()
                    }
                    else {
                        print("Couldnt find bet in encodedData...")
                        print(decodedData)
                    }
                    
                case PeerToHostCommandType.fold.rawValue:
                    if !self.appState.isHost {
                        print("Received host command when not host... ")
                        return;
                    }
                    print("Receiving command to check...")
                    self.appState.gameController?.fold()
                    self.appState.triggerViewUpdate.toggle()
                    
                    
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


// MARK: All broadcasting functions for host
extension NetworkingController {
    func broadcastEndGame() {
        self.appState.isInGame = false
        self.appState.showResultsView = true
        self.broadcastCommandToPeers(broadcastCommandType: .endGame)
    }
    
    func broadcastUpdateGameState() {
        self.broadcastCommandToPeers(broadcastCommandType: .updateGameState)
    }
    
    func broadcastUpdatePeerMoney() {
        self.broadcastCommandToPeers(broadcastCommandType: .updatePlayerMoney)
    }
    
    func broadcastUpdatePeerBet() {
        self.broadcastCommandToPeers(broadcastCommandType: .updatePlayerBet)
    }
    
    func broadcastUpdatePlayerFoldState() {
        self.broadcastCommandToPeers(broadcastCommandType: .updatePlayerFoldState)
    }
    
    func broadcastUpdatePlayerCards() {
        self.broadcastCommandToPeers(broadcastCommandType: .updatePlayerCards)
    }
    
    func broadcastUpdateCommunityCards() {
        self.broadcastCommandToPeers(broadcastCommandType: .updateCommunityCards )
    }
    
    func broadcastUpdateDealerButton() {
        self.broadcastCommandToPeers(broadcastCommandType: .updateDealerButton)
    }
}

// MARK: All broadcasting functions for individuals
extension NetworkingController {
    enum PeerToHostCommandType : String {
        case check = "check"
        case bet = "bet"
        case fold = "fold"
    }
    
    
    func sendCommandToHost(peerToHostCommandType: PeerToHostCommandType) {
        guard let hostPeer = appState.hostPeer else {
            print("No host found...")
            return
        }
        
        var sendingData: [String: Any] = [:]
        sendingData["commandType"] = peerToHostCommandType.rawValue
        
        switch peerToHostCommandType {
        case .check:
            print("Sending check command to host...")
            
        case .bet:
            print("UPDATING THE MONIES")
            sendingData["bet"] = self.appState.connectedPeers[self.appState.activePeerIndex].bet
            
        case .fold:
            print("Sending fold command to host...")
            
            
        default:
            print("Unrecognized peer to host command")
        }
        
        do {
            let data = try JSONSerialization.data(withJSONObject: sendingData, options: [])
            try mcSession.send(data, toPeers: [hostPeer.mcPeerID!], with: .reliable)
        } catch {
            print("Error encoding or sending command to host")
        }
    }
    
    
    func sendCheckToHost() {
        self.sendCommandToHost(peerToHostCommandType: .check)
    }
    
    func sendBetToHost() {
        self.sendCommandToHost(peerToHostCommandType: .bet)
    }
    
    func sendFoldToHost() {
        self.sendCommandToHost(peerToHostCommandType: .fold)
    }
}





