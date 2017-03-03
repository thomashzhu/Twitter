//
//  UserProfileImageView.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/2/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class UserProfileImageView: UIImageView, UIGestureRecognizerDelegate {

    var userId: String?
    
    override func awakeFromNib() {
        layer.cornerRadius = 5.0
        clipsToBounds = true
        
        // Add tap gesture to trigger tweet detail VC
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.showProfile(tapRecognizer:)))
        tapRecognizer.delegate = self
        self.addGestureRecognizer(tapRecognizer)
        self.isUserInteractionEnabled = true
    }

    /* ====================================================================================================
        MARK: - Segue methods
        DESCRIPTION: Segue to TweetDetailViewController
     ====================================================================================================== */
    func showProfile(tapRecognizer: UITapGestureRecognizer) {
        if let userId = userId {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            if let vc = storyboard.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
                if let navigationController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                    vc.userId = userId
                    navigationController.pushViewController(vc, animated: true)
                }
            }
        }
    }
    /* ==================================================================================================== */
}
