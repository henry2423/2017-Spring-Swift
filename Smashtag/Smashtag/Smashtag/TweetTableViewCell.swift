//
//  TweetTableViewCell.swift
//  Smashtag
//
//  Created by Henry on 04/08/2017.
//  Copyright © 2017 henry. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {

    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Twitter.Tweet? {
        didSet{
            updateUI()
        }
    }
    

    // whenever our public API tweet is set
    // we just update our outlets using this method
    private func updateUI() {
        tweetTextLabel?.text = tweet?.text
        tweetUserLabel?.text = tweet?.user.description
        
        if let profileImageURL = tweet?.user.profileImageURL {
            // FIXME: blocks main thread
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                let urlContent = try? Data(contentsOf: profileImageURL)
                if let imageData = urlContent, profileImageURL == self?.tweet?.user.profileImageURL {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                }
            }
        } else {
            tweetProfileImageView?.image = nil
        }
        
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
        
    }
}
