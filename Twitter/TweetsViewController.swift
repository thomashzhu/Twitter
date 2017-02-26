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
    
    private var isMoreDataLoading = false
    private var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notification = Notification.Name(rawValue: "replyButtonPressed")
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.replyButtonPressed),
                                               name: notification,
                                               object: nil)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 150
        
        let nib = UINib(nibName: "TweetCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TweetCell")
        
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
    
    func replyButtonPressed(notification: Notification) {
        if let tweet = notification.userInfo?["tweet"] as? Tweet {
            performSegue(withIdentifier: "MessageViewController_REPLY", sender: tweet)
        }
    }
    
    @IBAction func newMessagePressed(_ sender: AnyObject) {
        performSegue(withIdentifier: "MessageViewController_NEW", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let callback: (Bool) -> Void = { successful in
            if successful {
                self.loadMoreTimelineTweets(mode: .RefreshTweets)
            }
        }
        
        if let identifier = segue.identifier {
            if identifier == "MessageViewController_NEW" {
                if let newMessageVC = segue.destination as? MessageViewController {
                    newMessageVC.transitioningDelegate = self
                    newMessageVC.modalPresentationStyle = .custom
                    newMessageVC.updateMode = .New
                    newMessageVC.callback = callback
                }
            } else if identifier == "MessageViewController_REPLY" {
                if let replyMessageVC = segue.destination as? MessageViewController {
                    replyMessageVC.transitioningDelegate = self
                    replyMessageVC.modalPresentationStyle = .custom
                    if let tweet = sender as? Tweet {
                        if let id = tweet.id, let screenName = tweet.screenName {
                            replyMessageVC.updateMode = .Reply(id, screenName)
                            replyMessageVC.callback = callback
                        }
                    }
                }
            }
        }
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
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentingAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissingAnimationController()
    }
}
