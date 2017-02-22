//
//  MultipeerService.swift
//  Touch
//
//  Created by sean on 10/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

// cf. https://www.ralfebert.de/tutorials/ios-swift-multipeer-connectivity/

import Foundation
import MultipeerConnectivity


protocol MultipeerServiceDelegate {

    func didFindPeer(peer: MCPeerID, inviteHandler: @escaping (Bool) -> Void)

    func didReceiveInvitation(peer: MCPeerID, invitationHandler: @escaping (Bool) -> Void)

    func peerDidConnect(peer: MCPeerID)

    func peerDidDisconnect(peer: MCPeerID)

    func didReceiveMessage(peer: MCPeerID, message: String)
}


class MultipeerService: NSObject {

    private let serviceType: String

    private let peerID: MCPeerID

    private var serviceAdvertiser: MCNearbyServiceAdvertiser? {
        didSet { serviceAdvertiser?.delegate = self }
    }

    private var serviceBrowser: MCNearbyServiceBrowser? {
        didSet { serviceBrowser?.delegate = self }
    }

    fileprivate lazy var session: MCSession = {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()

    var maxNumberOfPeers = 1

    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }


    var delegate: MultipeerServiceDelegate?


    init(serviceName: String, displayName: String = UIDevice.current.name) {

        serviceType = serviceName
        peerID = MCPeerID(displayName: displayName)

        super.init()
    }


    func startAdvertising() {

        print("ADV START \(serviceType)")
        serviceAdvertiser = MCNearbyServiceAdvertiser(peer: peerID, discoveryInfo: nil, serviceType: serviceType)
        serviceAdvertiser!.startAdvertisingPeer()
    }


    func stopAdvertising() {

        print("ADV STOP")
        serviceAdvertiser?.stopAdvertisingPeer()
        serviceAdvertiser = nil
    }


    func startBrowsing() {

        print("BRWS START \(serviceType)")
        serviceBrowser = MCNearbyServiceBrowser(peer: peerID, serviceType: serviceType)
        serviceBrowser!.startBrowsingForPeers()
    }


    func stopBrowsing() {

        print("BRWS STOP")
        serviceBrowser?.stopBrowsingForPeers()
        serviceBrowser = nil
    }


    func sendMessage(message: String) {

        print("SESS SEND \(message) TO \(session.connectedPeers.count) PEERS")

        guard session.connectedPeers.count > 0 else {
            return
        }

        if let data = message.data(using: .utf8) {
            try! session.send(data, toPeers: session.connectedPeers, with: .reliable)
        }
    }
}


extension MultipeerService: MCNearbyServiceAdvertiserDelegate {

    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {

        print("ADV didNotStartAdvertisingPeer: \(error)")
    }


    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID,
                    withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {

        print("ADV didReceiveInvitationFromPeer peerID: \(peerID)")

        guard session.connectedPeers.count <= maxNumberOfPeers else {
            print("Already connected to max. number of peers.")
            return
        }

        guard !session.connectedPeers.contains(peerID) else {
            print("\t Peer already connected.")
            invitationHandler(false, self.session)
            return
        }

        let invitationHandlerWithSession: (Bool) -> Void = { accept in
            invitationHandler(accept, self.session)
        }

        delegate?.didReceiveInvitation(peer: peerID, invitationHandler: invitationHandlerWithSession)
    }
}


extension MultipeerService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {

        print("BRWS didNotStartBrowsingForPeers error: \(error)")
    }


    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {

        print("BRWS foundPeer peerID: \(peerID) withDiscoveryInfo info: \(info)")

        guard session.connectedPeers.count <= maxNumberOfPeers else {
            print("Already connected to max. number of peers.")
            return
        }

        let handler: (Bool) -> Void = { invite in
            if invite {
                browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 100)
            }
        }

        delegate?.didFindPeer(peer: peerID, inviteHandler: handler)
    }


    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID){

        print("BRWS lostPeer peerID: \(peerID)")
    }
}


extension MultipeerService: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {

        print("SESS peer peerId: \(peerID) didChange state: \(state)")

        switch state {
            case .connecting:
                break
            case .connected:
                delegate?.peerDidConnect(peer: peerID)
            case .notConnected:
                delegate?.peerDidDisconnect(peer: peerID)
        }
    }


    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {

        print("SESS didReceive data: \(data.count) bytes fromPeer peerID: \(peerID)")

        if let message = String(data: data, encoding: .utf8) {
            self.delegate?.didReceiveMessage(peer: peerID, message: message)
        }
    }


    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, with progress: Progress) {
        // not used
    }


    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String,
                 fromPeer peerID: MCPeerID, at localURL: URL, withError error: Error?) {
        // not used
    }


    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String,
                 fromPeer peerID: MCPeerID) {
        // not used
    }
}


extension MCSessionState: CustomStringConvertible {

    public var description: String {

        switch(self) {
        case .connecting:   return "CONNECTING ..."
        case .connected:    return "CONNECTED"
        case .notConnected: return "NOT CONNECTED"
        }
    }
}
