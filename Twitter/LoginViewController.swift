//
//  LoginViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func onLoginButton(_ sender: AnyObject) {
        if let client = TwitterClient.shared {
            client.login(
                success: {
                    self.performSegue(withIdentifier: "LoginSegue", sender: nil)},
                failure: { (error) in
                    print(error.localizedDescription)}
            )
        }
    }
}
