//
//  TweetCell.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/21/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import AFNetworking

class TweetCell: UITableViewCell {

    // MARK: - IBOutlets
    
    @IBOutlet weak var retweetStatusView: UIStackView!
    @IBOutlet weak var retweetedByLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var tweetLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var tweet: Tweet! {
        didSet {
            if let url = tweet.profileImageURL {
                profileImageView.setImageWith(url)
            }
            
            usernameLabel.text = tweet.name
            
            screenNameLabel.text = tweet.screenName
            
            if let timestamp = tweet.timestamp {
                timestampLabel.text = TwitterClient.tweetTimeFormatted(timestamp: timestamp)
            }
            
            tweetLabel.text = tweet.text
            tweetLabel.sizeToFit()
            
            if let retweeted = tweet.retweeted {
                configureRetweetButton(retweeted: retweeted)
            }
            
            setupRetweetStatView()
            
            if let favorited = tweet.favorited {
                configureFavoriteButton(favorited: favorited)
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.clipsToBounds = true
    }
    
    @IBAction func replyButtonTapped(_ sender: AnyObject) {
        // TODO: Implement this
    }
    
    @IBAction func retweetButtonTapped(_ sender: AnyObject) {
        if let retweeted = tweet.retweeted {
            TwitterClient.shared?.retweet(mode: (retweeted ? .Unretweet : .Retweet),
                                          tweet: tweet,
                                          success: { (_) in
                                            self.tweet.retweeted = !retweeted
                                            self.tweet.retweetCount += (retweeted ? -1 : 1)
                                            DispatchQueue.main.async {
                                                self.setupRetweetStatView()
                                                self.configureRetweetButton(retweeted: !retweeted)
                                            }},
                                          failure: { (error) in
                                            print(error.localizedDescription)}
            )
        }
    }
    
    @IBAction func favoriteButtonTapped(_ sender: AnyObject) {
        if let favorited = tweet.favorited {
            TwitterClient.shared?.favorite(mode: (favorited ? .Destroy : .Create),
                                           tweet: tweet,
                                           success: { (_) in
                                            self.tweet.favorited = !favorited
                                            self.tweet.favoritesCount += (favorited ? -1 : 1)
                                            DispatchQueue.main.async {
                                                self.configureFavoriteButton(favorited: !favorited)
                                            }},
                                           failure: { (error) in
                                            print(error.localizedDescription)}
            )
        }
    }
    
    private func setupRetweetStatView() {
        if tweet.retweetCount > 0 {
            if let screenName = tweet.retweetUserScreenName {
                configureRetweetStatUI(screenName: screenName)
            } else if !tweet.retweetInfoUnretrievable {
                if let id = tweet.id {
                    TwitterClient.shared?.retweetedUserScreenName(id: id,
                                                                  success: { (screenName) in
                                                                    DispatchQueue.main.async {
                                                                        self.configureRetweetStatUI(screenName: screenName)
                                                                    }},
                                                                  failure: { (error) in
                                                                    self.configureRetweetStatUI(screenName: nil)
                                                                    print(error.localizedDescription)}
                    )
                }
            } else {
                configureRetweetStatUI(screenName: nil)
            }
        } else {
            configureRetweetStatUI(screenName: nil)
        }
    }
    
    private func configureRetweetStatUI(screenName: String?) {
        if let screenName = screenName {
            
            if retweetStatusView.isHidden {
                retweetStatusView.isHidden = false
                layoutIfNeeded()
            }
            
            switch tweet.retweetCount {
            case 1:
                retweetedByLabel.text = "\(screenName) retweeted"
            case 2:
                retweetedByLabel.text = "\(screenName) and 1 other retweeted"
            default:
                retweetedByLabel.text = "\(screenName) and \(tweet.retweetCount - 1) others retweeted"
            }
        } else {
            retweetStatusView.isHidden = true
            layoutIfNeeded()
        }
    }
        
    private func configureRetweetButton(retweeted: Bool) {
        let image = UIImage(named: (retweeted ? "retweet-icon-green" : "retweet-icon"))
        self.retweetButton.setImage(image, for: .normal)
    }
    
    private func configureFavoriteButton(favorited: Bool) {
        let image = UIImage(named: (favorited ? "favor-icon-red" : "favor-icon"))
        self.favoriteButton.setImage(image, for: .normal)
    }
}
