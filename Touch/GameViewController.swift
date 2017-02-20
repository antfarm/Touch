//
//  ViewController.swift
//  Touch
//
//  Created by sean on 07/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var game: Game! {
        didSet {
            game.delegate = self
            game.sendFullState()
        }
    }

    fileprivate var remotePlayer: Game.Player?

    fileprivate var remoteGameSession: RemoteGameSession? {
        didSet {
            remotePlayer = remoteGameSession != nil ? (game?.player == .playerA ? .playerB : .playerA) : nil
            remoteGameSession?.delegate = self
        }
    }

    fileprivate var gameView: GameView { return view as! GameView }

    fileprivate var sendValidMove = false // TODO: find better way!!!

    
    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        remoteGameSession = RemoteGameSession()

        if Config.UI.roundedCorners {
            gameView.makeRoundedCorners()
        }
    }


    @IBAction func tileTouched(_ button: UIButton) {

        guard remotePlayer == nil || game.currentPlayer != remotePlayer else {
            showModalAlert(message: "Please wait for your opponent's turn!")
            return
        }

        let (x, y) = coordinates(tag: button.tag)

        sendValidMove = true

        game.makeMove(x: x, y: y)

        remoteGameSession?.sendMove(x: x, y: y)
    }


    func showMenu() {

        performSegue(withIdentifier: "showMenuSegue", sender: nil)
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showMenuSegue" {

            if let menuVC = segue.destination as? MenuViewController {

                menuVC.game = game
                menuVC.remoteGameSession = remoteGameSession
            }
        }
    }
}


extension GameViewController: RemoteGameSessionDelegate {

    func didReceiveMove(x: Int, y: Int) {

        guard game.currentPlayer == remotePlayer else {
            print("ERROR: Not remote player's turn!")
            return
        }

        sendValidMove = false

        game.makeMove(x: x, y: y)
    }


    func didResignGame() {

        game = nil
        remoteGameSession = nil

        // game.resign(player: remotePlayer)

        print("Remote player resigned.")
    }
}



extension GameViewController: GameDelegate {

    func tileChanged(x: Int, y: Int, state: Game.TileState) {

        let tag = tagForCoordinates(x: x, y: y)
        let tileView = gameView.tileViewForTag(tag: tag)

        switch state {
        case .empty:
            tileView.setEmpty()

        case .owned(let player) where player == .playerA:
            tileView.setOwnedByPlayerA()

        case .owned:
            tileView.setOwnedByPlayerB()

        case .destroyed:
            tileView.setDestroyed()
        }
    }


    func currentPlayerChanged(player: Game.Player) {

        switch player {
        case .playerA:
            gameView.setTurnIndicatorPlayerA()

        case .playerB:
            gameView.setTurnIndicatorPlayerB()
        }
    }


    func scoreChanged(score: Game.Score) {

        gameView.setScore(playerA: score[.playerA]!, playerB: score[.playerB]!)
    }


    func invalidMove(x: Int, y: Int, reason: Game.InvalidMoveReason) {

        switch reason {
        case .owned:
            showModalAlert(message: "You already own this tile.")

        case .destroyed:
            showModalAlert(message: "You cannot claim a destroyed tile.")

        case .copy:
            showModalAlert(message:
                "You are not allowed to copy your opponent's previous move.")
        }
    }


    func validMove(x: Int, y: Int) {

        guard sendValidMove else {
            return
        }

        //remoteGameSession?.sendMove(x: x, y: y)
    }


    func gameOver(winner: Game.Player?) {

        if let winner = winner {
            showModalAlert(message: "Game over!\n\(winner.rawValue) wins.")
        }
        else {
            showModalAlert(message: "Game over!\nIt's a draw!")
        }
    }
}


extension GameViewController {

    fileprivate func coordinates(tag: Int) -> (x: Int, y: Int) {

        guard tag != 49 else { return (x: 0, y: 0) }

        return (x: tag % 7, y: tag / 7)
    }


    fileprivate func tagForCoordinates(x: Int, y: Int) -> Int {

        guard (x, y) != (0, 0) else { return 49 }

        return x + y * 7
    }
}
