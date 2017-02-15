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

    var remotePlayer: Game.Player?

    var remoteGameSession: RemoteGameSession? {
        didSet {
            remoteGameSession?.delegate = self
        }
    }

    var alertMessage: String?
    var alertCompletion: (() -> ())?

    var gameView: GameView { return view as! GameView }


    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

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
        game.makeMove(x: x, y: y)
    }


    @IBAction func showMenu(_ sender: Any) {

        dismiss(animated: false, completion: nil)
    }
}


extension GameViewController: RemoteGameSessionDelegate {

    func receivedMove(x: Int, y: Int) {

        guard game.currentPlayer == remotePlayer else {
            print("EROR: Not remote player's turn!")
            return
        }

        game.makeMove(x: x, y: y)
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

    func showModalAlert(message: String, completion: (() -> ())? = nil) {

        alertMessage = message
        alertCompletion = completion

        performSegue(withIdentifier: "modalAlertSegue", sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "modalAlertSegue" {

            if let alertVC = segue.destination as? AlertViewController {

                alertVC.message = alertMessage!
                alertVC.completion = alertCompletion
            }
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
