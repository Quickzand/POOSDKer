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

    func startHosting() {
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

            listener?.newConnectionHandler = { connection in
                // MARK: Handle the connection with a response for the websocket in the future
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


class ParticipantNetworkingController {
    private var browser: NWBrowser?

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
                switch result.endpoint {
                case .service(let name, let type, let domain, let interface):
                    print("Found service: \(name) \t \(type) \t \(domain) \t \(interface)")
                    // MARK: - Connect to service in future here
                default:
                    break
                }
            }
        }

        // Start browsing on the main thread
        // MARK: We may wanna change this later to be on its own thread to have stuff updating real time, might be complicated though...
        browser?.start(queue: .main)
    }

    func stopBrowsing() {
        browser?.cancel()
        browser = nil
        print("Browsing stopped.")
    }
}
