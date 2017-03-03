//
//  AccountListViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 3/2/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit
import KeychainAccess

class AccountListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    var users: [User]!
    private(set) var inEditingMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = UIColor.white
        
        users = User.users
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    /* ====================================================================================================
        MARK: - UITableViewDataSource and UITableViewDelegate protocol methods
     ====================================================================================================== */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        
        let user = users[indexPath.row]
        
        if User.isCurrentUser(user: user) {
            cell.textLabel?.text = "\(user.screenName ?? "") (current session)"
        } else {
            cell.textLabel?.text = user.screenName
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            if User.isCurrentUser(user: users[indexPath.row]) {
                let ac = UIAlertController(title: "Are you sure?",
                                           message: "This is your current session. Deleting this user (you) will log you out of the app.",
                                           preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { _ in
                    self.removeUser(indexPath: indexPath)
                    TwitterClient.shared?.logout()
                }
                ac.addAction(okAction)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                ac.addAction(cancelAction)
                
                present(ac, animated: true, completion: nil)
            } else {
                removeUser(indexPath: indexPath)
            }
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        User.currentUser = users[indexPath.row]
        if User.loadAccessToken() {
            TwitterClient.shared?.currentAccount(
                success: { _ in
                    _ = self.navigationController?.popToRootViewController(animated: true) },
                failure: { error in
                    return print(error.localizedDescription) }
            )
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - IBActions
     ====================================================================================================== */
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        addUser()
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
        MARK: - Helper methods (add / remove user)
     ====================================================================================================== */
    private func addUser() {
        if let client = TwitterClient.shared {
            client.login(
                success: {
                    self.users = User.users
                    self.tableView.reloadData() },
                failure: { (error) in
                    print(error.localizedDescription)}
            )
        }
    }
    
    private func removeUser(indexPath: IndexPath) {
        let removedUser = users.remove(at: indexPath.row)
        
        if let uuid = removedUser.uuid {
            let keychain = Keychain(service: TwitterClient.bundleIdenfitier)
            keychain["\(uuid)_access_token"] = nil
            keychain["\(uuid)_access_token_secret"] = nil
        }
        
        User.users = users
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
    /* ==================================================================================================== */
}
