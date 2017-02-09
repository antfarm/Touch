//
//  MenuViewController.swift
//  Touch
//
//  Created by sean on 09/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    var game: Game!


    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        game = Game()
    }


    @IBAction func showGame(_ sender: UIButton) {

        performSegue(withIdentifier: "showGameSegue", sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showGameSegue" {

            if let gameVC = segue.destination as? GameViewController {

                game.delegate = gameVC
                game.sendFullState()

                gameVC.game = game
            }
        }
    }

}
