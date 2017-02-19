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

    @IBOutlet var messageLabel: UILabel!
    
    @IBOutlet var okButton: UIButton!
    @IBOutlet var cancelButton: UIButton!


    func makeRoundedCorners() {

        dialogView.layer.cornerRadius = 8

        messageLabel.layer.masksToBounds = true
        messageLabel.layer.cornerRadius = 8

        okButton.layer.cornerRadius = 8
        cancelButton.layer.cornerRadius = 8
    }


    func setMessageText(message: String) {
        
        messageLabel.text = message
    }


    func setOKButtonTitle(title: String) {

        okButton.setTitle(title, for: .normal)
    }


    func setCancelButtonTitle(title: String) {

        cancelButton.setTitle(title, for: .normal)
    }


    func hideCancelButton() {

        cancelButton.isHidden = true
    }
}
