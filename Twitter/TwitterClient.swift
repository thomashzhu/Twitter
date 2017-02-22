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
    
    func retweet(id: Int, success: @escaping (Void) -> Void, failure: @escaping (Error) -> Void) {
        post("1.1/statuses/retweet/\(id).json",
            parameters: nil,
            progress: nil,
            success: { (_, response: Any?) in
                if let _ = response as? [String: AnyObject] {
                    success()
                }
            },
            failure: { (_, error: Error) in
                failure(error)
        })
    }
    
    enum FavoriteMode {
        case Create, Destroy
    }
    
    func favorite(mode: FavoriteMode, id: Int, success: @escaping (Void) -> Void, failure: @escaping (Error) -> Void) {
        post("1.1/favorites/\(mode == .Create ? "create" : "destroy").json",
            parameters: ["id": id],
            progress: nil,
            success: { (_, _) in
                success()
            },
            failure: { (_, error: Error) in
                failure(error)
        })
    }
}
