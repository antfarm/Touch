//
//  MenuViewController.swift
//  Touch
//
//  Created by sean on 09/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit


class MenuViewController: UIViewController {

    enum State {

        case initial
        case gameInProgress
    }


    fileprivate var game: Game?

    fileprivate var remoteGameSession: RemoteGameSession?

    private var menuView: MenuView { return view as! MenuView }

    private var state: State = .initial {
        didSet {
            menuView.showMenuForState(state: state)
        }
    }


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
            state = .initial
        }
        else {
            state = .gameInProgress
        }
    }


    @IBAction func newGame(_ sender: UIButton) {

        game = Game()
        remoteGameSession = nil

        showGame()
    }


    @IBAction func newNetworkGame(_ sender: UIButton) {

        game = Game()

        remoteGameSession = RemoteGameSession()
        remoteGameSession!.start()

        showGame()
    }
    
    
    @IBAction func continueGame(_ sender: UIButton) {

        showGame()
    }


    @IBAction func resignGame(_ sender: UIButton) {

        remoteGameSession!.stop()
        
        game = nil
        remoteGameSession = nil

        state = .initial
    }
}


extension MenuViewController {

    func showGame() {

        performSegue(withIdentifier: "showGameSegue", sender: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showGameSegue" {

            if let gameVC = segue.destination as? GameViewController {

                gameVC.game = game
                gameVC.remoteGameSession = remoteGameSession
            }
        }
    }
}
