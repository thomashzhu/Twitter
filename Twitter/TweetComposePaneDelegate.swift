//
//  TweetComposePaneDelegate.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/1/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

protocol ReloadableTweetTableViewProtocol {
    func loadMoreTimelineTweets(mode: TwitterClient.LoadingMode)
}

class TweetComposePaneDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let vc: ReloadableTweetTableViewProtocol
    private let tweet: Tweet
    
    init(vc: ReloadableTweetTableViewProtocol, tweet: Tweet) {
        self.vc = vc
        self.tweet = tweet
    }
    
    enum Mode {
        case New, Reply
    }
    
    func present(mode: TweetComposePaneDelegate.Mode) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController {
        
            let callback: (Bool) -> Void = { successful in
                if successful {
                    self.vc.loadMoreTimelineTweets(mode: .RefreshTweets)
                }
            }
            
            switch mode {
            case .New:
                messageVC.transitioningDelegate = self
                messageVC.modalPresentationStyle = .custom
                messageVC.updateMode = .New
                messageVC.callback = callback
                
            case .Reply:
                messageVC.transitioningDelegate = self
                messageVC.modalPresentationStyle = .custom
                if let id = tweet.id, let screenName = tweet.screenName {
                    messageVC.updateMode = .Reply(id, screenName)
                    messageVC.callback = callback
                }
            }
        }
    }
    
    // MARK: - Facebook Pop
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimationController()
    }
}
