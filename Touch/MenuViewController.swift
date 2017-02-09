//
//  MenuViewController.swift
//  Touch
//
//  Created by sean on 09/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    var game: Game?

    var menuView: MenuView { return view as! MenuView }

    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        if Config.UI.roundedCorners {
            menuView.makeRoundedCorners()
        }
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if game == nil || game!.isOver {
            menuView.setPlayButtonTitle(title: "New Game")
        }
        else {
            menuView.setPlayButtonTitle(title: "Continue Game")
        }
    }


    @IBAction func showGame(_ sender: UIButton) {

        showGame()
    }
}


extension MenuViewController {

    func showGame() {

        performSegue(withIdentifier: "showGameSegue", sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showGameSegue" {

            if let gameVC = segue.destination as? GameViewController {

                if game == nil {
                    game = Game()
                }

                if game!.isOver {
                    game!.reset()
                }

                game!.delegate = gameVC
                game!.sendFullState()

                gameVC.game = game

                menuView.setPlayButtonTitle(title: "")
            }
        }
    }
}
