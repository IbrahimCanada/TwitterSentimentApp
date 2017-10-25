//
//  TweetInfoViewController.swift
//  TwitterSentiment
//
//  Created on 4/1/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import UIKit

import SwiftyJSON

import FontAwesome_swift

// The info view to display tweet specific data
class TweetInfoViewController: UIViewController {

    var tweet: JSON? = nil
    
    @IBOutlet var positiveWordsLabel: UILabel!
    @IBOutlet var negativeWordsLabel: UILabel!
    @IBOutlet var wordsLabel: UILabel!
    @IBOutlet var comparativeScoreLabel: UILabel!
    @IBOutlet var sentimentScoreLabel: UILabel!

    @IBOutlet var closeButton: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let modal = self.view.viewWithTag(1)
        
        modal?.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        UIView.animate(withDuration: 0.25, animations: {
            modal?.layer.transform = CATransform3DMakeScale(1,1,1)
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let modal = self.view.viewWithTag(1)
        modal?.layer.cornerRadius = 10.0
        modal?.layer.borderWidth = 0.5
        modal?.clipsToBounds = true
        modal?.layer.shadowColor = UIColor.black.cgColor
        modal?.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        modal?.layer.shadowRadius = 1
        modal?.layer.shadowOpacity = 0.3
        modal?.layer.masksToBounds = false
        
        // Other
        closeButton.titleLabel?.font = UIFont.fontAwesome(ofSize: 32)
        closeButton.setTitle(String.fontAwesomeIcon(name: .timesCircle), for: .normal)
        
        // Configure Modal
        self.configureModal()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let modal = self.view.viewWithTag(1)

        modal?.layer.transform = CATransform3DMakeScale(1,1,1)
        UIView.animate(withDuration: 0.25, animations: {
            modal?.layer.transform = CATransform3DMakeScale(0.1,0.1,1)
        })
    }
    
    func configureModal() {
        
        let sentimentData = self.tweet?["sentimentData"]
        
        if let positiveWords = sentimentData?["positive"].array {
            self.positiveWordsLabel.text = positiveWords.description
        }
        
        if let negativeWords = sentimentData?["negative"].array {
            self.negativeWordsLabel.text = negativeWords.description
        }
        
        if let tokens = sentimentData?["tokens"].array {
            self.wordsLabel.text = String(tokens.count)
        }
        
        if let comparative = sentimentData?["comparative"].double {
            self.comparativeScoreLabel.text = String(format: "%.2f", comparative)
        }
        
        if let sentimentScore = sentimentData?["score"].double {
            self.sentimentScoreLabel.text = String(sentimentScore)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
