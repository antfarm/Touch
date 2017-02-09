//
//  AlertView.swift
//  Touch
//
//  Created by sean on 09/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit


class AlertView: UIView {

    @IBOutlet var dialogView: UIView!
    @IBOutlet var labelMessage: UILabel!
    @IBOutlet var okButton: UIButton!


    func makeRoundedCorners() {

        dialogView.layer.cornerRadius = 8

        labelMessage.layer.masksToBounds = true
        labelMessage.layer.cornerRadius = 8

        okButton.layer.cornerRadius = 8
    }


    func setText(message: String) {
        
        labelMessage.text = message
    }
}
