//
//  MenuView.swift
//  Touch
//
//  Created by sean on 09/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit


class MenuView: UIView {

    enum State {

        case initial
        case gameInProgress
    }


    @IBOutlet var newGameButton: UIButton!

    @IBOutlet var continueGameButton: UIButton!


    var state: State = .initial {
        didSet {

            switch state {

            case .initial:
                newGameButton.isHidden = false
                continueGameButton.isHidden = true

            case .gameInProgress:
                newGameButton.isHidden = true
                continueGameButton.isHidden = false
            }
        }
    }
    

    func makeRoundedCorners() {

        newGameButton.layer.cornerRadius = 8
        continueGameButton.layer.cornerRadius = 8
    }
}
