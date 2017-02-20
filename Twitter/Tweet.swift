//
//  Tweet.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    let text: String?
    let timestamp: Date?
    let retweetCount: Int
    let favoritesCount: Int
    
    init(dictionary: [String: AnyObject]) {
        text = dictionary["text"] as? String
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
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoritesCount = (dictionary["favourites_count"] as? Int) ?? 0
    }
    
    class func tweetsWithArray(dictionaries: [[String: AnyObject]]) -> [Tweet] {
        return dictionaries.map { Tweet(dictionary: $0) }
    }
}
