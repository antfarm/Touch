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

    
    override func viewDidLoad() {
        super.viewDidLoad()
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
