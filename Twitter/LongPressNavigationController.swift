//
//  LongPressNavigationController.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/4/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class LongPressNavigationController: UINavigationController, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.presentAccountListViewController(gesture:)))
        longPressRecognizer.delegate = self
        navigationBar.addGestureRecognizer(longPressRecognizer)
        navigationBar.isUserInteractionEnabled = true
    }

    func presentAccountListViewController(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let vc = storyboard.instantiateViewController(withIdentifier: "AccountListViewController") as? AccountListViewController {
                vc.transitioningDelegate = self
                vc.modalPresentationStyle = .custom
                
                present(vc, animated: true, completion: nil)
            }
        }
    }
    
    /* ====================================================================================================
     MARK: - UIViewControllerTransitioningDelegate method with Facebook POP
     ====================================================================================================== */
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimationController()
    }
    /* ==================================================================================================== */
}
