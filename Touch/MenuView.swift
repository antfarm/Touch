//
//  MenuView.swift
//  Touch
//
//  Created by sean on 09/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit


class MenuView: UIView {

    @IBOutlet var stackView: UIStackView!

    @IBOutlet var newGameButton: UIButton!
    @IBOutlet var continueGameButton: UIButton!
    @IBOutlet var resignGameButton: UIButton!


    private lazy var menuButtons: [UIButton] = {
        return self.stackView.subviews.filter { $0 is UIButton }
    }() as! [UIButton]

    
    private lazy var visibleMenuButtonsForState: [MenuViewController.State: [UIButton]] = [

        .empty: [

        ],

        .initial: [
            self.newGameButton,
        ],

        .gameInProgress: [
            self.continueGameButton,
            self.resignGameButton
        ]
    ]


    func showMenuForState(state: MenuViewController.State) {

        if let buttons = visibleMenuButtonsForState[state] {
            showMenuWithButtons(visibleButtons: buttons)
        }
    }


    private func showMenuWithButtons(visibleButtons: [UIButton]) {

        func shouldShowButton(button: UIButton) -> Bool {
            return visibleButtons.contains(button)
        }

        for button in menuButtons {
            button.isHidden = !shouldShowButton(button: button)
        }
    }


    func makeRoundedCorners() {

        for button in menuButtons {
            button.layer.cornerRadius = 8
        }
    }
}
