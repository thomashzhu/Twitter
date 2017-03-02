//
//  TweetTableView.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/1/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

protocol ReloadableTweetTableViewProtocol {
    func loadMoreTimelineTweets(mode: TwitterClient.LoadingMode)
}

class TweetTableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var hostingVC: ReloadableTweetTableViewProtocol!
    var tweets: [Tweet]!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dataSource = self
        self.delegate = self
        self.estimatedRowHeight = 150
        
        let nib = UINib(nibName: "TweetCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "TweetCell")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as? TweetCell {
            configureUI(cell: cell, indexPath: indexPath)
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    func loadMoreTweets(mode: TwitterClient.LoadingMode) {
        hostingVC.loadMoreTimelineTweets(mode: mode)
    }
    
    private func configureUI(cell: TweetCell, indexPath: IndexPath) {
        
        let tweet = tweets[indexPath.row]
        cell.tweet = tweet
        
        // If the network is slow, it might take a while to load a retweeted user's name, so UI changes might
        // be delayed. For the following if block, it decides whether to show or hide the retweet status view
        // right away, WITHOUT waiting for a retweet user's name to be returned.
        if tweet.retweetCount > 0 {
            cell.retweetedByLabel.text = "..."
            cell.retweetStatusView.isHidden = false
        } else {
            cell.retweetStatusView.isHidden = true
        }
        
        if let url = tweet.profileImageURL {
            cell.profileImageView.setImageWith(url)
        }
        
        cell.usernameLabel.text = tweet.name
        
        cell.screenNameLabel.text = tweet.screenName
        
        if let timestamp = tweet.timestamp {
            cell.timestampLabel.text = TwitterClient.tweetTimeFormatted(timestamp: timestamp)
        }
        
        cell.tweetLabel.text = tweet.text
        
        cell.cellHeightAdjustmentClosure = {
            self.reloadRows(at: [indexPath], with: .none)
        }
        cell.determineRetweetStatusAndUpdateUI()
        
        cell.replyButtonClosure = {
            let delegate = MessageViewDelegate(tableView: self, tweet: tweet)
            delegate.present(mode: .Reply)
        }
        
        if let favorited = tweet.favorited {
            cell.configureFavoriteButton(favorited: favorited)
        }
    }
    
    

}
