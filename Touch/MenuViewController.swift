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


    fileprivate var remoteGameSession: RemoteGameSession? {
        didSet {
            remoteGameSession?.connectionDelegate = self
        }
    }


    private var menuView: MenuView { return view as! MenuView }


    private var state: State = .initial {
        didSet {
            menuView.showMenuForState(state: state)
        }
    }


    fileprivate var isInviter = false

    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        if Config.UI.roundedCorners {
            menuView.makeRoundedCorners()
        }

        remoteGameSession = RemoteGameSession()

        remoteGameSession?.startAdvertising()
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

        isInviter = true

//        game = Game()

        //remoteGameSession?.stopAdvertising()
        remoteGameSession?.startBrowsing()



        //showGame()
    }
    
    
    @IBAction func continueGame(_ sender: UIButton) {

        showGame()
    }


    @IBAction func resignGame(_ sender: UIButton) {

        game = nil
        remoteGameSession = RemoteGameSession()

        state = .initial
    }
}


extension MenuViewController: RemoteGameConnectionDelegate {

    func didConnect() {

        print("DID CONNECT: \(remoteGameSession?.connectedPeers)")

        game = Game(player: isInviter ? .playerA : .playerB)

        showGame()
    }


    func didDisconnect() {

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
