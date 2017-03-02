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
    
    @IBOutlet weak var retweetStatusView: UIStackView!
    @IBOutlet weak var retweetedByLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    @IBOutlet weak var tweetLabel: UILabel!
    
    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var favoriteCountLabel: UILabel!
    
    var tweet: Tweet!
    
    var cellHeightAdjustmentClosure: ((Void) -> Void)?
    var replyButtonClosure: ((Void) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.clipsToBounds = true
    }
    
    // MARK: - IBActions
    
    @IBAction func replyButtonTapped(_ sender: AnyObject) {
        if let replyButtonClosure = replyButtonClosure {
            replyButtonClosure()
        }
    }
    
    @IBAction func retweetButtonTapped(_ sender: AnyObject) {
        if let retweeted = tweet.retweeted {
            TwitterClient.shared?.retweet(mode: (retweeted ? .Unretweet : .Retweet),
                                          tweet: tweet,
                                          success: { (_) in
                                            self.tweet.retweeted = !retweeted
                                            self.tweet.retweetCount += (retweeted ? -1 : 1)
                                            DispatchQueue.main.async {
                                                self.setupRetweetStatView(completion: self.cellHeightAdjustmentClosure)
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
                                            self.tweet.favoritesCount += (favorited ? -1 : 1)
                                            DispatchQueue.main.async {
                                                self.configureFavoriteButton(favorited: !favorited)
                                            }},
                                           failure: { (error) in
                                            print(error.localizedDescription)}
            )
        }
    }
    
    // MARK: - Determine if a retweet is retweeted by the current user
    
    /*
     * The purpose is to determine if the current user is included among the users that 
     * have retweeted the tweet. If there is no retweet at all, then no check is needed.
     * However, if there is at least one, then we have to call the show status id API,
     * and see if there is a current_user_retweet key in the response.
     */
    func determineRetweetStatusAndUpdateUI() {
        if tweet.retweetCount > 0 {
            getIsRetweetedByCurrentUser(completion: cellHeightAdjustmentClosure)
        } else {
            tweet.retweeted = false
            retweetStatusView.isHidden = true
            configureRetweetButton(retweeted: false)
        }
    }
    
    // Step 1: Determine if this retweeted tweet is retweeted by the current user
    private func getIsRetweetedByCurrentUser(completion: ((Void) -> Void)?) {
        TwitterClient.shared?.getTweetDetail(tweet: tweet,
                                             success: { (tweet) in
                                                DispatchQueue.main.async {
                                                    if let _ = self.tweet.tweetDetail?["current_user_retweet"] {
                                                        self.tweet.retweeted = true
                                                        self.configureRetweetButton(retweeted: true)
                                                    } else {
                                                        self.tweet.retweeted = false
                                                        self.configureRetweetButton(retweeted: false)
                                                    }
                                                    self.setupRetweetStatView(completion: completion)
                                                }},
                                             failure: { (error) in
                                                print(error.localizedDescription)}
        )
    }
    
    // Step 2: If so, get one of the user's screen name that retweeted the tweet
    private func setupRetweetStatView(completion: ((Void) -> Void)?) {
        
        var retrievingScreenName = false
        
        if tweet.retweetCount > 0 {
            if let screenName = tweet.retweetUserScreenName {
                self.tweet.retweetUserScreenName = screenName
            } else if !tweet.retweetInfoUnretrievable {
                if let id = tweet.id {
                    retrievingScreenName = true
                    TwitterClient.shared?.retweetedUserScreenName(id: id,
                                                                  success: { (screenName) in
                                                                    self.tweet.retweetUserScreenName = screenName
                                                                    DispatchQueue.main.async {
                                                                        self.configureRetweetStatUI(
                                                                            screenName: screenName,
                                                                            completion: completion
                                                                        )
                                                                    }},
                                                                  failure: { (error) in
                                                                    print(error.localizedDescription)}
                    )
                }
            }
        }
        
        if !retrievingScreenName {
            configureRetweetStatUI(screenName: tweet.retweetUserScreenName, completion: completion)
        }
    }
    
    // Step 3: Configure retweet stat UI view
    private func configureRetweetStatUI(screenName: String?, completion: ((Void) -> Void)?) {
        if let screenName = screenName {
            
            if retweetStatusView.isHidden {
                retweetStatusView.isHidden = false
                if let completion = completion {
                    completion()
                }
            }
            
            switch tweet.retweetCount {
            case 1:
                retweetedByLabel.text = "\(screenName) retweeted"
            case 2:
                retweetedByLabel.text = "\(screenName) and 1 other retweeted"
            default:
                retweetedByLabel.text = "\(screenName) and \(tweet.retweetCount - 1) others retweeted"
            }
        } else {
            retweetStatusView.isHidden = true
            layoutIfNeeded()
        }
    }
    
    // - MARK: Configure the Retweet Button
    func configureRetweetButton(retweeted: Bool) {
        let image = UIImage(named: (retweeted ? "retweet-icon-green" : "retweet-icon"))
        retweetButton.setImage(image, for: .normal)
        retweetCountLabel.text = "\(tweet.retweetCount)"
    }
    
    // - MARK: Configure the Favorite Button
    func configureFavoriteButton(favorited: Bool) {
        let image = UIImage(named: (favorited ? "favor-icon-red" : "favor-icon"))
        favoriteButton.setImage(image, for: .normal)
        favoriteCountLabel.text = "\(tweet.favoritesCount)"
    }
}
