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
    
    @IBOutlet weak var retweetedIndicatorImageView: UIImageView!
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
                let interval = timestamp.timeIntervalSinceNow
                print(timestamp)
                if interval < 60 * 60 * 24 {
                    let seconds = -Int(interval.truncatingRemainder(dividingBy: 60))
                    let minutes = -Int((interval / 60).truncatingRemainder(dividingBy: 60))
                    let hours = -Int((interval / 3600))
                    
                    let result = (hours == 0 ? "" : "\(hours)h ") + (minutes == 0 ? "" : "\(minutes)m ") + (seconds == 0 ? "" : "\(seconds)s")
                    timestampLabel.text = result
                } else {
                    let formatter: DateFormatter = {
                        let f = DateFormatter()
                        f.dateFormat = "EEE/MMM/d"
                        return f
                    }()
                    timestampLabel.text = formatter.string(from: timestamp)
                }
            }
            
            tweetLabel.text = tweet.text
            
            if let retweeted = tweet.retweeted {
                configureRetweetButton(retweeted: retweeted)
            }
            
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
                                            DispatchQueue.main.async {
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
                                            DispatchQueue.main.async {
                                                self.configureFavoriteButton(favorited: !favorited)
                                            }},
                                           failure: { (error) in
                                            print(error.localizedDescription)}
            )
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
