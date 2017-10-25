var _ = require('lodash');
var async = require("async");
var moment = require('moment');
var TweetQuery = require("../models/TweetQuery");



module.exports = {
    stats: function(req, res) {
        const query = req.query.query;

        // moment().startOf('week');    // set to the first day of this week, 12:00 am
        // moment().startOf('isoWeek'); // set to the first day of this week according to ISO 8601, 12:00 am
        // moment().startOf('day');     // set to 12:00 am today
        // moment().startOf('date');     // set to 12:00 am today
        // moment().startOf('hour');    // set to now, but with 0 mins, 0 secs, and 0 ms
        // moment().startOf('minute');  // set to now, but with 0 seconds and 0 milliseconds
        // moment().startOf('second');  // same as moment().milliseconds(0);

        var start = moment().startOf('minute').format('ddd MMM DD HH:mm:ss Z YYYY'); // set to 12:00 am today
        var end = moment().endOf('hour').format('ddd MMM DD HH:mm:ss Z YYYY'); // set to 23:59 pm today

        TweetQuery.findOne({
                query: query,
            })
            .populate({
                path: 'tweets',
                // match: {
                //     'tweetData.created_at': {
                //         $gte: start,
                //         $lt: end
                //     }
                // }
            })
            .exec()
            .then(function(tweetQuery) {
                // total positive (>0)
                //  very postitive (>5)
                // total negative (<0)
                // very negative (<-5)
                // total neutral (=0)
                // for each tweet
                let i = 0;
                let allScores = [];
                let neutralSentiments = [];
                let positiveTweets = [];
                let positiveSentiments = [];
                let negativeTweets = [];
                let negativeSentiments = [];
                _.forIn(tweetQuery.tweets, function(tweet, key) {
                    // console.log(key);
                    let sentimentData = tweet.sentimentData;
                    if (sentimentData !== undefined) {
                        // i++;
                        // 
                        if (sentimentData.score === 0) {
                            neutralSentiments.push(sentimentData.score);
                        } else if (sentimentData.score > 0) {
                            positiveSentiments.push(sentimentData.score);
                        } else if (sentimentData.score < 0) {
                            negativeSentiments.push(sentimentData.score);
                        } else {
                            console.log(sentimentData.score);
                        }


                        allScores.push(sentimentData.score);
                        // console.log(sentimentData.score);
                    }
                });
                res.status(200).json({
                    status: 200,
                    success: true,
                    data: {
                        neutral: neutralSentiments,
                        positive: positiveSentiments,
                        negative: negativeSentiments
                    }
                });


            });
    },
};