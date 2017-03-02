//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import pop

class TweetsViewController: UIViewController, UIViewControllerTransitioningDelegate, ReloadableTweetTableViewProtocol {
    
    @IBOutlet weak var tableView: TweetTableView!
    
    private(set) var messageViewDelegate: MessageViewDelegate!
    
    
    /* ====================================================================================================
        MARK: - Lifecycle methods
     ====================================================================================================== */
    
    // Set up the TweetTableView and loads tweets
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure UI of the navigation bar
        if let navigationBar = navigationController?.navigationBar {
            
            let height = navigationBar.frame.height
            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: height * 0.5, height: height * 0.5))
            imageView.contentMode = .scaleAspectFit
            
            let image = UIImage(named: "twitter_logo_white_no_bg")
            imageView.image = image
            
            navigationItem.titleView = imageView
            navigationItem.titleView?.alpha = 0.0
            
            UIView.animate(withDuration: 2.0,
                           delay: 0.0,
                           options: .curveEaseOut,
                           animations: { self.navigationItem.titleView?.alpha = 1.0 },
                           completion: nil
            )
        }
        
        self.tableView.hostingVC = self
        self.tableView.tweets = [Tweet]()
        
        self.tableView.estimatedRowHeight = 150
        
        loadMoreTweets(mode: .EarlierTweets)
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
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - IBActions
     ====================================================================================================== */
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.shared?.logout()
    }
    
    @IBAction func newMessagePressed(_ sender: AnyObject) {
        messageViewDelegate = MessageViewDelegate(tableViewToBeReloadedUponCompletion: tableView, tweetInReplyTo: nil)
        messageViewDelegate.present(mode: .New)
    }
    /* ==================================================================================================== */
}
