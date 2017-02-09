//
//  ViewController.swift
//  Touch
//
//  Created by sean on 07/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    var game: Game!

    var gameView: GameView { return view as! GameView }

    var alertMessage: String?


    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        gameView.makeRoundedCorners()
        game.reset()
    }


    @IBAction func tileTouched(_ button: UIButton) {

        let (x, y) = coordinates(tag: button.tag)

        print("\nTILE TOUCHED tag: \(button.tag) -> x: \(x), y: \(y)")

        game.makeMove(x: x, y: y)
    }


    @IBAction func newGame(_ sender: UIButton) {
        print("NEW GAME")

        game.reset()
    }



    func showModalAlert(message: String) {

        alertMessage = message
        performSegue(withIdentifier: "modalAlertSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "modalAlertSegue" {

            if let alertVC = segue.destination as? AlertViewController {
                alertVC.message = alertMessage!
            }
        }
    }
}


extension GameViewController: GameDelegate {

    func stateChanged(x: Int, y: Int, state: Game.TileState) {

        let tag = tagForCoordinates(x: x, y: y)
        let tileView = gameView.tileViewForTag(tag: tag)

        print("\t\t\tSTATE CHANGED state: \(state), x: \(x), y: \(y) -> tag: \(tag)")

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

        print ("PLAYER CHANGED: \(player.rawValue)")

        switch player {
        case .playerA:
            gameView.setTurnIndicatorPlayerA()
        case .playerB:
            gameView.setTurnIndicatorPlayerB()
        }
    }


    func scoreChanged(score: [Game.Player : Int]) {

        print("SCORE CHANGED: \(score[.playerA]!) - \(score[.playerB]!)")

        gameView.setScore(playerA: score[.playerA]!, playerB: score[.playerB]!)
    }


    func invalidMove(x: Int, y: Int) {

        print("\t\tINVALID MOVE x: \(x), y: \(y)")
        showModalAlert(message: "INVALID MOVE!\nx: \(x), y: \(y)")
    }


    func gameOver(score: [Game.Player : Int]) {

        if score[.playerA]! == score[.playerB]! {
            print("\tDRAW")
            showModalAlert(message: "GAME OVER!\nDRAW")
        }
        else {           
            let winner: Game.Player = (score[.playerA]! > score[.playerB]! ? .playerA : .playerB)
            print("\t\(winner.rawValue) WINS")
            showModalAlert(message: "GAME OVER!\n\(winner.rawValue) WINS")
        }
    }
}


extension GameViewController {

    fileprivate func coordinates(tag: Int) -> (x: Int, y: Int) {

        if tag == 49 {
            return (x: 0, y: 0)
        }

        return (x: tag % 7, y: tag / 7)
    }


    fileprivate func tagForCoordinates(x: Int, y: Int) -> Int {

        if x == 0 && y == 0 {
            return 49
        }

        return x + y * 7
    }
}
