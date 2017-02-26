//
//  MessageViewController.swift
//  Twitter
//
//  Created by Thomas Zhu on 2/23/17.
//  Copyright © 2017 Thomas Zhu. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    
    @IBOutlet weak var doneButton: UIButton!
    
    var updateMode: TwitterClient.UpdateMode?
    var callback: ((Bool) -> Void)?
    
    private var placeholder: String?
    private var inReplyToScreenName: String?
    
    private var inReplyToUserMention: String {
        if let inReplyToScreenName = inReplyToScreenName {
            return "@\(inReplyToScreenName) "
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 12.0
        backgroundView.clipsToBounds = true
        
        messageTextView.delegate = self;
        
        // Substitute to the placeholder function in UITextField
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

    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        if let updateMode = updateMode {
            
            let inReplyToStatusId: String? = {
                switch updateMode {
                case .New:
                    return nil
                case .Reply(let inReplyToStatusId, _):
                    return inReplyToStatusId
                }
            }()
            
            if let placeholder = placeholder, inReplyToUserMention + messageTextView.text != placeholder {
                TwitterClient.shared?.updateStatus(message: inReplyToUserMention + messageTextView.text,
                                     inReplyToStatusId: inReplyToStatusId,
                                     success: { _ in
                                        self.dismiss(animated: true) { self.callback?(true) }},
                                     failure: { (error) in
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
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        messageTextView.text = ""
        messageTextView.alpha = 1
        messageTextView.becomeFirstResponder()
    }
    
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return !(textView.text.characters.count >= 140 - inReplyToUserMention.characters.count)
    }
}
