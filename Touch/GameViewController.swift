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

    @IBOutlet var labelScoreA: UILabel!
    @IBOutlet var labelScoreB: UILabel!

    @IBOutlet var indicatorA: UIView!
    @IBOutlet var indicatorB: UIView!


    override func viewDidLoad() {
        super.viewDidLoad()

        game.reset()
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    @IBAction func tileTouched(_ button: UIButton) {

        let (x, y) = coordinates(tag: button.tag)
        let t = tag(x: x, y: y)

        print("\nTILE TOUCHED x: \(x), y: \(y), tag: \(t)")

        game.makeMove(x: x, y: y)
    }


    @IBAction func newGame(_ sender: UIButton) {
        print("NEW GAME")

        game.reset()
    }
}


extension GameViewController: GameDelegate {

    func stateChanged(x: Int, y: Int, state: Game.TileState) {

        print("\t\t\tSTATE CHANGED x: \(x), y: \(y), state: \(state)")

        let buttonTag = tag(x: x, y: y)
        let tileView = self.view.viewWithTag(buttonTag)!.superview as! TileView

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
            indicatorA.alpha = 1
            indicatorB.alpha = 0
            
        case .playerB:
            indicatorA.alpha = 0
            indicatorB.alpha = 1
        }
    }


    func scoreChanged(score: [Game.Player : Int]) {

        print("SCORE CHANGED: \(score[.playerA]!) - \(score[.playerB]!)")

        labelScoreA.text = "\(score[.playerA]!)"
        labelScoreB.text = "\(score[.playerB]!)"
    }


    func invalidMove(x: Int, y: Int) {

        print("\t\tINVALID MOVE x: \(x), y: \(y)")
    }


    func gameOver(score: [Game.Player : Int]) {

        if score[.playerA]! == score[.playerB]! {
            print("\tDRAW")
        }
        else {           
            let winner: Game.Player = (score[.playerA]! > score[.playerB]! ? .playerA : .playerB)
            print("\t\(winner.rawValue) WINS")
        }
    }
}


extension GameViewController {

    // (0, 0) has tag 49

    fileprivate func coordinates(tag: Int) -> (x: Int, y: Int) {

        let tag = tag == 49 ? 0 : tag
        return (x: tag % 7, y: tag / 7)
    }


    fileprivate func tag(x: Int, y: Int) -> Int {

        let tag = x + y * 7
        return tag == 0 ? 49 : tag
    }
}
