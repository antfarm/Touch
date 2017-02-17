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

    func peerDidConnect(peer: MCPeerID)

    func peerDidDisconnect(peer: MCPeerID)

    func didReceiveMessage(message: String, from: MCPeerID)
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


    fileprivate var timeStarted = Date().timeIntervalSince1970


    var connectedPeers: [MCPeerID] {
        return session.connectedPeers
    }


    var delegate: MultipeerServiceDelegate?


    init(serviceName: String, displayName: String = UIDevice.current.name) {

        serviceType = serviceName
        peerID = MCPeerID(displayName: displayName)

        timeStarted = Date().timeIntervalSince1970

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

        if session.connectedPeers.count > 0 {
            if let data = message.data(using: .utf8) {
                try! session.send(data, toPeers: session.connectedPeers, with: .reliable)
            }
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

//        let timeStartedPeer: TimeInterval? = context?.withUnsafeBytes { $0.pointee }
//
//        if let timeStartedPeer = timeStartedPeer {
//
//            print("TIME: \(timeStarted) < \(timeStartedPeer) ?")
//
//            let acceptInvitation = timeStarted < timeStartedPeer
//
//            invitationHandler(acceptInvitation, session)
//
//            if acceptInvitation {
//                print("ADV ACCEPT INVITATION FROM \(peerID)")
//                advertiser.stopAdvertisingPeer()
//            }
//        }

        let acceptInvitation = session.connectedPeers.count < 3

        invitationHandler(acceptInvitation, session)
    }
}


extension MultipeerService: MCNearbyServiceBrowserDelegate {

    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {

        print("BRWS didNotStartBrowsingForPeers error: \(error)")

    }


    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String: String]?) {

        print("BRWS foundPeer peerID: \(peerID) withDiscoveryInfo info: \(info)")

//        let context = Data(bytes: &timeStarted, count: MemoryLayout<TimeInterval>.size)
//
//        browser.invitePeer(peerID, to: session, withContext: context, timeout: 100)

        browser.invitePeer(peerID, to: session, withContext: nil, timeout: 100)
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
            self.delegate?.didReceiveMessage(message: message, from: peerID)
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
