//
//  User.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import BDBOAuth1Manager
import KeychainAccess

class User: NSObject {
    
    static let userDidLogoutNotification = Notification.Name("UserDidLogout")
    
    private(set) var uuid: String?
    
    // Current user
    let name: String?
    let screenName: String?
    let profileUrl: URL?
    let tagline: String?
    
    // User lookup
    let profileBackgroundImageUrl: String?
    let userDescription: String?
    let tweetCount: Int?
    let followingCount: Int?
    let followerCount: Int?
    
    var dictionary: [String: AnyObject]
    
    init(dictionary: [String: AnyObject]) {
        
        uuid = dictionary["uuid"] as? String
        
        // Current user
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let profileUrlString = dictionary["profile_image_url_https"] as? String {
            profileUrl = URL(string: profileUrlString)
        } else {
            profileUrl = nil
        }
        tagline = dictionary["description"] as? String
        
        // User lookup
        profileBackgroundImageUrl = dictionary["profile_background_image_url_https"] as? String
        userDescription = dictionary["description"] as? String
        tweetCount = dictionary["statuses_count"] as? Int
        followingCount = dictionary["friends_count"] as? Int
        followerCount = dictionary["followers_count"] as? Int
        
        self.dictionary = dictionary
    }
    
    private static var _currentUser: User?
    class var currentUser: User? {
        get {
            if let _currentUser = _currentUser {
                return _currentUser
            } else {
                let defaults = UserDefaults.standard
                if let data = defaults.data(forKey: "currentUserData"),
                    let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
                    let dictionary = jsonData as? [String: AnyObject] {
                    _currentUser = User(dictionary: dictionary)
                    return _currentUser
                }
                return nil
            }
        }
        set(user) {
            _currentUser = user
            
            let defaults = UserDefaults.standard
            if let user = user {
                if let data = try? JSONSerialization.data(withJSONObject: user.dictionary, options: []) {
                    defaults.set(data, forKey: "currentUserData")
                } else {
                    defaults.set(nil, forKey: "currentUserData")
                }
            } else {
                defaults.set(nil, forKey: "currentUserData")
            }
            defaults.synchronize()
        }
    }
    
    private static var _users: [User]?
    class var users: [User]? {
        get {
            if let _users = _users {
                return _users
            } else {
                let defaults = UserDefaults.standard
                if let data = defaults.data(forKey: "usersData"),
                    let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
                    let userDictionaries = jsonData as? [[String: AnyObject]] {
                    _users = userDictionaries.map { userDictionary in
                        return User(dictionary: userDictionary)
                    }
                    return _users
                }
                return nil
            }
        }
        set(users) {
            _users = users
            
            let defaults = UserDefaults.standard
            if let users = users {
                let userDictionaries: [[String: AnyObject]] = users.map {user in
                    return user.dictionary
                }
                
                if let usersData = try? JSONSerialization.data(withJSONObject: userDictionaries, options: []) {
                    defaults.set(usersData, forKey: "usersData")
                } else {
                    defaults.set(nil, forKey: "usersData")
                }
            } else {
                defaults.set(nil, forKey: "usersData")
            }
            defaults.synchronize()
        }
    }
    
    class func isCurrentUser(user: User?) -> Bool {
        if let currentUser = User.currentUser, let user = user {
            if let currentUserUUID = currentUser.uuid, let userUUID = user.uuid {
                if currentUserUUID == userUUID {
                    return true
                }
            }
        }
        return false
    }
    
    class func saveCurrentUser(user: User, accessToken: BDBOAuth1Credential) {
        let uuid = UUID().uuidString
        user.uuid = uuid
        user.dictionary["uuid"] = uuid as AnyObject?
        
        let keychain = Keychain(service: TwitterClient.bundleIdenfitier)
        if let token = accessToken.token,
            let secret = accessToken.secret {
            keychain["\(uuid)_access_token"] = token
            keychain["\(uuid)_access_token_secret"] = secret
        }
        
        currentUser = user
        if users != nil {
            self.users! += [user]
        } else {
            self.users = [user]
        }
    }
    
    class func loadAccessToken() -> Bool {
        
        if let client = TwitterClient.shared {
            client.requestSerializer.removeAccessToken()
            
            if let currentUser = User.currentUser, let uuid = currentUser.uuid {
                let keychain = Keychain(service: TwitterClient.bundleIdenfitier)
                if let accessToken = keychain["\(uuid)_access_token"],
                    let accessTokenSecret = keychain["\(uuid)_access_token_secret"] {
                    
                    let generatedToken = BDBOAuth1Credential(token: accessToken, secret: accessTokenSecret, expiration: nil)
                    client.requestSerializer.saveAccessToken(generatedToken)
                    
                    return true
                }
            }
        }
        return false
    }
}
