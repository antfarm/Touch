//
//  RemoteGameSession.swift
//  Touch
//
//  Created by sean on 14/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//


import Foundation
import MultipeerConnectivity


protocol RemoteGameSessionDelegate {

    func didReceiveMove(x: Int, y: Int)

    func didResignGame()
}


protocol RemoteGameConnectionDelegate {

    func didConnect()

    func didDisconnect()

    func didReceiveInvitation(invitationHandler: @escaping (Bool) -> Void)
}


class RemoteGameSession {

    private lazy var service: MultipeerService = {
        let service = MultipeerService(serviceName: Config.MultipeerService.serviceType)
        service.delegate = self
        return service
    }()


    var connectedPeers: [String] {
        return service.connectedPeers.map { $0.displayName }
    }


    var delegate: RemoteGameSessionDelegate?

    var connectionDelegate: RemoteGameConnectionDelegate?


    func startAdvertising() {
        service.startAdvertising()
    }


    func stopAdvertising() {
        service.stopAdvertising()
    }


    func startBrowsing() {
        service.startBrowsing()
    }


    func stopBrowsing() {
        service.stopBrowsing()
    }

    
    func sendMove(x: Int, y: Int) {

        let message = Message.move(x: x, y: y).serialize()
        service.sendMessage(message: message)
    }


    func sendResign() {

        let message = Message.resign.serialize()
        service.sendMessage(message: message)
    }
}


extension RemoteGameSession: MultipeerServiceDelegate {


    func peerDidConnect(peer: MCPeerID) {

        print("PLAYER \(peer.displayName) CONNECTED")

        DispatchQueue.main.sync {
            connectionDelegate?.didConnect()
        }
    }


    func peerDidDisconnect(peer: MCPeerID) {

        print("PLAYER \(peer.displayName) DISCONNECTED")

        DispatchQueue.main.sync {
            connectionDelegate?.didDisconnect()
        }
    }


    func didReceiveInvitation(invitationHandler: @escaping (Bool) -> Void) {

        guard connectedPeers.count <= 2 else {
            print("Already connected to anpother peer")
            return
        }

        DispatchQueue.main.sync {
            connectionDelegate?.didReceiveInvitation(invitationHandler: invitationHandler)
        }
    }


    func didReceiveMessage(message: String, from peerID: MCPeerID) {

        let displayName = peerID.displayName
        print("MESSAGE FROM \(displayName): \(message)")

        guard let message = Message.deserialize(string: message) else {
            return
        }

        switch message {
        case .move(let x, let y):
            DispatchQueue.main.sync {
                delegate?.didReceiveMove(x: x, y: y)
            }

        case .resign:
            DispatchQueue.main.sync {
                delegate?.didResignGame()
            }
        }
    }
}


extension RemoteGameSession {

    fileprivate enum Message {

        case move(x: Int, y: Int)
        case resign


        static let commandMove = "MOVE"
        static let commandResign = "QUIT"


        func serialize() -> String {

            switch self {
            case .move(let x, let y):
                return "\(Message.commandMove) \(x) \(y)"

            case .resign:
                return "\(Message.commandResign)"
            }
        }


        static func deserialize(string: String) -> Message? {

            let components = string.components(separatedBy: " ")

            switch components[0] {
            case commandMove:
                return .move(x: Int(components[1])!, y: Int(components[2])!)

            case commandResign:
                return .resign
                
            default:
                print("UNKNOWN MESSAGE: \(string)")
                return nil
            }
        }
    }
}
