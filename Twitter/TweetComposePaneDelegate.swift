//
//  TweetComposePaneDelegate.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/1/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class MessageViewDelegate: NSObject, UIViewControllerTransitioningDelegate {
    
    private let tableView: TweetTableView!
    private let tweet: Tweet?
    
    init(tableViewToBeReloadedUponCompletion tableView: TweetTableView, tweetInReplyTo tweet: Tweet?) {
        self.tableView = tableView
        self.tweet = tweet
    }
    
    enum Mode {
        case New, Reply
    }
    
    
    /* ====================================================================================================
        MARK: - Present MessageViewController
        DESCRIPTION: Present new or reply message pane based on the mode that's passed in
     ====================================================================================================== */
    func present(mode: MessageViewDelegate.Mode) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if let messageVC = storyboard.instantiateViewController(withIdentifier: "MessageViewController") as? MessageViewController {
        
            /*
                This callback will be passed into MessageViewController. Once a tweet is done composing,
                this callback will trigger the loadMoreTweets pass-through method, which will eventually
                be passed to whichever hosting view controller that implements the loadMoreTweets method
             */
            let callback: (Bool) -> Void = { successful in
                if successful {
                    self.tableView.loadMoreTweets(mode: .RefreshTweets)
                }
            }
            
            messageVC.transitioningDelegate = self
            messageVC.modalPresentationStyle = .custom
            
            switch mode {
            case .New:
                messageVC.updateMode = .New
                messageVC.callback = callback
            case .Reply:
                if let tweet = tweet {
                    if let id = tweet.id, let screenName = tweet.screenName {
                        messageVC.updateMode = .Reply(id, screenName)
                        messageVC.callback = callback
                    }
                }
            }
            
            let rootVC = UIApplication.shared.keyWindow?.rootViewController
            rootVC?.present(messageVC, animated: true, completion: nil)
        }
    }
    /* ==================================================================================================== */
    
    
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
