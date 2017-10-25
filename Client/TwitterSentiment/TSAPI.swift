//
//  TSAPI.swift
//  TwitterSentiment
//
//  Created on 3/30/17.
//  Copyright © 2017 IBRAHIM MANSSOURI. All rights reserved.
//

import Alamofire
import SwiftyJSON

// Class to unify all API request functions
public struct TSAPI {

    private static let baseURL = "http://localhost:3000/api/v1"

    private enum ResourcePath: CustomStringConvertible {
        case Trending
        case Tweets
        case UpdateTweets
        
        case Stats


        var description: String {
            switch self {
            case .Trending: return "/trends"
            case .Tweets: return "/tweets"
            case .UpdateTweets: return "/update"
                
            case .Stats: return "/stats"

            }
        }
    }

    // GET /trends : Retrieve local trending topics
    public static func getTrending(latitude: String, longitude: String, completion: @escaping (Bool, JSON?) -> ()) {
        let urlString = baseURL + ResourcePath.Trending.description
        
        let parameters: [String: String] = [
            "latitude": latitude,
            "longitude": longitude
        ]
        
        Alamofire.request(urlString, method: .get, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json["data"])
                case .failure(let error):
                    let json = JSON(error)
                    print(json)
                    completion(false, json)
        }
        }
    }
    
    // GET /tweets : Retrieve analysed tweets
    public static func getTweets(page: Int, query: String, completion: @escaping (Bool, JSON?) -> ()) {
        let urlString = baseURL + ResourcePath.Tweets.description
        
        let limit = 20
        let skip = page * limit
        
        
        let parameters: [String: String] = [
            "skip": String(skip),
            "limit": String(limit),
            "query": query
        ]
        
        Alamofire.request(urlString, method: .get, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json["data"])
                case .failure(let error):
                    let json = JSON(error)
                    print(json)
                    completion(false, json)
                }
        }
    }
    
    // GET /update : Tell server to update tweets for query
    public static func updateTweets(query: String, completion: @escaping (Bool, JSON?) -> ()) {
        let urlString = baseURL + ResourcePath.UpdateTweets.description
        
        let parameters: [String: String] = [
            "query": query
        ]
        
        Alamofire.request(urlString, method: .get, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json["data"])
                case .failure(let error):
                    let json = JSON(error)
                    print(json)
                    completion(false, json)
                }
        }
    }
    
    /* Stats */
    // GET /stats : Retrieve categorised sentiments data set
    public static func updateStats(query: String, completion: @escaping (Bool, JSON?) -> ()) {
        let urlString = baseURL + ResourcePath.Stats.description
        
        let parameters: [String: String] = [
            "query": query
        ]
        
        Alamofire.request(urlString, method: .get, parameters: parameters)
            .validate()
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    completion(true, json["data"])
                case .failure(let error):
                    let json = JSON(error)
                    print(json)
                    completion(false, json)
                }
        }
    }
    
    
}
