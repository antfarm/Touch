//
//  AlertViewController.swift
//  Touch
//
//  Created by sean on 08/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

import UIKit

class AlertViewController: UIViewController {

    var message: String!

    @IBOutlet var alertView: UIView!
    @IBOutlet var okButton: UIButton!
    @IBOutlet var labelMessage: UILabel!


    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.layer.cornerRadius = 8
        okButton.layer.cornerRadius = 8

        labelMessage.layer.masksToBounds = true
        labelMessage.layer.cornerRadius = 8

        labelMessage.text = message
    }


    @IBAction func okButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
    }
}

