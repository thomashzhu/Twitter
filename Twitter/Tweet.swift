//
//  Tweet.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    let dictionary: [String: AnyObject]
    
    let profileImageURL: URL?
    
    let name: String?
    let screenName: String?
    let timestamp: Date?
    
    let text: String?
    
    // Retweet & Favorite
    let id: String?
    
    var retweetCount: Int
    var favoritesCount: Int
    
    var retweeted: Bool?
    var favorited: Bool?
    
    var retweetUserScreenName: String?
    var retweetInfoUnretrievable: Bool
    
    var tweetDetail: [String: AnyObject]?
    var retweetId: String?
    
    init(dictionary: [String: AnyObject]) {
        
        self.dictionary = dictionary
        
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
        
        self.id = {
            if let retweetStatus = dictionary["retweeted_status"] as? [String: AnyObject], !retweetStatus.isEmpty {
                return retweetStatus["id_str"] as? String
            } else {
                return dictionary["id_str"] as? String
            }
        }()
        
        self.retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        self.favoritesCount = (dictionary["favorite_count"] as? Int) ?? 0
        
        self.favorited = dictionary["favorited"] as? Bool
        
        retweetInfoUnretrievable = false
    }
    
    class func tweetsWithArray(dictionaries: [[String: AnyObject]]) -> [Tweet] {
        return dictionaries.map { Tweet(dictionary: $0) }
    }
}
