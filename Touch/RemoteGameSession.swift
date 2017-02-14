//
//  RemoteGameSession.swift
//  Touch
//
//  Created by sean on 14/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//


import Foundation
import MultipeerConnectivity // remove dependency, make peer id a String


protocol RemoteGameSessionDelegate {

    func receivedMove(x: Int, y: Int)
}


class RemoteGameSession {

    var delegate: RemoteGameSessionDelegate?
}


extension RemoteGameSession: ConnectivityManagerDelegate {

    func connectedDevicesChanged(manager: ConnectivityManager, connectedDevices: [String]) {

    }


    func messageReceived(message: String, from: String) {

        let move: (Int, Int)? = (3, 3)

        if let (x, y) = move {
            delegate?.receivedMove(x: x, y: y)
        }
    }
    
}
