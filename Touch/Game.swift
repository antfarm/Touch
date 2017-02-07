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

    func scoreChanged(score: [Game.Player:Int])

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


    private var grid: [[TileState]] = Array(repeating: Array(repeating: .empty, count: 7), count: 7)

    private var score: [Player:Int] = [.playerA: 0, .playerB: 0]


    private(set) var currentPlayer: Player = .playerA {
        didSet {
            delegate?.currentPlayerChanged(player: currentPlayer)
        }
    }


    init() {

    }


    private func setTileState(x: Int, y: Int, state: TileState) {

        grid[x][y] = state

        delegate?.stateChanged(x: x, y: y, state: state)
    }



    func claimTileForPlayer(x: Int, y: Int, player: Player) {

        switch grid[x][y] {
        case .empty:

            score[currentPlayer]! += 1

            setTileState(x: x, y: y, state: .owned(by: player))
            print("SET \(currentPlayer)")

        case .owned(let player):

            let opponent: Player = currentPlayer == .playerA ? .playerB : .playerA

            if player == opponent {
                score[opponent]! -= 1

                setTileState(x: x, y: y, state: .destroyed)
                print("OWNED BY \(player) -> DESTROY")
            }

        case .destroyed:

            delegate?.invalidMove(x: x, y: y)

            print("ILLEGAL MOVE")
        }
    }


    func makeMove(x: Int, y: Int) {

        switch grid[x][y] {
        case .empty:

            for (x, y) in neighborhoodCoordinates(x: x, y: y) {
                claimTileForPlayer(x: x, y: y, player: currentPlayer)
            }

        case .owned(let by):
            delegate?.invalidMove(x: x, y: y)
            print("OWNED BY \(by)")

        case .destroyed:
            delegate?.invalidMove(x: x, y: y)
            print("ILLEGAL MOVE")
        }

        currentPlayer = currentPlayer == .playerA ? .playerB : .playerA

        delegate?.scoreChanged(score: score)
    }


    private func neighborhoodCoordinates(x: Int, y: Int) -> [(x: Int, y: Int)] {

        var coordinates = [(x: x, y: y)]

        for (dx, dy) in [(0, -1), (-1, 0), (1, 0), (0, 1)] {
            if (0..<7) ~= x + dx && (0..<7) ~= y + dy {
                coordinates.append((x: x + dx, y: y + dy))
            }
        }

        return coordinates
    }
}
