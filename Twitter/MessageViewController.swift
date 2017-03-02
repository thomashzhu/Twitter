//
//  MessageViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/23/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    var updateMode: TwitterClient.UpdateMode?   // .New or .Reply
    var callback: ((Bool) -> Void)?             // Code to be called once tweet is done composing
    
    private var placeholder: String?
    private var inReplyToScreenName: String?
    
    private var inReplyToUserMention: String {
        if let inReplyToScreenName = inReplyToScreenName {
            return "@\(inReplyToScreenName) "
        }
        return ""
    }
    
    /* ====================================================================================================
        MARK: - Lifecycle method
        DESCRIPTION: Delegation and UI preparation
     ====================================================================================================== */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messageTextView.delegate = self;
        
        // Round-cornered view
        backgroundView.layer.cornerRadius = 12.0
        backgroundView.clipsToBounds = true
        
        // Generate the placeholder text (as in UITextField)
        if let updateMode = updateMode {
            switch updateMode {
            case .New:
                doneButton.setTitle("COMPOSE", for: .normal)
                placeholder = "New tweet..."
            case .Reply(_, let screenName):
                inReplyToScreenName = screenName
                
                doneButton.setTitle("REPLY", for: .normal)
                placeholder = "In reply to \(screenName)..."
            }
        }
        
        messageTextView.text = placeholder
        messageTextView.alpha = 0.75
    
        characterCountLabel.text = ""
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - IBActions
     ====================================================================================================== */
    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        if let updateMode = updateMode {
            
            // Retrieve the ID of the original tweet, if any
            let inReplyToStatusId: String? = {
                switch updateMode {
                case .New:
                    return nil
                case .Reply(let inReplyToStatusId, _):
                    return inReplyToStatusId
                }
            }()
            
            // Store current text so that API failure won't erase what user wrote
            let currentText = inReplyToUserMention + messageTextView.text
            
            // Call update status API if text has changed
            if let placeholder = placeholder, currentText != placeholder {
                TwitterClient.shared?.updateStatus(message: inReplyToUserMention + messageTextView.text,
                                     inReplyToStatusId: inReplyToStatusId,
                                     success: { _ in
                                        self.dismiss(animated: true) { self.callback?(true) }},
                                     failure: { (error) in
                                        self.messageTextView.text = currentText
                                        
                                        let ac = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                                        ac.addAction(okAction)
                                        self.present(ac, animated: true, completion: nil)
                    }
                )
            } else {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    /* ==================================================================================================== */
    
    
    /* ====================================================================================================
     MARK: - UITextViewDelegate methods
     ====================================================================================================== */
    
    // Erase placeholder text once editing begins
    func textViewDidBeginEditing(_ textView: UITextView) {
        messageTextView.text = ""
        messageTextView.alpha = 1
        messageTextView.becomeFirstResponder()
    }
    
    // Update remaining character count, constantly
    func textViewDidChange(_ textView: UITextView) {
        let count = textView.text.characters.count
        
        if let updateMode = updateMode {
            switch updateMode {
            case .New:
                characterCountLabel.text = "\(count) out of 140 characters"
            case .Reply:
                let remainingCharacterCount = 140 - inReplyToUserMention.characters.count
                characterCountLabel.text = "\(count) out of \(remainingCharacterCount) characters (prefixing \(inReplyToUserMention))"
            }
        }
    }
    
    // Accept text changes as long as it's within the character limit, otherwise deny
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return !(textView.text.characters.count >= 140 - inReplyToUserMention.characters.count)
    }
    /* ==================================================================================================== */
}
