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
    
    @IBOutlet weak var replyImageView: UIImageView!
    @IBOutlet weak var retweetImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.clipsToBounds = true
    }
    
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
        }
    }
}
