//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/2/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class TweetDetailViewController: UIViewController {

    @IBOutlet weak var tweetView: TweetView!
    
    var cell: TweetCell!
    var completionBlock: ((TweetView) -> Void)!
    
    /* ====================================================================================================
        MARK: - Lifecycle methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationItem.title = "Tweet"
        
        configureView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // Update retweet and favorite status
        completionBlock(tweetView)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - Helper methods
     ====================================================================================================== */
    private func configureView() {
        tweetView.tweet = cell.tweetView.tweet
        
        if cell.tweetView.retweetStatusView.isHidden {
            tweetView.retweetStatusView.isHidden = true
        } else {
            tweetView.retweetedByLabel.text = cell.tweetView.retweetedByLabel.text
        }
        
        tweetView.profileImageView.image = cell.tweetView.profileImageView.image
        tweetView.profileImageView.userId = cell.tweetView.tweet.userId
        
        tweetView.usernameLabel.text = cell.tweetView.usernameLabel.text
        tweetView.screenNameLabel.text = cell.tweetView.screenNameLabel.text
        
        tweetView.tweetLabel.text = cell.tweetView.tweetLabel.text
        
        tweetView.timestampLabel.text = cell.tweetView.timestampLabel.text
        
        tweetView.retweetCountLabel.text = cell.tweetView.retweetCountLabel.text
        tweetView.favoriteCountLabel.text = cell.tweetView.favoriteCountLabel.text
        
        tweetView.retweetButton.setImage(cell.tweetView.retweetButton.image(for: .normal), for: .normal)
        tweetView.favoriteButton.setImage(cell.tweetView.favoriteButton.image(for: .normal), for: .normal)
    }
    /* ==================================================================================================== */
}
