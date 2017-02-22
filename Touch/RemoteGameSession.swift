//
//  RemoteGameService.swift
//  Touch
//
//  Created by sean on 14/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//


import Foundation
import MultipeerConnectivity


protocol RemoteGameBrowserDelegate {

    func didFindPeer(peer: String, inviteHandler: @escaping (Bool) -> Void)
}


protocol RemoteGameAdvertiserDelegate {

    func didReceiveInvitation(peer: String, invitationHandler: @escaping (Bool) -> Void)
}


protocol RemoteGameSessionDelegate {

    func didConnect()

    func didDisconnect()

    func didReceiveMove(x: Int, y: Int)

    func didResignGame()
}


class RemoteGameService {

    private lazy var service: MultipeerService = {
        let service = MultipeerService(serviceName: Config.MultipeerService.serviceType)
        service.delegate = self
        return service
    }()


    var connectedPeers: [String] {
        return service.connectedPeers.map { $0.displayName }
    }

    var isConnected: Bool {
        return service.connectedPeers.count > 0
    }

    private(set) var isAdvertising = false

    private(set) var isBrowsing = false

    var sessionDelegate: RemoteGameSessionDelegate?

    var advertiserDelegate: RemoteGameAdvertiserDelegate?

    var browserDelegate: RemoteGameBrowserDelegate?


    func startAdvertising() {
        guard !isAdvertising else { return }

        service.startAdvertising()
        isAdvertising = true
    }


    func stopAdvertising() {
        guard isAdvertising else { return }

        service.stopAdvertising()
        isAdvertising = false
    }


    func startBrowsing() {
        guard !isBrowsing else { return }

        service.startBrowsing()
        isBrowsing = true
    }


    func stopBrowsing() {
        guard isBrowsing else { return }

        service.stopBrowsing()
        isBrowsing = false
    }

    
    func sendMove(x: Int, y: Int) {
        guard isConnected else { return }

        let message = Message.move(x: x, y: y).serialize()
        service.sendMessage(message: message)
    }


    func sendResign() {
        guard isConnected else { return }
        
        let message = Message.resign.serialize()
        service.sendMessage(message: message)
    }
}


extension RemoteGameService: MultipeerServiceDelegate {

    func didFindPeer(peer: MCPeerID, inviteHandler: @escaping (Bool) -> Void) {

        print("FOUND PEER \(peer.displayName)")

        browserDelegate?.didFindPeer(peer: peer.displayName, inviteHandler: inviteHandler)
    }


    func didReceiveInvitation(peer: MCPeerID, invitationHandler: @escaping (Bool) -> Void) {

        print("PEERS: \(connectedPeers)")

        advertiserDelegate?.didReceiveInvitation(peer: peer.displayName, invitationHandler: invitationHandler)
    }


    func peerDidConnect(peer: MCPeerID) {

        print("PLAYER \(peer.displayName) CONNECTED")

        DispatchQueue.main.sync {
            sessionDelegate?.didConnect()
        }
    }


    func peerDidDisconnect(peer: MCPeerID) {

        print("PLAYER \(peer.displayName) DISCONNECTED")

        DispatchQueue.main.sync {
            sessionDelegate?.didDisconnect()
        }
    }
    

    func didReceiveMessage(peer: MCPeerID, message: String) {

        print("MESSAGE FROM \(peer.displayName): \(message)")

        guard let message = Message.deserialize(string: message) else {
            return
        }

        switch message {
        case .move(let x, let y):
            DispatchQueue.main.sync {
                sessionDelegate?.didReceiveMove(x: x, y: y)
            }

        case .resign:
            DispatchQueue.main.sync {
                sessionDelegate?.didResignGame()
            }
        }
    }
}


extension RemoteGameService {

    fileprivate enum Message {

        case move(x: Int, y: Int)
        case resign


        func serialize() -> String {

            switch self {
            case .move(let x, let y):
                return "MOVE \(x) \(y)"

            case .resign:
                return "QUIT"
            }
        }


        static func deserialize(string: String) -> Message? {

            let components = string.components(separatedBy: " ")

            switch components[0] {
            case "MOVE":
                return .move(x: Int(components[1])!, y: Int(components[2])!)

            case "QUIT":
                return .resign
                
            default:
                print("UNKNOWN MESSAGE: \(string)")
                return nil
            }
        }
    }
}
