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

        case empty
        case initial
        case gameInProgress
    }


    var game: Game!

    var remoteGameService: RemoteGameService! {
        didSet {
            remoteGameService.advertiserDelegate = self
        }
    }
    

    fileprivate var state: State = .initial {
        didSet {
            guard state != oldValue else { return }
            
            switch state {
            case .initial:
                remoteGameService.startAdvertising()
            default:
                remoteGameService.stopAdvertising()            }
        }
    }
    
    
    var gameViewController: GameViewController!

    fileprivate var menuView: MenuView { return view as! MenuView }


    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        if Config.UI.roundedCorners {
            menuView.makeRoundedCorners()
        }

        remoteGameService.startAdvertising()

        gameViewController = storyboard?.instantiateViewController(withIdentifier: "GameViewController") as! GameViewController

        gameViewController.game = game
        gameViewController.remoteGameService = remoteGameService
    }


    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if game.isOver {
            state = .initial
            game.reset()
        }

        menuView.showMenuForState(state: state)
    }


    @IBAction func newGame(_ sender: UIButton) {

        menuView.showMenuForState(state: .empty)

        state = .gameInProgress

        game.reset()
        gameViewController.remotePlayer = nil

        showGame()
    }


    @IBAction func continueGame(_ sender: UIButton) {

        showGame()
    }


    @IBAction func resignGame(_ sender: UIButton) {

        menuView.showMenuForState(state: .initial)

        state = .initial
        game.reset()
    }


    func showGame() {

        present(gameViewController, animated:false)
    }
}


extension MenuViewController: RemoteGameAdvertiserDelegate {

    func didReceiveInvitation(peer: String, invitationHandler: @escaping (Bool) -> Void) {

        showModalAlert(message: "Accept invitation from \(peer)?",
                       okTitle: "Accept",
                       okAction: {
                            invitationHandler(true)

                            self.menuView.showMenuForState(state: .empty)
                            self.state = .gameInProgress

                            self.game.reset()

                            self.gameViewController.remotePlayer = .playerA
                            self.showGame()
                        },
                       cancelTitle: "Reject", cancelAction: { invitationHandler(false) })
    }
}
