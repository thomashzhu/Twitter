//
//  DismissingAnimationController.swift
//  TipCalculator
//
//  Created by Thomas Zhu on 12/18/16.
//  Copyright © 2016 Thomas Zhu. All rights reserved.
//

import Foundation
import UIKit
import pop

class DismissingAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.85;
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view!
        toView.alpha = 1
        toView.isUserInteractionEnabled = true
        
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view!
        
        let closeAnimation = POPBasicAnimation(propertyNamed: kPOPLayerPositionY)!
        closeAnimation.toValue = CGFloat(-fromView.layer.position.y)
        closeAnimation.completionBlock = { (anim, finished) in
            transitionContext.completeTransition(true)
        }
        
        let scaleDownAnimation = POPSpringAnimation(propertyNamed: kPOPLayerScaleXY)!
        scaleDownAnimation.springBounciness = 20
        scaleDownAnimation.toValue = NSValue(cgPoint: CGPoint(x: 0, y: 0))
        
        fromView.layer.pop_add(closeAnimation, forKey: "closeAnimation")
        fromView.layer.pop_add(scaleDownAnimation, forKey: "scaleDown")
    }
}
