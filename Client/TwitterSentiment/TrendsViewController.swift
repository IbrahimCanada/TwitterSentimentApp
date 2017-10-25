//
//  ViewController.swift
//  TwitterSentiment
//
//  Created on 3/28/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import UIKit
import CoreLocation

import SwiftyJSON

import ChameleonFramework

private let trendCellReuseIdentifier = "TrendCell"

// Trending topics view controller
class TrendsViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    var trends: JSON = []

    @IBOutlet var trendsTableView: UITableView!
    @IBOutlet var searchTextField: UITextField!

    var userLocation: CLLocation?
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.hideKeyboardWhenTappedAround()
        self.navigationController?.hidesNavigationBarHairline = true

        self.trendsTableView.cellLayoutMarginsFollowReadableWidth = false
        self.trendsTableView.separatorColor = UIColor.lightGray
//        self.trendsTableView.contentInset = UIEdgeInsetsMake(-10, 0, 0, 0);
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateTrendingTopics), name: .userLocation, object: nil)

        self.locationManager.requestWhenInUseAuthorization()

        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        self.locationManager.requestLocation()
        
        let refreshControl = UIRefreshControl()
        self.trendsTableView.refreshControl = refreshControl
        self.trendsTableView.refreshControl?.addTarget(self, action: #selector(updateTrending), for: .valueChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK :- Outlets
    @IBAction func searchButtonPressed(_ sender: Any) {
        if let isEmpty = searchTextField.text?.isEmpty {
            if(!isEmpty) {
                self.performSegue(withIdentifier: "SearchTweets", sender: nil)
            }
        }
    }
    
    // MARK :- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowTweets",
            let tcvc = segue.destination as? TweetsCollectionViewController,
                let indexPath = self.trendsTableView.indexPathForSelectedRow {
                    tcvc.query = self.trends[indexPath.row]["query"].stringValue
                    tcvc.name = self.trends[indexPath.row]["name"].stringValue
        }
        
        if segue.identifier == "SearchTweets",
            let tcvc = segue.destination as? TweetsCollectionViewController {
                tcvc.query = self.searchTextField.text
                tcvc.name = self.searchTextField.text
        }
    }
    
    // MARK :- Functions
    
    func updateTrending() {
        self.userLocation = nil
        self.locationManager.requestLocation()
    }
    
    func updateTrendingTopics(notification: NSNotification) {
        if let location = notification.object as? CLLocation {
         
            let latitude = location.coordinate.latitude.description
            let longitude = location.coordinate.longitude.description

            
            TSAPI.getTrending(latitude: latitude, longitude: longitude, completion: { (isSuccessful, data) in
                self.trendsTableView.refreshControl?.endRefreshing()
                if(isSuccessful) {
                    
                    print("success")
                    if let trends = data?["trends"] {
                        self.trends = trends
                        self.trendsTableView.reloadSections([0], with: .bottom)
                    }
                }
                else {
                    print("error")
                }
            })
        }
    }
    
    // MARK :- UITableView Delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.trends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: trendCellReuseIdentifier, for: indexPath) as! TrendsTableViewCell
        
        let trend = self.trends[indexPath.row]
        
        cell.configure(with: trend)
        
        return cell
    }
    
    // MARK :- UITableViewDelegate Delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            if(userLocation == nil) {
                if (location.horizontalAccuracy <= self.locationManager.desiredAccuracy) {
                    self.userLocation = location
                    print("Found user's location: \(location)")
                    
                    NotificationCenter.default.post(name: .userLocation, object: location)
                }
            }
        }
    }
    
    func locationManager(_ locationManager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
}

