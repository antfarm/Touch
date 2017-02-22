//
//  Game.swift
//  Touch
//
//  Created by sean on 07/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import Foundation


protocol GameDelegate {

    func tileChanged(x: Int, y: Int, state: Game.TileState)

    func currentPlayerChanged(player: Game.Player)

    func scoreChanged(score: Game.Score)

    func invalidMove(x: Int, y: Int, reason: Game.InvalidMoveReason)

    func validMove(x: Int, y: Int)

    func gameOver(winner: Game.Player?)
}


class Game {

    typealias Score = [Game.Player: Int]


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


    private(set) var currentPlayer: Player! {
        didSet { delegate?.currentPlayerChanged(player: currentPlayer) }
    }

    var currentOpponent: Player {
        return currentPlayer == .playerA ? .playerB : .playerA
    }

    private var leadingPlayer: Game.Player? {
        return score[.playerA]! == score[.playerB]! ? nil :
            score[.playerA]! > score[.playerB]! ? .playerA : .playerB
    }

    private(set) var isOver: Bool = false {
        didSet { if isOver { delegate?.gameOver(winner: leadingPlayer) } }
    }

    private var score: [Player: Int]!

    private var tiles: [[TileState]] =
        Array(repeating: Array(repeating: .empty, count: 7), count: 7)


    private var previousMove: (x: Int, y: Int)?

    private var occupiedTiles: Set<Int> = []

    private lazy var coordinates = {
        (0..<7).flatMap { (x) in (0..<7).map { (y) in (x: x, y: y) } }
    }()


    init() {

        reset()
    }

    
    func reset() {

        isOver = false
        currentPlayer = .playerA

        score = [.playerA: 0, .playerB: 0]
        delegate?.scoreChanged(score: score)

        for (x, y) in coordinates {
            setTileState(x: x, y: y, state: .empty)
        }

        previousMove = nil
        occupiedTiles = []
    }


    func sendFullState() {

        for (x, y) in coordinates {
            delegate?.tileChanged(x: x, y: y, state: tiles[x][y])
        }

        delegate?.currentPlayerChanged(player: currentPlayer)
        delegate?.scoreChanged(score: score)
    }


    func makeMove(x: Int, y: Int) {

        guard !isOver else {
            delegate?.gameOver(winner: leadingPlayer)
            return
        }

        let currentState = tiles[x][y]

        switch currentState {
        case .empty:

            claimNeighborhoodForPlayer(x: x, y: y, player: currentPlayer)
            finishMove(x: x, y: y)

        case .owned(let player) where player == currentOpponent:

            guard previousMove == nil || previousMove! != (x, y) else {
                delegate?.invalidMove(x: x, y: y, reason: .copy)
                break
            }

            claimNeighborhoodForPlayer(x: x, y: y, player: currentPlayer)
            finishMove(x: x, y: y)

        case .owned:

            delegate?.invalidMove(x: x, y: y, reason: .owned)

        case .destroyed:

            delegate?.invalidMove(x: x, y: y, reason: .destroyed)
        }
    }


    private func finishMove(x: Int, y: Int) {

        previousMove = (x: x, y: y)

        delegate?.validMove(x: x, y: y)

        currentPlayer = currentOpponent

        delegate?.scoreChanged(score: score)

        if occupiedTiles.count == 49 {
            isOver = true
        }
    }


    private func claimNeighborhoodForPlayer(x: Int, y: Int, player: Player) {

        for (x, y) in neighborhoodCoordinates(x: x, y: y) {
            claimTileForPlayer(x: x, y: y, player: player)
        }
    }
    
    
    private func claimTileForPlayer(x: Int, y: Int, player: Player) {

        let currentState = tiles[x][y]

        switch currentState {
        case .empty:

            setTileState(x: x, y: y, state: .owned(by: player))
            score[currentPlayer]! += 1

        case .owned(let player) where player == currentOpponent:

            setTileState(x: x, y: y, state: .destroyed)
            score[player]! -= 1

        case .owned:

            break

        case .destroyed:

            break
        }
    }


    private func setTileState(x: Int, y: Int, state: TileState) {

        tiles[x][y] = state

        delegate?.tileChanged(x: x, y: y, state: state)

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
