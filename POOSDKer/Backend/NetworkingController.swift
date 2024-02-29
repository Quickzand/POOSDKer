//
//  NetworkingController.swift
//  POOSDKer
//
//  Created by Matthew Sand on 2/27/24.
//

import Foundation
import Network


class NetworkingController  {
    var hostController : HostNetworkingController = HostNetworkingController()
    var participantController : ParticipantNetworkingController = ParticipantNetworkingController()
}


class HostNetworkingController {
    var listener: NWListener?

    func startHosting(displayName : String) {
        do {
            let parameters = NWParameters.tcp
            parameters.includePeerToPeer = true

            
            let serviceType = "_poosdker._tcp"
            let serviceName = "POOSDker"

            // THIS PUTS IT ON A RANDOM PORT
            listener = try NWListener(using: parameters)
            listener?.service = NWListener.Service(name: serviceName, type: serviceType)

            listener?.stateUpdateHandler = { newState in
                switch newState {
                case .ready:
                    print("Listener ready on port \(self.listener?.port ?? 0)")
                case .failed(let error):
                    print("Listener failed to start, error: \(error)")
                default:
                    break
                }
            }

            listener?.newConnectionHandler = {  connection in
                connection.stateUpdateHandler = { newState in
                    switch newState {
                    case .ready:
                        print("Connected to \(connection.endpoint)")
                        // Prepare the info as a Data object
                        let hostInfo = ["displayName": displayName, "websocketInfo": "WebSocket Details"]
                        if let hostInfoData = try? JSONEncoder().encode(hostInfo) {
                            connection.send(content: hostInfoData, completion: .contentProcessed({ sendError in
                                if let sendError = sendError {
                                    print("Failed to send host info: \(sendError)")
                                    return
                                }
                                // Handle successful sending of host info, e.g., prepare for further communication
                            }))
                        }
                    default:
                        break
                    }
                }
                connection.start(queue: .main)
            }

            listener?.start(queue: .main)
        } catch {
            print("Unable to create NWListener: \(error.localizedDescription)")
        }
    }

    func stopHosting() {
        listener?.cancel()
        listener = nil
    }
}




struct DiscoveredHost : Identifiable {
    var id: UUID = UUID()
    var displayName : String
}


class ParticipantNetworkingController {
    private var browser: NWBrowser?
    
    
    var discoveredHosts : [DiscoveredHost] = [];

    func startBrowsing() {
        // Sets up peer to peer params
        let parameters = NWParameters()
        parameters.includePeerToPeer = true

        
        let serviceType = "_poosdker._tcp"
        let browserDescriptor = NWBrowser.Descriptor.bonjour(type: serviceType, domain: "local")
        browser = NWBrowser(for: browserDescriptor, using: parameters)

        // Handls results
        browser?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Browser is ready.")
            case .failed(let error):
                print("Browser failed with error: \(error)")
            default:
                break
            }
        }

        browser?.browseResultsChangedHandler = { results, changes in
            for result in results {
                guard case let .service(name, _, _, _) = result.endpoint else { continue }
                
                let connection = NWConnection(to: result.endpoint, using: NWParameters.tcp)
                connection.stateUpdateHandler = { newState in
                    switch newState {
                    case .ready:
                        print("Connected to host: \(name)")
                        // Now ready to receive data
                        self.receiveInitialInfo(connection: connection)
                    default:
                        break
                    }
                }
                connection.start(queue: .main)
            }
        }

        // Start browsing on the main thread
        // MARK: We may wanna change this later to be on its own thread to have stuff updating real time, might be complicated though...
        browser?.start(queue: .main)
    }
    
    
    func receiveInitialInfo(connection: NWConnection) {
        connection.receive(minimumIncompleteLength: 1, maximumLength: 65536) { (data, _, isComplete, error) in
            guard let data = data, error == nil else {
                print("Error receiving data: \(error?.localizedDescription ?? "unknown error")")
                return
            }
            if let hostInfo = try? JSONDecoder().decode(Dictionary<String, String>.self, from: data) {
                print("Received host info: \(hostInfo)")
                
                if let displayName = hostInfo["displayName"] {
                    self.discoveredHosts.append(DiscoveredHost(displayName: displayName))
                }
            }
            if isComplete {
                // Close the connection if the communication is complete
                connection.cancel()
            }
        }
    }


    func stopBrowsing() {
        browser?.cancel()
        browser = nil
        print("Browsing stopped.")
    }
}
