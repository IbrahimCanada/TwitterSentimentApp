//
//  Utils.swift
//  TwitterSentiment
//
//  Created on 3/31/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import UIKit
import Foundation

// Utitlities
struct Utils {
    
    // Loading Indicators
    static func showLoading(_ status: Bool) {
        if(status) {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }
        else {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
    }
    
    static func isLoading() -> Bool {
        return UIApplication.shared.isNetworkActivityIndicatorVisible
    }
}

// Extension to remove the keyboard when a user taps anywhere on the screen
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
