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
    
    private let textViewPlaceholder = "Message..."
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backgroundView.layer.cornerRadius = 12.0
        backgroundView.clipsToBounds = true
        
        messageTextView.delegate = self;
        
        // Substitute to the placeholder function in UITextField
        messageTextView.text = textViewPlaceholder
        messageTextView.alpha = 0.75
    }

    @IBAction func closeButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        messageTextView.text = ""
        messageTextView.alpha = 1
        messageTextView.becomeFirstResponder()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        characterCountLabel.text = "\(textView.text.characters.count)"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        return !(textView.text.characters.count >= 140)
    }
}
