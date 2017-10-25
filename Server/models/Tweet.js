var mongoose = require('mongoose');
mongoose.Promise = require('bluebird');

var Schema = mongoose.Schema;


var TweetSchema = new Schema({

    tweetId: {
        type: String,
        unique: true,
        index: true,
    },

    tweetData: {
        type: Schema.Types.Mixed
    },

    sentimentData: {
        type: Schema.Types.Mixed
    }
}, {
    timestamps: true,
    underscored: false
});

var Tweet = mongoose.model('Tweet', TweetSchema);
module.exports = Tweet;