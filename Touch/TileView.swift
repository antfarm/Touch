//
//  TileView.swift
//  Touch
//
//  Created by sean on 08/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit


class TileView: UIView {

    func setEmpty() {
        backgroundColor = UIColor.white
    }

    func setOwnedByPlayerA() {
        backgroundColor = UIColor.yellow
    }

    func setOwnedByPlayerB() {
        backgroundColor = UIColor.orange
    }

    func setDestroyed() {
        backgroundColor = UIColor(white: 1, alpha: 0.6)
    }
}
