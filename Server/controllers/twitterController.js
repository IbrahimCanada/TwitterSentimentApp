var _ = require('lodash');
var async = require("async");
var sentiment = require("sentiment");
var emojis = require("../utils/emojis.json");

var Tweet = require("../models/Tweet");
var TweetQuery = require("../models/TweetQuery");

var Twit = require("twit");
var twitterConfig = require("../config/twitter");

var T = new Twit({
    consumer_key: twitterConfig.key,
    consumer_secret: twitterConfig.secret,
    app_only_auth: true,
    timeout_ms: 60 * 1000, // optional HTTP request timeout to apply to all requests.
});


module.exports = {

    // User will send location coordinates
    // Find nearest places using twitter api
    // Find trending topics
    // Return list of trending topics
    trends: function(req, res) {
        const latitude = req.query.latitude;
        const longitude = req.query.longitude;

        console.log(latitude);
        console.log(longitude);

        findClosestWOIED(latitude, longitude)
            .then(woeid => findTrendingTopics(woeid)
                .then(trends => {
                    res.status(200).json({
                        success: true,
                        data: {
                            trends: trends
                        }
                    });
                })).catch(function(error) {
                console.log('caught error', error.stack);
                sendJSONError(res, error);
            });
    },

    tweets: function(req, res) {

        const query = req.query.query;
        console.log(query);

        const limit = parseInt(req.query.limit) || 25;
        const skip = parseInt(req.query.skip) || 0;

        // Find the query (should exist!)
        // And return it
        TweetQuery.findOne({
                query: query
            })
            .populate({
                path: 'tweets',
                options: {
                    sort: {
                        'tweetData.id': -1
                    },
                    limit: limit,
                    skip: skip
                }
            })
            .exec()
            .then(function(tweetQuery) {
                if (tweetQuery) {
                    // console.log("EXISTING QUERY");

                    res.status(200).json({
                        success: true,
                        data: {
                            tweets: tweetQuery.tweets
                        }
                    });

                } else {
                    // console.log("NEW QUERY");
                    res.status(400).json({
                        success: false,
                        data: {
                            message: "Query doesn't exist."
                        }
                    });
                }
            });
    },

    // Fetch 200 tweets, save to database
    // Open stream to keep fetching tweets
    // Save tweets to database as they come
    // return latest tweets to user only from database
    // perform sentiment analysis on tweet
    // 
    //  Find the new tweets analyze them
    //  Pass them over to new function
    //  Find colleciton existing or not
    //  If existing check every tweet if exists in collection
    //  return collection
    updateTweets: function(req, res) {
        const query = req.query.query;
        // console.log(query);

        // Find existing collection
        // Or create a new one
        async.waterfall([
                function(callback) {
                    findTweets(query)
                        .then(tweets => {
                            var tweetsArray = [];

                            // Start of loop
                            console.time("sentiment");

                            async.forEachOf(tweets, function(tweet, key, next) {
                                analyseSentiment(tweet)
                                    .then(score => {
                                        Tweet.findOne({
                                                tweetId: tweet.id_str
                                            })
                                            .exec()
                                            .then(function(existingTweet) {
                                                if (existingTweet) {
                                                    // console.log("existing");
                                                    tweetsArray.push(existingTweet._id);
                                                    next();
                                                } else {
                                                    // console.log("new");
                                                    // console.log(score);
                                                    let newTweet = new Tweet();
                                                    newTweet.tweetId = tweet.id_str;
                                                    newTweet.tweetData = tweet;
                                                    newTweet.sentimentData = score;

                                                    newTweet.save(function(err) {
                                                        if (!err) {
                                                            tweetsArray.push(newTweet._id);
                                                            next();
                                                        } else {
                                                            console.log(err);
                                                            next(err);
                                                        }
                                                    });
                                                }
                                            });
                                    });
                            }, function(err) {
                                // End of loop
                                if (err) {
                                    console.error(err.message);
                                } else {
                                    console.timeEnd("sentiment");

                                    callback(null, tweets, tweetsArray);
                                }
                            });
                        });
                },
                function(tweets, tweetsArray, callback) {

                    TweetQuery.findOne({
                            query: query
                        })
                        .exec()
                        .then(function(tweetQuery) {
                            if (!tweetQuery) {
                                // console.log("NEW QUERY");
                                tweetQuery = new TweetQuery();
                                tweetQuery.query = query;
                                tweetQuery.tweets = _.unionWith(tweetQuery.tweets, tweetsArray, _.isEqual);
                                tweetQuery.save(function(err) {
                                    if (!err) {
                                        callback(null, tweets, tweetQuery);
                                    } else {
                                        console.log(err);
                                    }
                                });
                                // callback(null, tweetQuery);
                            } else {
                                // console.log("EXISTING QUERY");
                                tweetQuery.tweets = _.unionWith(tweetQuery.tweets, tweetsArray, _.isEqual);
                                tweetQuery.save(function(err) {
                                    if (!err) {
                                        callback(null, tweets, tweetQuery);
                                    } else {
                                        console.log(err);
                                    }
                                });
                            }
                        });

                }
            ],
            function(err, tweets, tweetQuery) {
                // result now equals 'done'
                console.log("DONE");

                // console.log(tweetQuery);
                res.status(200).json({
                    success: true,
                    data: {
                        message: "Update complete for query."
                    }
                });

            });
    }
};

var findClosestWOIED = function(latitude, longitude) {
    let promise = new Promise(function(resolve, reject) {
        T.get('trends/closest', {
                lat: latitude,
                long: longitude
            }).catch(function(error) {
                console.log('caught error', error.stack);
                reject(error);
            })
            .then(function(result) {
                let data = result.data[0];
                let woeid = data.woeid;

                resolve(woeid);
            });
    });

    return promise;
};

var findTrendingTopics = function(woeid) {
    let promise = new Promise(function(resolve, reject) {
        T.get('trends/place', {
                id: woeid
            }).catch(function(error) {
                console.log('caught error', error.stack);
                reject(error);
            })
            .then(function(result) {
                let data = result.data[0];
                let trends = data.trends;

                // Sort trends
                // trends.sort(dynamicSort("-tweet_volume"));
                resolve(trends);
            });
    });

    return promise;
};

var findTweets = function(query) {
    let promise = new Promise(function(resolve, reject) {
        T.get('search/tweets', {
                q: query,
                count: 100,
                lang: "en",
                result_type: "mixed"
            }).catch(function(error) {
                console.log('caught error', error.stack);
                reject(error);
            })
            .then(function(result) {
                console.log("Updating");
                // console.log(result.data);
                // let data = result.data[0];
                // let tweets = data.tweets;
                resolve(result.data.statuses);
            });
    });

    return promise;
};

var analyseSentiment = function(tweet) {
    let promise = new Promise(function(resolve) {
        var score = sentiment(tweet.text, emojis);
        // console.log(answer);
        resolve(score);
    });

    return promise;
};


// Utilities
function sendJSONError(response, error) {
    return response.status(400).json({
        status: 400,
        success: "false",
        data: error
    });
}

// Used to sort trends
function dynamicSort(property) {
    var sortOrder = 1;
    if (property[0] === "-") {
        sortOrder = -1;
        property = property.substr(1);
    }
    return function(a, b) {
        var result = (a[property] < b[property]) ? -1 : (a[property] > b[property]) ? 1 : 0;
        return result * sortOrder;
    };
}