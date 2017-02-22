//
//  TwitterClient.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import KeychainAccess

class TwitterClient: BDBOAuth1SessionManager {
    
    static let bundleIdenfitier = "com.thomaszhu.Twitter"
    
    static let shared = TwitterClient(baseURL: URL(string: "https://api.twitter.com"),
                                                                    consumerKey: "rJGhM2NZQdkIeawgHNxNNnaGL",
                                                                    consumerSecret: "FY6zm7jSgifroGt4Lm64M0PAzTwNPJQTgzxpJaeBI0irqT874X")
    
    @objc enum LoadingMode: Int {
        case RefreshTweets
        case EarlierTweets
    }
    var maxTweetId: Int?
    var minTweetId: Int?
    
    var loginSuccess: (() -> Void)?
    var loginFailure: ((Error) -> Void)?
    
    func homeTimeline(mode: LoadingMode, success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        
        var parameters = ["count": 20]
        switch mode {
        case .RefreshTweets:
            if let maxTweetId = maxTweetId {
                parameters["since_id"] = maxTweetId
            }
        case .EarlierTweets:
            if let minTweetId = minTweetId {
                parameters["max_id"] = minTweetId - 1
            }
        }
        
        get("1.1/statuses/home_timeline.json",
            parameters: parameters,
            progress: nil,
            success: { (_, response: Any?) in
                if let dictionaries = response as? [[String: AnyObject]] {
                    let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
                    
                    let tweetIDs = tweets.reduce([]) { (result, tweet) -> [Int] in
                        if let id = tweet.id {
                            return result + [id]
                        } else {
                            return result
                        }
                    }
                    self.maxTweetId = tweetIDs.sorted().last
                    self.minTweetId = tweetIDs.sorted().first
                    
                    success(tweets)
                }
            },
            failure: { (_, error: Error) in
                failure(error)
        })
    }
    
    func currentAccount(success: @escaping (User) -> Void, failure: @escaping (Error) -> Void) {
        get("1.1/account/verify_credentials.json",
            parameters: nil,
            progress: nil,
            success: { (_, response: Any?) in
                if let userDictionary = response as? [String: AnyObject] {
                    let user = User(dictionary: userDictionary)
                    success(user)
                }
            },
            failure: { (_, error: Error) in
                failure(error)
        })
    }
    
