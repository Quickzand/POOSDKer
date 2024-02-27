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


class HostNetworkingController : NSObject, NetServiceDelegate {
    var service: NetService?

       func startService() {
           service = NetService(domain: "local.", type: "_yourServiceName._tcp.", name: "My Service", port: 8000)
           service?.delegate = self
           service?.publish()
       }

       // NetServiceDelegate methods
       func netServiceDidPublish(_ sender: NetService) {
           print("Service published successfully")
       }

       func netService(_ sender: NetService, didNotPublish errorDict: [String : NSNumber]) {
           print("Failed to publish service: \(errorDict)")
       }
}



class ParticipantNetworkingController : NSObject, NetServiceBrowserDelegate {
    var browser = NetServiceBrowser()

       func startBrowsing() {
           browser.delegate = self
           browser.searchForServices(ofType: "_yourServiceName._tcp.", inDomain: "local.")
       }

       // NetServiceBrowserDelegate methods
       func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
           print("Found service: \(service)")
           // Resolve the service to get its details
           service.resolve(withTimeout: 10.0)
       }

       func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
           print("Search was not successful: \(errorDict)")
       }
}
