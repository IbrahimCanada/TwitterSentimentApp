//
//  TweetsCollectionViewController.swift
//  TwitterSentiment
//
//  Created on 3/31/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import UIKit

import SwiftyJSON

private let tweetReuseIdentifier = "TweetCell"

// The tweet feed controller
class TweetsCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var query: String? = nil
    var name: String? = nil
    
    var tweets: JSON = []
    private var tweetsLoader = TweetsLoader()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.hidesNavigationBarHairline = true
        
        self.title = name
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadTweets), name: .updateTweets, object: nil)
        
        let refreshControl = UIRefreshControl()
        self.collectionView?.refreshControl = refreshControl
        self.collectionView?.refreshControl?.addTarget(self, action: #selector(updateTweets), for: .valueChanged)
        
        self.updateTweets();
    }
    
    // MARK :- Functions
    
    func updateTweets() {
        Utils.showLoading(true)

        TSAPI.updateTweets(query: query!) { (isSuccessful, data) in
            if(isSuccessful) {
                NotificationCenter.default.post(name: .updateTweets, object: nil)
            }
        }
    }
    
    func loadTweets() {
        Utils.showLoading(true)
        self.tweetsLoader = TweetsLoader()
        
        self.tweetsLoader.load(query: query!, completion: { (isSuccessful, data) in
            self.collectionView?.refreshControl?.endRefreshing()
            Utils.showLoading(false)
            
//            self.refreshControl?.endRefreshing()
            
            if(isSuccessful) {
                self.tweets = data["tweets"]
                self.collectionView?.reloadData()
            }
            else {
                // TODO-MP: Handle Errors
                print(isSuccessful)
                print(data);
            }
            
        })
    }
    
    func loadMoreTweets() {
        Utils.showLoading(true)
        self.tweetsLoader.next(query: query!) { [unowned self] (isSuccessful, data) in
            Utils.showLoading(false)
            
            if(isSuccessful) {
                let newTweets = data["tweets"]
                
                self.tweets = JSON(self.tweets.arrayObject! + newTweets.arrayObject!)
                self.collectionView?.reloadData()
            }
            else {
                // TODO-LP: Handle Error
                print(data)
            }
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTweetInfo",
            let tivc = segue.destination as? TweetInfoViewController,
                let cell = sender as? TweetsCollectionViewCell,
                    let indexPath = self.collectionView?.indexPath(for: cell) {
                        tivc.tweet = self.tweets[indexPath.row]
        }
        
        if segue.identifier == "ShowStats",
            let nvc = segue.destination as? UINavigationController,
                let svc = nvc.topViewController as? StatsViewController {
            svc.query = query
            svc.name = name
        }
    }
    
    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
    }
    

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return self.tweets.count + (tweetsLoader.hasMore ? 1 : 0)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: tweetReuseIdentifier, for: indexPath) as! TweetsCollectionViewCell
    
        // Configure the cell
        let tweet = self.tweets[indexPath.row]
        
        cell.configure (with: tweet)
        

        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

        if indexPath.row == self.tweets.count {
            self.loadMoreTweets()
        }
    }
}

protocol ContentAwareCollectionViewCell {
    func fittedSizeForConstrainedSize(constrainedSize: CGSize) -> CGSize
}
