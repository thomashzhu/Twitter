//
//  TweetTableView.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/1/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

protocol ReloadableTweetTableViewProtocol {
    func loadMoreTweets(mode: TwitterClient.LoadingMode)
}

class TweetTableView: UITableView, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    var hostingVC: ReloadableTweetTableViewProtocol!
    var tweets: [Tweet]!
    
    // Pull-to-refresh variable
    var tableViewRefreshControl = UIRefreshControl()
    
    // Infinite scrolling variables
    var isMoreDataLoading = false
    var loadingMoreView: InfiniteScrollActivityView?
    
    
    /* ====================================================================================================
        DESCRIPTION: Delegation, UI preparation
     ====================================================================================================== */
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // TableViewDataSource and UITableViewDelegate delegation
        self.dataSource = self
        self.delegate = self
        
        // Associate TweetCell xib to this table view
        let nib = UINib(nibName: "TweetCell", bundle: nil)
        self.register(nib, forCellReuseIdentifier: "TweetCell")
        
        // Set up pull-to-refresh view
        tableViewRefreshControl = UIRefreshControl()
        tableViewRefreshControl.addTarget(self, action: #selector(self.loadMoreTweets(mode:)), for: .valueChanged)
        self.insertSubview(tableViewRefreshControl, at: 0)
        
        // Set up infinite scroll loading indicator
        let frame = CGRect(x: 0, y: self.contentSize.height, width: self.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        self.addSubview(loadingMoreView!)
        
        // ScrollView content size adjustment
        var insets = self.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        self.contentInset = insets
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        DESCRIPTION: Once the new/reply tweet is done composing, this method will be called. The mode (.New or .Reply) 
        will then be passed to whichever hosting view controller that implements the loadMoreTweets method
     ====================================================================================================== */
    func loadMoreTweets(mode: TwitterClient.LoadingMode) {
        hostingVC.loadMoreTweets(mode: mode)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - UITableViewDataSource and UITableViewDelegate protocol methods
     ====================================================================================================== */
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
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - UIScrollViewDelegate protocol methods
     ====================================================================================================== */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x: 0, y: contentSize.height, width: bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreTweets(mode: .EarlierTweets)
            }
        }
    }
    /* ==================================================================================================== */
    
 
    /* ====================================================================================================
        MARK: - Private methods
     ====================================================================================================== */
    
    // MARK: Configure cell UI
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
            let delegate = MessageViewDelegate(tableViewToBeReloadedUponCompletion: self, tweetInReplyTo: tweet)
            delegate.present(mode: .Reply)
        }
        
        if let favorited = tweet.favorited {
            cell.configureFavoriteButton(favorited: favorited)
        }
    }
    /* ==================================================================================================== */
}
