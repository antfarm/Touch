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

    var okButtonTitle: String?
    var okAction: (() -> ())?

    var cancelButtonTitle: String?
    var cancelAction: (() -> ())?

    var alertView: AlertView { return view as! AlertView }


    override var prefersStatusBarHidden: Bool { return true }


    override func viewDidLoad() {
        super.viewDidLoad()

        alertView.setMessageText(message: message)

        if let okButtonTitle = okButtonTitle {
            alertView.setOKButtonTitle(title: okButtonTitle)
        }

        if let cancelButtonTitle = cancelButtonTitle {
            alertView.setCancelButtonTitle(title: cancelButtonTitle)
        }

        if okAction == nil && cancelAction == nil {
            alertView.hideCancelButton()
        }
        
        if Config.UI.roundedCorners {
            alertView.makeRoundedCorners()
        }
    }


    @IBAction func okButtonPressed(_ sender: UIButton) {

        self.dismiss(animated: false) { self.okAction?() }
    }


    @IBAction func cancelButtonPressed(_ sender: UIButton) {

        self.dismiss(animated: false) { self.cancelAction?() }
    }
}


extension UIViewController {

    func showModalAlert(message: String,
                        okTitle: String? = nil, okAction: (() -> ())? = nil,
                        cancelTitle: String? = nil, cancelAction: (() -> ())? = nil) {

        let alertViewController =
            storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController

        alertViewController.message = message

        alertViewController.okButtonTitle = okTitle
        alertViewController.okAction = okAction

        alertViewController.cancelButtonTitle = cancelTitle
        alertViewController.cancelAction = cancelAction

        present(alertViewController, animated: false)
    }
}
