//
//  ConnectivityManager.swift
//  Touch
//
//  Created by sean on 10/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

// cf. https://www.ralfebert.de/tutorials/ios-swift-multipeer-connectivity/

import Foundation
import MultipeerConnectivity


protocol ConnectivityManagerDelegate {

    func connectedDevicesChanged(manager : ConnectivityManager, connectedDevices: [MCPeerID])

    func messageReceived(message: String, from: MCPeerID)
}


class ConnectivityManager: NSObject {

    private let serviceType = "touch7-game"

    private let peerId = MCPeerID(displayName: UIDevice.current.name)

    private let serviceAdvertiser: MCNearbyServiceAdvertiser
    private let serviceBrowser: MCNearbyServiceBrowser

    fileprivate lazy var session: MCSession = {
        let session = MCSession(peer: self.peerId,
                                securityIdentity: nil,
                                encryptionPreference: .none)
        session.delegate = self
        return session
    }()

    var delegate: ConnectivityManagerDelegate?


    override init() {

        serviceAdvertiser = MCNearbyServiceAdvertiser(
            peer: peerId, discoveryInfo: nil, serviceType: serviceType)

        serviceBrowser = MCNearbyServiceBrowser(
            peer: peerId, serviceType: serviceType)

        super.init()

        serviceAdvertiser.delegate = self
        serviceAdvertiser.startAdvertisingPeer()

        serviceBrowser.delegate = self
        serviceBrowser.startBrowsingForPeers()
    }


    deinit {

        serviceAdvertiser.stopAdvertisingPeer()
        serviceBrowser.stopBrowsingForPeers()
    }


    func sendMessage(message: String) {

        if session.connectedPeers.count > 0 {
            if let data = message.data(using: .utf8) {
                try! session.send(
                    data, toPeers: session.connectedPeers, with: .reliable)
            }
        }
    }
}


extension ConnectivityManager: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didNotStartAdvertisingPeer error: Error) {

        print("ADV didNotStartAdvertisingPeer: \(error)")
    }


    func advertiser(_ advertiser: MCNearbyServiceAdvertiser,
                    didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?,
                    invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        print("ADV didReceiveInvitationFromPeer peerID: \(peerID)")

        invitationHandler(true, session)
    }
}


extension ConnectivityManager: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser,
                 didNotStartBrowsingForPeers error: Error) {

        print("BRWS didNotStartBrowsingForPeers error: \(error)")

    }


    func browser(_ browser: MCNearbyServiceBrowser,
                 foundPeer peerID: MCPeerID,
                 withDiscoveryInfo info: [String : String]?) {

        print("BRWS foundPeer peerID: \(peerID) withDiscoveryInfo info: \(info)")

        browser.invitePeer(
            peerID, to: session, withContext: nil, timeout: 100)
    }


    func browser(_ browser: MCNearbyServiceBrowser,
                 lostPeer peerID: MCPeerID){

        print("BRWS lostPeer peerID: \(peerID)")
    }
}


extension ConnectivityManager: MCSessionDelegate {

    func session(_ session: MCSession,
                 peer peerID: MCPeerID,
                 didChange state: MCSessionState) {

        print("SESS peer peerId: \(peerID) didChange state: \(state)")

        delegate?.connectedDevicesChanged(
            manager: self, connectedDevices: session.connectedPeers)
    }


    func session(_ session: MCSession,
                 didReceive data: Data,
                 fromPeer peerID: MCPeerID) {

        print("SESS didReceive data: \(data.count) bytes fromPeer peerID: \(peerID)")

        if let message = String(data: data, encoding: .utf8) {
            self.delegate?.messageReceived(message: message, from: peerID)
        }
    }


    func session(_ session: MCSession,
                 didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 with progress: Progress) {

        // not used
    }


    func session(_ session: MCSession,
                 didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID,
                 at localURL: URL,
                 withError error: Error?) {

        // not used
    }


    func session(_ session: MCSession,
                 didReceive stream: InputStream,
                 withName streamName: String,
                 fromPeer peerID: MCPeerID) {

        // not used
    }
}


extension MCSessionState: CustomStringConvertible {

    public var description: String {

        switch(self) {
        case .notConnected:
            return "NOT CONNECTED"
        case .connecting:
            return "CONNECTING"
        case .connected: return "CONNECTED"
        }
    }

}
