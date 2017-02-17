//
//  MultipeerUIService.swift
//  Touch
//
//  Created by sean on 16/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import Foundation
import MultipeerConnectivity


protocol MultipeerUIServiceDelegate {

    func connectedDevicesChanged(manager: MultipeerUIService, connectedDevices: [MCPeerID])

    func didReceiveMessage(message: String, from: MCPeerID)
}


class MultipeerUIService: NSObject {

    private let serviceType: String
    fileprivate let peerID: MCPeerID

    private var advertiserAssistent: MCAdvertiserAssistant? {
        didSet { advertiserAssistent?.delegate = self }
    }

    private var browserVC: MCBrowserViewController? {
        didSet { browserVC?.delegate = self }
    }

    fileprivate lazy var session: MCSession = {
        let session = MCSession(peer: self.peerID, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()

    var delegate: MultipeerUIServiceDelegate?


    init(serviceName: String, displayName: String = UIDevice.current.name) {

        serviceType = serviceName
        peerID = MCPeerID(displayName: displayName)

        super.init()
    }


    func startAdvertising(discoveryInfo: [String: String]? = nil) {

        print("ADV START")
        
        advertiserAssistent = MCAdvertiserAssistant(serviceType: serviceType, discoveryInfo: discoveryInfo, session: session)
        advertiserAssistent!.start()
    }

    func startBrowsing() {

        print("BRWS START")

        browserVC = MCBrowserViewController(serviceType: serviceType, session: session)
        browserVC!.minimumNumberOfPeers = 2
        browserVC!.maximumNumberOfPeers = 2

        UIApplication.shared.keyWindow?.rootViewController?.present(browserVC!, animated: true)
    }


    func stopAdvertising() {

        print("ADV STOP")
        advertiserAssistent?.stop()
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


extension MultipeerUIService: MCAdvertiserAssistantDelegate {

    func advertiserAssistantDidDismissInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {

    }

    func advertiserAssistantWillPresentInvitation(_ advertiserAssistant: MCAdvertiserAssistant) {

    }
}


extension MultipeerUIService: MCBrowserViewControllerDelegate {

    func browserViewController(_ browserViewController: MCBrowserViewController,
                               shouldPresentNearbyPeer peerID: MCPeerID,
                               withDiscoveryInfo info: [String : String]?) -> Bool {

        return peerID != self.peerID
    }


    func browserViewControllerDidFinish(_ browserViewController: MCBrowserViewController) {

        browserViewController.dismiss(animated: true, completion: nil)
    }


    func browserViewControllerWasCancelled(_ browserViewController: MCBrowserViewController) {

        browserViewController.dismiss(animated: true, completion: nil)
    }
}


extension MultipeerUIService: MCSessionDelegate {

    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {

        print("SESS peer peerId: \(peerID) didChange state: \(state)")

        delegate?.connectedDevicesChanged(manager: self, connectedDevices: session.connectedPeers)
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
