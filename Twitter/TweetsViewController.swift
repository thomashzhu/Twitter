//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private(set) var tweets = [Tweet]()
    
    private(set) var isMoreDataLoading = false
    private(set) var loadingMoreView: InfiniteScrollActivityView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 120
        
        let nib = UINib(nibName: "TweetCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "TweetCell")
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: tableView.contentSize.height, width: tableView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset
        insets.bottom += InfiniteScrollActivityView.defaultHeight
        tableView.contentInset = insets
        
        loadTimelineTweets()
    }
    
    func loadTimelineTweets() {
        TwitterClient.shared?.homeTimeline(
            success: { (tweets) in
                self.isMoreDataLoading = false
                self.loadingMoreView!.stopAnimating()

                self.tweets.append(contentsOf: tweets)
                self.tableView.reloadData()
        }, failure: { (error) in
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
                
                loadTimelineTweets()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as? TweetCell {
            let tweet = tweets[indexPath.row]
            cell.tweet = tweet
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
}
