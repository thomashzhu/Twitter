//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class TweetsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    private(set) var tweets = [Tweet]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self
        
        TwitterClient.shared?.homeTimeline(
            success: { (tweets) in
                self.tweets = tweets
                self.tableView.reloadData()
            }, failure: { (error) in
                print(error.localizedDescription)}
        )
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: Substitute with custom cell later
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    
    @IBAction func onLogoutButton(_ sender: AnyObject) {
        TwitterClient.shared?.logout()
    }
}
