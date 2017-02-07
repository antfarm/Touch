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

    @IBAction func newGame(_ sender: UIButton) {
        print("NEW GAME")

        game.reset()
    }


    override func viewDidLoad() {
        super.viewDidLoad()

        indicatorB.alpha = 0
    }


    override var prefersStatusBarHidden: Bool {
        return true
    }

    
    @IBAction func tileTouched(_ button: UIButton) {

        let (x, y) = coordinates(tag: button.tag)
        let t = tag(x: x, y: y)

        print("[\(x) | \(y)] \(t)")

        game.makeMove(x: x, y: y)
    }
}


extension GameViewController: GameDelegate {

    func stateChanged(x: Int, y: Int, state: Game.TileState) {

        print("STATE CHANGED")

        if let view = self.view.viewWithTag(tag(x: x, y: y))?.superview {

            let color: UIColor

            switch state {
            case .empty:
                color = UIColor.white
            case .owned(let player):
                color = player == Game.Player.playerA ? UIColor.yellow : UIColor.orange
            case .destroyed:
                color = UIColor.gray
            }

            view.backgroundColor = color
        }
    }


    func currentPlayerChanged(player: Game.Player) {

        print ("PLAYER CHANGED")

        switch player {

        case .playerA:
            indicatorA.alpha = 1
            indicatorB.alpha = 0
            
        case .playerB:
            indicatorA.alpha = 0
            indicatorB.alpha = 1
        }
    }


    func scoreChanged(score: [Game.Player:Int]) {

        print("SCORE CHANGED")
        labelScoreA.text = "\(score[Game.Player.playerA]!)"
        labelScoreB.text = "\(score[Game.Player.playerB]!)"
    }


    func invalidMove(x: Int, y: Int) {

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