    func login(success: @escaping () -> Void, failure: @escaping (Error) -> Void) {
        
        loginSuccess = success
        loginFailure = failure
        
        deauthorize()
        fetchRequestToken(withPath: "oauth/request_token",
                          method: "GET",
                          callbackURL: URL(string: "twitterdemo://oauth"),
                          scope: nil,
                          success: { (requestToken: BDBOAuth1Credential?) -> Void in
                            if let token = requestToken?.token,
                                let url = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(token)") {
                                UIApplication.shared.open(url,
                                                          options: [:],
                                                          completionHandler: nil)
                            }},
                          failure: { (error: Error?) in
                            print("error: \(error?.localizedDescription ?? "unknown")")
                            if let error = error {
                                self.loginFailure?(error)
                            }}
        )
    }
    
    func logout() {
        User.currentUser = nil
        deauthorize()
        requestSerializer.removeAccessToken()
        
        NotificationCenter.default.post(
            name: User.userDidLogoutNotification,
            object: nil
        )
    }
    
    func handleOpenUrl(url: URL) {
        
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "/oauth/access_token",
                         method: "POST",
                         requestToken: requestToken,
                         success: { (accessToken: BDBOAuth1Credential?) in
                            
                            if let accessToken = accessToken {
                                let keychain = Keychain(service: TwitterClient.bundleIdenfitier)
                                if let token = accessToken.token,
                                    let secret = accessToken.secret {
                                    keychain["access_token"] = token
                                    keychain["access_token_secret"] = secret
                                }
                            }
                            
                            self.currentAccount(
                                success: { (user) in
                                    User.currentUser = user
                                    self.loginSuccess?()},
                                failure: { (error) in
                                    self.loginFailure?(error)
                            })
                            
                            self.loginSuccess?()},
                         failure: { (error: Error?) in
                            print("error: \(error?.localizedDescription ?? "unknown")")
                            if let error = error {
                                self.loginFailure?(error)
                            }}
        )
    }
    
    func loadAccessToken() -> Bool {
        requestSerializer.removeAccessToken()
        
        let keychain = Keychain(service: TwitterClient.bundleIdenfitier)
        if let accessToken = keychain["access_token"],
            let accessTokenSecret = keychain["access_token_secret"] {
            
            let generatedToken = BDBOAuth1Credential(token: accessToken, secret: accessTokenSecret, expiration: nil)
            requestSerializer.saveAccessToken(generatedToken)
            
            return true
        }
        return false
    }
    
    enum RetweetMode {
        case Retweet, Unretweet
    }
    
    func retweet(mode: RetweetMode, tweet: Tweet, success: @escaping (Void) -> Void, failure: @escaping (Error) -> Void) {
        switch mode {
        case .Retweet:
            if let id = tweet.id {
                post("1.1/statuses/retweet/\(id).json",
                    parameters: nil,
                    progress: nil,
                    success: { _ in success() },
                    failure: { (_, error: Error) in
                        failure(error)
                })
            }
        case .Unretweet:
            let dictionary = tweet.dictionary
            
            let originalTweetId: String? = {
                if let retweetStatus = dictionary["retweeted_status"] as? [String: AnyObject], !retweetStatus.isEmpty {
                    return retweetStatus["id_str"] as? String
                } else {
                    return dictionary["id_str"] as? String
                }
            }()
            
            if let _ = originalTweetId {
                if let id = tweet.id {
                    get("https://api.twitter.com/1.1/statuses/show.json?id=\(id)",
                        parameters: ["include_my_retweet": 1],
                        progress: nil,
                        success: { (_, response: Any?) in
                            if let fullTweetDictionary = response as? [String: AnyObject] {
                                if let retweetId = fullTweetDictionary["current_user_retweet"]?["id_str"] as? String {
                                    self.post("1.1/statuses/destroy/\(retweetId).json",
                                        parameters: nil,
                                        progress: nil,
                                        success: { _ in success() },
                                        failure: { (_, error: Error) in
                                            failure(error)
                                    })
                                }
                            }},
                        failure: { (_, error: Error) in
                            failure(error)
                    })
                }
            }
        }
    }
    
    enum FavoriteMode {
        case Create, Destroy
    }
    
    func favorite(mode: FavoriteMode, tweet: Tweet, success: @escaping (Void) -> Void, failure: @escaping (Error) -> Void) {
        if let id = tweet.id {
            post("1.1/favorites/\(mode == .Create ? "create" : "destroy").json",
                parameters: ["id": id],
                progress: nil,
                success: { _ in success() },
                failure: { (_, error: Error) in
                    failure(error)
            })
        }
    }
    
    func retweetedUserScreenName(id: Int, success: @escaping (String) -> Void, failure: @escaping (Error) -> Void) {
        get("1.1/statuses/retweets/\(id).json",
            parameters: ["count": 1],
            progress: nil,
            success: { (_, response: Any?) in
                if let response = response as? [[String: AnyObject]] {
                    if let screenName = response.first?["user"]?["screen_name"] as? String {
                        success(screenName)
                    }
                }
        },
            failure: { (_, error: Error) in
                failure(error)
        })
    }
    
    static func tweetTimeFormatted(timestamp: Date) -> String {
        
        let interval = timestamp.timeIntervalSinceNow
        
        if interval < 60 * 60 * 24 {
            let seconds = -Int(interval.truncatingRemainder(dividingBy: 60))
            let minutes = -Int((interval / 60).truncatingRemainder(dividingBy: 60))
            let hours = -Int((interval / 3600))
            
            let result = (hours == 0 ? "" : "\(hours)h ") + (minutes == 0 ? "" : "\(minutes)m ") + (seconds == 0 ? "" : "\(seconds)s")
            return result
        } else {
            let formatter: DateFormatter = {
                let f = DateFormatter()
                f.dateFormat = "EEE/MMM/d"
                return f
            }()
            return formatter.string(from: timestamp)
        }
    }
}
