//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import pop

class TweetsViewController: UIViewController, UIScrollViewDelegate, UIViewControllerTransitioningDelegate, ReloadableTweetTableViewProtocol {
    
    private(set) var tableView = TweetTableView()
    private(set) var tweets = [Tweet]()
    
    private(set) var messageViewDelegate: MessageViewDelegate!
    
    private let refreshControl = UIRefreshControl()
    
    private var isMoreDataLoading = false
    private var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tweets = tweets
        
        // Set up Pull-to-refresh view
        refreshControl.addTarget(self, action: #selector(self.loadMoreTimelineTweets(mode:)), for: .valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        loadMoreTimelineTweets(mode: .EarlierTweets)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
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
    }
    
    func loadMoreTimelineTweets(mode: TwitterClient.LoadingMode) {
        TwitterClient.shared?.homeTimeline(
            mode: mode,
            success: { (tweets) in
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()

                switch mode {
                case .RefreshTweets:
                    self.tweets.insert(contentsOf: tweets, at: 0)
                    self.refreshControl.endRefreshing()
                case .EarlierTweets:
                    self.tweets.append(contentsOf: tweets)
                }
                
                self.tableView.reloadData()},
            failure: { (error) in
                print(error.localizedDescription)}
        )
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (!isMoreDataLoading) {
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.isDragging) {
                isMoreDataLoading = true
                
                let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                loadMoreTimelineTweets(mode: .EarlierTweets)
            }
        }
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.shared?.logout()
    }
    
    @IBAction func newMessagePressed(_ sender: AnyObject) {
        messageViewDelegate = MessageViewDelegate(vc: self, tweet: nil)
        messageViewDelegate.present(mode: .New)
    }
}
