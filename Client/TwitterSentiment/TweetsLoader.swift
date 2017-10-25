//
//  TweetsLoader.swift
//  TwitterSentiment
//
//  Created on 3/31/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import Foundation

import SwiftyJSON

// Class to handle pagination: loading more tweets as the user scrolls
class TweetsLoader {
    
    typealias TweetsLoaderCompletion = (_ isSuccessful: Bool, _ data:JSON) -> ()
    
    private (set) var hasMore : Bool = false
    private var page : Int = 0
    private var isLoading : Bool = false
    
    func load(query: String, page: Int = 0, completion: @escaping TweetsLoaderCompletion) {
        if isLoading {
            return
        }
        
        isLoading = true
        TSAPI.getTweets(page: page, query: query) { [weak self] (isSuccessful, data) in
            switch isSuccessful {
            case true:
                if let strongSelf = self {
                    strongSelf.hasMore = (data?["tweets"].count)! > 0
                    strongSelf.isLoading = false
                    completion(true, data!)
                }
            case false:
                completion(false, [])
            }
        }
    }
    
    func next(query: String, completion: @escaping TweetsLoaderCompletion) {
        if isLoading {
            return
        }
        
        page += 1
        load(query: query, page: page, completion: completion)
    }
}
