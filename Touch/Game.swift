//
//  Game.swift
//  Touch
//
//  Created by sean on 07/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import Foundation


protocol GameDelegate {

    func stateChanged(x: Int, y: Int, state: Game.TileState)

    func currentPlayerChanged(player: Game.Player)

    func invalidMove(x: Int, y: Int)
}


class Game {

    enum Player: String {

        case playerA = "A"
        case playerB = "B"
    }

    enum TileState {

        case empty
        case owned(by: Player)
        case destroyed
    }


    var delegate: GameDelegate?


    fileprivate var grid: [[TileState]] = Array(repeating: Array(repeating: .empty, count: 7), count: 7)

    
    fileprivate(set) var currentPlayer: Player = .playerA {
        didSet(player) {
            delegate?.currentPlayerChanged(player: player)
        }
    }


    init() {

    }


    func setTileState(x: Int, y: Int, state: TileState) {

        grid[x][y] = state
        delegate?.stateChanged(x: x, y: y, state: state)
    }


    func makeMove(x: Int, y: Int) {

        switch grid[x][y] {
        case .empty:
            setTileState(x: x, y: y, state: .owned(by: currentPlayer))
            print("SET \(currentPlayer)")

        case .owned(let by):
            delegate?.invalidMove(x: x, y: y)
            print("OWNED BY \(by)")

        case .destroyed:
            delegate?.invalidMove(x: x, y: y)
            print("ILLEGAL MOVE")
        }

        currentPlayer = currentPlayer == .playerA ? .playerB : .playerA
    }
}
