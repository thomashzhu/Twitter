//
//  UserProfileViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/2/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class UserProfileViewController: UIViewController, ReloadableTweetTableViewProtocol, UIScrollViewDelegate, UIGestureRecognizerDelegate {

    var userId: String!
    private(set) var presentingUser: User?
    
    @IBOutlet weak var topView: UIView!
    private(set) var originalTopViewFrame: CGRect!
    private(set) var maxTopViewFrame: CGRect!
    @IBOutlet weak var topViewConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var profileInfoStackView: UIStackView!
    private(set) var descriptionLabel = UILabel()
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var userProfileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var tweetCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var followerCountCountLabel: UILabel!
    
    @IBOutlet weak var tableView: TweetTableView!
    
    
    /* ====================================================================================================
        MARK: - Lifecycle methods
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor.white
        
        userProfileImageView.layer.cornerRadius = 5.0
        userProfileImageView.clipsToBounds = true
        
        tableView.hostingVC = self
        
        let client = TwitterClient.shared
        
        client?.userLookup(userId: userId,
                                         success: { user in
                                            self.configureUserStats(user: user)
        },
                                         failure: {
                                            error in print(error.localizedDescription)
        })
        
        client?.userTimeline(userId: userId,
                                           success: { tweets in
                                            self.tableView.tweets = tweets
                                            self.tableView.reloadData() },
                                           failure: { error in print(error.localizedDescription) })
        
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.pan(gestureRecognizer:)))
        pan.delegate = self
        pan.minimumNumberOfTouches = 1
        pan.maximumNumberOfTouches = 1
        scrollView.addGestureRecognizer(pan)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        configureScrollView()
        
        originalTopViewFrame = topView.frame
        maxTopViewFrame = CGRect(x: topView.frame.origin.x,
                                    y: topView.frame.origin.y,
                                    width: topView.frame.width,
                                    height: topView.frame.height * 2)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - IBActions
     ====================================================================================================== */
    @IBAction func newMessagePressed(_ sender: Any) {
        let messageViewDelegate = MessageViewDelegate(tableViewToBeReloadedUponCompletion: tableView, tweetInReplyTo: nil)
        messageViewDelegate.present(mode: .New)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - Configure user stats using information returned from the user lookup API call
     ====================================================================================================== */
    private func configureUserStats(user: User) {
        if let urlString = user.profileBackgroundImageUrl, let url = URL(string: urlString) {
            backgroundImageView.setImageWith(url)
        }
        
        if let url = user.profileUrl {
            userProfileImageView.setImageWith(url)
        }
        usernameLabel.text = user.name
        screenNameLabel.text = user.screenName
        
        descriptionLabel.text = user.userDescription
        
        tweetCountLabel.text = "\(user.tweetCount ?? 0)"
        followingCountLabel.text = "\(user.followingCount ?? 0)"
        followerCountCountLabel.text = "\(user.followerCount ?? 0)"
        
        if User.isCurrentUser(user: user) {
            navigationItem.title = "Me"
        } else {
            navigationItem.title = user.name
        }
    }
    
    private func configureScrollView() {
        let scrollViewWidth: CGFloat = self.scrollView.frame.width
        let scrollViewHeight: CGFloat = self.scrollView.frame.height
        
        let view1 = UIView(frame: CGRect(x: 0, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        view1.addSubview(profileInfoStackView)
        
        descriptionLabel.numberOfLines = 0
        descriptionLabel.lineBreakMode = .byWordWrapping
        descriptionLabel.textAlignment = .center
        descriptionLabel.font = UIFont(name: "Avenir-Book", size: 15)
        descriptionLabel.textColor = UIColor.darkGray
        
        let view2 = UIView(frame: CGRect(x: scrollViewWidth, y: 0, width: scrollViewWidth, height: scrollViewHeight))
        view2.addSubview(descriptionLabel)
        
        self.scrollView.addSubview(view1)
        self.scrollView.addSubview(view2)
        
        self.scrollView.isPagingEnabled = true
        self.scrollView.contentSize = CGSize(width: scrollView.frame.width * 2, height: scrollView.frame.height)
        self.scrollView.delegate = self
        
        applyScrollViewConstraints()
    }
    
    private func applyScrollViewConstraints() {
        
        if let page = scrollView.subviews.first {
            let proportionalHeight1 = NSLayoutConstraint(item: profileInfoStackView, attribute: .height, relatedBy: .equal, toItem: page, attribute: .height, multiplier: 0.85, constant: 0)
            let centerX1 = NSLayoutConstraint(item: profileInfoStackView, attribute: .centerX, relatedBy: .equal, toItem: page, attribute: .centerX, multiplier: 1, constant: 0)
            let centerY1 = NSLayoutConstraint(item: profileInfoStackView, attribute: .centerY, relatedBy: .equal, toItem: page, attribute: .centerY, multiplier: 1, constant: 0)
            profileInfoStackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([proportionalHeight1, centerX1, centerY1])
            
            let proportionalWidth2 = NSLayoutConstraint(item: descriptionLabel, attribute: .width, relatedBy: .equal, toItem: page, attribute: .width, multiplier: 0.85, constant: 0)
            let proportionalHeight2 = NSLayoutConstraint(item: descriptionLabel, attribute: .height, relatedBy: .equal, toItem: page, attribute: .height, multiplier: 0.85, constant: 0)
            let centerX2 = NSLayoutConstraint(item: descriptionLabel, attribute: .centerX, relatedBy: .equal, toItem: page, attribute: .centerX, multiplier: 1, constant: page.frame.width)
            let centerY2 = NSLayoutConstraint(item: descriptionLabel, attribute: .centerY, relatedBy: .equal, toItem: page, attribute: .centerY, multiplier: 1, constant: 0)
            descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([proportionalWidth2, proportionalHeight2, centerX2, centerY2])
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - UIGestureRecognizerDelegate methods
     ====================================================================================================== */
    func pan(gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: scrollView)
        let isVerticalPan = (fabsf(Float(translation.x)) < fabsf(Float(translation.y)))
        
        if isVerticalPan {
            let currentPoint = gestureRecognizer.location(in: self.view)
            let yCoordinate = min(max(currentPoint.y, originalTopViewFrame.maxY), maxTopViewFrame.maxY)
            
            if yCoordinate >= originalTopViewFrame.maxY && yCoordinate <= maxTopViewFrame.maxY {
                topViewConstraint.constant = yCoordinate - originalTopViewFrame.maxY
                
                self.scrollView.contentSize = CGSize(width: scrollView.frame.width * 2, height: yCoordinate - originalTopViewFrame.minY)
                applyScrollViewConstraints()
                
                if !UIAccessibilityIsReduceTransparencyEnabled() {
                    let blurEffect = UIBlurEffect(style: .light)
                    let blurEffectView = UIVisualEffectView(effect: blurEffect)
                    blurEffectView.alpha = 1 - 0.5 * (maxTopViewFrame.maxY / yCoordinate)
                    blurEffectView.frame = userProfileImageView.bounds
                    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                    
                    for subview in userProfileImageView.subviews {
                        if subview is UIVisualEffectView {
                            subview.removeFromSuperview()
                        }
                    }
                    userProfileImageView.addSubview(blurEffectView)
                }
            }
        }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - UIScrollViewDelegate methods
     ====================================================================================================== */
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let maximumOffset = scrollView.contentSize.width - scrollView.frame.width
        let currentOffset = scrollView.contentOffset.x
        let percentage = currentOffset / maximumOffset
        
        let minAlpha: CGFloat = 0.4
        
        backgroundImageView.tintColor = UIColor.black
        backgroundImageView.alpha = 1 - percentage * (1 - minAlpha)
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - ReloadableTweetTableViewProtocol protocol methods
        DESCRIPTION: Load tweets based on modes - Refresh (scrolling up) or Earlier (scrolling down)
     ====================================================================================================== */
    func loadMoreTweets(mode: TwitterClient.LoadingMode) {
        TwitterClient.shared?.userTimeline(userId: userId,
                                           success: { tweets in
                                            self.tableView.isMoreDataLoading = false
                                            self.tableView.loadingMoreView!.stopAnimating()
                                            
                                            switch mode {
                                            case .RefreshTweets:
                                                self.tableView.tableViewRefreshControl.endRefreshing()
                                            case .EarlierTweets:
                                                break
                                            }
                                            
                                            self.tableView.tweets = tweets
                                            self.tableView.reloadData() },
                                           failure: { error in print(error.localizedDescription) }
        )
    }
    
    func reloadUponUserChanged(user: User?) {
        // No action needed (since it's user specific)
    }
    /* ==================================================================================================== */
}
