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


class RemoteGameSession {

    enum Message {

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


    private lazy var service: MultipeerService = {
        return MultipeerService(serviceName: Config.MultipeerService.serviceType)
    }()


    var delegate: RemoteGameSessionDelegate?


    func start() {

        service.startDiscovery()
    }


    func stop() {

        service.stopDiscovery()
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

    func connectedDevicesChanged(manager: MultipeerService, connectedDevices: [MCPeerID]) {

        let displayNames = connectedDevices.map { $0.displayName }
        print("CONNECTED: \(displayNames)")
    }


    func didReceiveMessage(message: String, from peerID: MCPeerID) {

        let displayName = peerID.displayName
        print("MESSAGE FROM \(displayName): \(message)")

        guard let message = Message.deserialize(string: message) else {
            return
        }

        switch message {
        case .move(let x, let y):
            delegate?.didReceiveMove(x: x, y: y)

        case .resign:
            delegate?.didResignGame()
        }
    }
    
}
