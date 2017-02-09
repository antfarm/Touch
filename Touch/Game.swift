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

    func invalidMove(x: Int, y: Int, reason: Game.InvalidMoveReason)

    func gameOver(score: [Game.Player:Int])
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


    enum InvalidMoveReason {

        case owned
        case destroyed
        case copy
    }


    var delegate: GameDelegate?

    private var currentPlayer: Player! {
        didSet { delegate?.currentPlayerChanged(player: currentPlayer) }
    }

    private var opponent: Player {
        return currentPlayer == .playerA ? .playerB : .playerA
    }

    private var score: [Player:Int]!

    private var grid: [[TileState]] = Array(repeating: Array(repeating: .empty, count: 7), count: 7)

    private var previousMove: (x: Int, y: Int)?

    private var occupiedTiles: Set<Int> = []


    init() {
        reset()
    }

    
    func reset() {

        currentPlayer = .playerA

        score = [.playerA: 0, .playerB: 0]
        delegate?.scoreChanged(score: score)

        for x in (0..<7) {
            for y in (0..<7) {
                setTileState(x: x, y: y, state: .empty)
            }
        }
    }


    func makeMove(x: Int, y: Int) {

        let currentState = grid[x][y]

        switch currentState {
        case .empty:
            print("\tEMPTY -> CLAIM")

            claimNeighborhoodTilesForPlayer(x: x, y: y, player: currentPlayer)

            finishMove(x: x, y: y)

        case .owned(let player) where player == opponent:
            print("\tOWNED BY OPPONENT -> CLAIM")

            if let (previousX, previousY) = previousMove {
                guard x != previousX || y != previousY else {
                    print("\tOPPONENT'S PREVIOUS MOVE -> ILLEGAL MOVE")

                    delegate?.invalidMove(x: x, y: y, reason: .copy)
                    return
                }
            }

            claimNeighborhoodTilesForPlayer(x: x, y: y, player: currentPlayer)

            finishMove(x: x, y: y)

        case .owned:
            print("\tOWNED BY PLAYER -> ILLEGAL MOVE")

            delegate?.invalidMove(x: x, y: y, reason: .owned)

        case .destroyed:
            print("\tDESTROYED -> ILLEGAL MOVE")

            delegate?.invalidMove(x: x, y: y, reason: .destroyed)
        }
    }


    private func claimNeighborhoodTilesForPlayer(x: Int, y: Int, player: Player) {

        for (x, y) in neighborhoodCoordinates(x: x, y: y) {
            claimTileForPlayer(x: x, y: y, player: player)
        }
    }
    
    
    private func finishMove(x: Int, y: Int) {

        previousMove = (x: x, y: y)

        currentPlayer = currentPlayer == .playerA ? .playerB : .playerA

        delegate?.scoreChanged(score: score)

        if occupiedTiles.count == 49 {
            print("GAME OVER!")

            delegate?.gameOver(score: score)
        }
    }
    
    
    private func claimTileForPlayer(x: Int, y: Int, player: Player) {

        let currentState = grid[x][y]

        switch currentState {
        case .empty:
            print("\t\tEMPTY -> OCCUPY")

            setTileState(x: x, y: y, state: .owned(by: player))
            score[currentPlayer]! += 1

        case .owned(let player) where player == opponent:
            print("\t\tOWNED BY OPPONENT -> DESTROY")

            setTileState(x: x, y: y, state: .destroyed)
            score[opponent]! -= 1

        case .owned:
            print("\t\tOWNED BY PLAYER -> .")

        case .destroyed:
            print("\t\tDESTROYED -> .")
        }
    }


    private func setTileState(x: Int, y: Int, state: TileState) {

        grid[x][y] = state

        delegate?.stateChanged(x: x, y: y, state: state)

        let index = x + y * 7

        switch state {
        case .empty:
            occupiedTiles.remove(index)
        default:
            occupiedTiles.insert(index)
        }
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
