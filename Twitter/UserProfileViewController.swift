//
//  UserProfileViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/2/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, ReloadableTweetTableViewProtocol {

    var userId: String!
    private(set) var presentingUser: User?
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountCountLabel: UILabel!
    
    @IBOutlet weak var tableView: TweetTableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor.white
        
        userProfileImageView.layer.cornerRadius = 5.0
        userProfileImageView.clipsToBounds = true
        
        tableView.hostingVC = self
        
        let client = TwitterClient.shared
        
        client?.userLookup(userId: userId,
                                         success: { user in
                                            self.configureUserStats(user: user)
        },
                                         failure: {
                                            error in print(error.localizedDescription)
        })
        
        client?.userTimeline(userId: userId,
                                           success: { tweets in
                                            self.tableView.tweets = tweets
                                            self.tableView.reloadData() },
                                           failure: { error in print(error.localizedDescription) })
    }

    
    /* ====================================================================================================
        MARK: - IBActions
     ====================================================================================================== */
    @IBAction func newMessagePressed(_ sender: Any) {
        let messageViewDelegate = MessageViewDelegate(tableViewToBeReloadedUponCompletion: tableView, tweetInReplyTo: nil)
        messageViewDelegate.present(mode: .New)
    }
    /* ==================================================================================================== */
    
    
    
    /* ====================================================================================================
        MARK: - Configure user stats using information returned from the user lookup API call
     ====================================================================================================== */
    private func configureUserStats(user: User) {
        if let urlString = user.profileBackgroundImageUrl, let url = URL(string: urlString) {
            backgroundImageView.setImageWith(url)
        }
        
        if let url = user.profileUrl {
            userProfileImageView.setImageWith(url)
        }
        usernameLabel.text = user.name
        screenNameLabel.text = user.screenName
        
        tweetCountLabel.text = "\(user.tweetCount ?? 0)"
        followingCountLabel.text = "\(user.followingCount ?? 0)"
        followerCountCountLabel.text = "\(user.followerCount ?? 0)"
        
        if User.isCurrentUser(user: user) {
            navigationItem.title = "Me"
        } else {
            navigationItem.title = user.name
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - ReloadableTweetTableViewProtocol protocol method
        DESCRIPTION: Load tweets based on modes - Refresh (scrolling up) or Earlier (scrolling down)
     ====================================================================================================== */
    func loadMoreTweets(mode: TwitterClient.LoadingMode) {
        TwitterClient.shared?.homeTimeline(
            mode: mode,
            success: { (tweets) in
                self.tableView.isMoreDataLoading = false
                self.tableView.loadingMoreView!.stopAnimating()
                
                switch mode {
                case .RefreshTweets:
                    self.tableView.tweets.insert(contentsOf: tweets, at: 0)
                    self.tableView.tableViewRefreshControl.endRefreshing()
                case .EarlierTweets:
                    self.tableView.tweets.append(contentsOf: tweets)
                }
                
                self.tableView.reloadData()},
            failure: { (error) in
                print(error.localizedDescription)}
        )
    }
    
    func reloadUponUserChanged(user: User?) {
        if !User.isCurrentUser(user: presentingUser) {
            self.tableView.tweets = []
            
            TwitterClient.shared?.minTweetId = nil
            TwitterClient.shared?.maxTweetId = nil
            loadMoreTweets(mode: .EarlierTweets)
            
            presentingUser = User.currentUser
        }
    }
    /* ==================================================================================================== */
}
