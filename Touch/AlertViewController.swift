//
//  AlertViewController.swift
//  Touch
//
//  Created by sean on 08/02/2017.
//  Copyright © 2017 antfarm. All rights reserved.
//

// cf. http://stackoverflow.com/a/25325168/5907161

import UIKit


class AlertViewController: UIViewController {

    var message: String!
    var completion: (() -> ())?

    var alertView: AlertView { return view as! AlertView }


    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        if Config.UI.roundedCorners {
            alertView.makeRoundedCorners()
        }

        alertView.setText(message: message)
    }


    @IBAction func okButtonPressed(_ sender: UIButton) {

        self.dismiss(animated: false) { self.completion?() }
    }
}


extension UIViewController {

    func showModalAlert(message: String, completion: (() -> ())? = nil) {

        let alertViewController = storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController

        alertViewController.message = message
        alertViewController.completion = completion

        present(alertViewController, animated: false, completion: nil)
    }
}
