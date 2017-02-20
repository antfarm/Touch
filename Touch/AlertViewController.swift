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

        let alertVC = storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController

        alertVC.message = message

        alertVC.okButtonTitle = okTitle
        alertVC.okAction = okAction

        alertVC.cancelButtonTitle = cancelTitle
        alertVC.cancelAction = cancelAction

        present(alertVC, animated: false)
    }
}
