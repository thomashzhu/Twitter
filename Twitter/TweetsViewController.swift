//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import pop

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIViewControllerTransitioningDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let refreshControl = UIRefreshControl()
    
    private(set) var tweets = [Tweet]()
    
    private(set) var isMoreDataLoading = false
    private(set) var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 150
        
        let nib = UINib(nibName: "TweetCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TweetCell")
        
        // Set up Pull-to-refresh view
        refreshControl.addTarget(self, action: #selector(TweetsViewController.loadMoreTimelineTweets(mode:)), for: .valueChanged)
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
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.shared?.logout()
    }
    
    @IBAction func newMessagePressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "vc", sender: nil)
    }
    
    private func configureUI(cell: TweetCell, indexPath: IndexPath) {
        
        let tweet = tweets[indexPath.row]
        
        cell.tweet = tweet
        
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
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
        cell.determineRetweetStatusAndUpdateUI()
        
        if let favorited = tweet.favorited {
            cell.configureFavoriteButton(favorited: favorited)
        }
    }
    
    // MARK: - Facebook Pop
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let messageVC = segue.destination as? MessageViewController {
            messageVC.transitioningDelegate = self
            messageVC.modalPresentationStyle = .custom
        }
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimationController()
    }
}
