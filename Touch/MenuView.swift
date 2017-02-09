//
//  MenuView.swift
//  Touch
//
//  Created by sean on 09/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit


class MenuView: UIView {

    @IBOutlet var playButton: UIButton!


    func makeRoundedCorners() {

        playButton.layer.cornerRadius = 8
    }


    func setPlayButtonTitle(title: String) {

        playButton.setTitle(title, for: .normal)
    }
}
