//
//  TweetsCollectionViewCell.swift
//  TwitterSentiment
//
//  Created on 3/31/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import UIKit

import SwiftyJSON
import AlamofireImage

import ActiveLabel
import FontAwesome_swift

// Cell subclass to configure the tweet cells
class TweetsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var screenNameLabel: UILabel!
    @IBOutlet var textLabel: ActiveLabel!
    @IBOutlet var retweetCountLabel: UILabel!
    @IBOutlet var favoriteCountLabel: UILabel!
    @IBOutlet var sentimentScoreLabel: UILabel!
    
    override func awakeFromNib() {
        self.layer.cornerRadius = 3.0
        
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        self.layer.shadowRadius = 1
        self.layer.shadowOpacity = 0.3
        self.layer.masksToBounds = false
//        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.contentView.layer.cornerRadius).cgPath

    }

    //  text, user.profile_image_url, user.name, user.screen_name, favorite_count, retweet_count,
    func configure(with tweet: JSON) {
        
        // Sentiment Data
        let sentimentData = tweet["sentimentData"]

        if let score = sentimentData["score"].int {
            
            switch score {
            case 0:
                self.sentimentScoreLabel.text = String(score) + " 😐"
            case _ where score <= -6:
                self.sentimentScoreLabel.text = String(score) + " 😡"
            case _ where score >= 6:
                self.sentimentScoreLabel.text = String(score) + " 😂"
            case _ where score <= -3:
                self.sentimentScoreLabel.text = String(score) + " 😩"
            case _ where score >= 3:
                self.sentimentScoreLabel.text = String(score) + " 😃"
            case _ where score > 0:
                self.sentimentScoreLabel.text = String(score) + " 🙂"
            case _ where score < 0:
                self.sentimentScoreLabel.text = String(score) + " 🙁"
            default:
                self.sentimentScoreLabel.text = String(score) + " 😐"
            }
            
        }
        
        // Twitter Data
        let tweetData = tweet["tweetData"]
        
        if let profileImageURL = tweetData["user"]["profile_image_url"].string,
            let url = URL(string: profileImageURL ) {
            self.profileImageView.af_setImage(withURL: url)
        }

        if let name = tweetData["user"]["name"].string {
            if let verified = tweetData["user"]["verified"].bool,
                verified {
                // TODO: Fix font
                self.nameLabel.font = UIFont.fontAwesome(ofSize: 14)
                self.nameLabel.text = name + " " + String.fontAwesomeIcon(name: .checkCircle)
            }
            else {
                self.nameLabel.text = name
            }
        }
        
        if let screenName = tweetData["user"]["screen_name"].string {
            
            self.screenNameLabel.text = "@" + screenName
        }
        
        if let text = tweetData["text"].string {
            self.textLabel.enabledTypes = [.mention, .hashtag, .url]
            
            let twitterBlue = UIColor(red: 27/255, green: 149/255, blue: 224/255, alpha: 1)
            self.textLabel.hashtagColor = twitterBlue
            self.textLabel.mentionColor = twitterBlue
            self.textLabel.URLColor = twitterBlue
            
            self.textLabel.text = text
        }
        
        if let favoriteCount = tweetData["favorite_count"].int {
            self.favoriteCountLabel.font = UIFont.fontAwesome(ofSize: 12)
            self.favoriteCountLabel.text = String.fontAwesomeIcon(name: .heart) + " " + String(favoriteCount)
        }
        
        if let retweetCount = tweetData["retweet_count"].int {
            self.retweetCountLabel.font = UIFont.fontAwesome(ofSize: 12)
            self.retweetCountLabel.text = String.fontAwesomeIcon(name: .retweet) + " " + String(retweetCount)
        }
        
    }
}
