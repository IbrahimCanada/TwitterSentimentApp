//
//  TrendCellTableViewCell.swift
//  TwitterSentiment
//
//  Created on 3/30/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import UIKit

import SwiftyJSON

// Trend cell subclass
class TrendsTableViewCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var tweetVolumeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func configure(with trend: JSON) {
        
        if let name = trend["name"].string {
            self.nameLabel.text = name
        }
        if let tweetVolume = trend["tweet_volume"].int {
            self.tweetVolumeLabel.text = String(tweetVolume) + " tweets!"
        }
        else {
             self.tweetVolumeLabel.text = ""
        }
    }
}
