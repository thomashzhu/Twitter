//
//  Tweet.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    let retweeted: Bool?
    
    let profileImageURL: URL?
    
    let name: String?
    let screenName: String?
    let timestamp: Date?
    
    let text: String?
    
    let retweetCount: Int
    let favoritesCount: Int
    
    init(dictionary: [String: AnyObject]) {
        
        self.retweeted = dictionary["retweeted"] as? Bool
        
        if let profileImageURLString = dictionary["user"]?["profile_image_url_https"] as? String,
            let profileImageURL = URL(string: profileImageURLString) {
            self.profileImageURL = profileImageURL
        } else {
            self.profileImageURL = nil
        }
        
        self.name = dictionary["user"]?["name"] as? String
        self.screenName = dictionary["user"]?["screen_name"] as? String
        if let timestampString = dictionary["created_at"] as? String {
            let formatter: DateFormatter = {
                let f = DateFormatter()
                f.dateFormat = "EEE MMM d HH:mm:ss Z y"
                return f
            }()
            timestamp = formatter.date(from: timestampString)
        } else {
            timestamp = nil
        }
        
        self.text = dictionary["text"] as? String
        
        // pending
        self.retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        self.favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
    }
    
    class func tweetsWithArray(dictionaries: [[String: AnyObject]]) -> [Tweet] {
        return dictionaries.map { Tweet(dictionary: $0) }
    }
}
