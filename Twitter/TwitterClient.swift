//
//  TwitterClient.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let shared = TwitterClient(baseURL: URL(string: "https://api.twitter.com"),
                                                                    consumerKey: "rJGhM2NZQdkIeawgHNxNNnaGL",
                                                                    consumerSecret: "FY6zm7jSgifroGt4Lm64M0PAzTwNPJQTgzxpJaeBI0irqT874X")
    
    var loginSuccess: (() -> Void)?
    var loginFailure: ((Error) -> Void)?
    
    func homeTimeline(success: @escaping ([Tweet]) -> Void, failure: @escaping (Error) -> Void) {
        get("1.1/statuses/home_timeline.json",
            parameters: nil,
            progress: nil,
            success: { (_, response: Any?) in
                if let dictionaries = response as? [[String: AnyObject]] {
                    let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
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
                    
                    print("name: \(user.name)")
                    print("screenname: \(user.screenName)")
                    print("profile url: \(user.profileUrl)")
                    print("description: \(user.tagline)")
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
}
