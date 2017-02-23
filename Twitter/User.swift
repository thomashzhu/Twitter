//
//  User.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/19/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class User: NSObject {

    static let userDidLogoutNotification = Notification.Name("UserDidLogout")
    
    let name: String?
    let screenName: String?
    let profileUrl: URL?
    let tagline: String?
    
    let dictionary: [String: AnyObject]
    
    init(dictionary: [String: AnyObject]) {
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        if let profileUrlString = dictionary["profile_image_url_https"] as? String {
            profileUrl = URL(string: profileUrlString)
        } else {
            profileUrl = nil
        }
        tagline = dictionary["description"] as? String
        
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
}
