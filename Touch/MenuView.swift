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


    private lazy var menuButtons: [UIButton] = {
        return self.stackView.subviews
            .filter { $0 is UIButton }.map { $0 as! UIButton }
    }()


    private lazy var visibleMenuButtonsForState: [MenuViewController.State: [UIButton]] = [

        .initial:        [self.newGameButton],
        .gameInProgress: [self.continueGameButton]
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
    

//    private lazy var statesVisible: [UIButton: [MenuViewController.State]] = [
//
//        self.newGameButton: [.initial],
//        self.continueGameButton: [.gameInProgress]
//    ]
//
//
//    private func shouldHide(button: UIButton, forState state: MenuViewController.State) -> Bool {
//
//        guard let statesVisible = statesVisible[button] else {
//            return false
//        }
//
//        return !statesVisible.contains(state)
//    }
//
//
//    func showMenuForState(state: MenuViewController.State) {
//
//        for button in statesVisible.keys  {
//            button.isHidden = shouldHide(button: button, forState: state)
//        }
//    }


    func makeRoundedCorners() {

        newGameButton.layer.cornerRadius = 8
        continueGameButton.layer.cornerRadius = 8
    }
}
