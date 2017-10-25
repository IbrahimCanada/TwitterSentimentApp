var mongoose = require('mongoose');
mongoose.Promise = require('bluebird');

var Schema = mongoose.Schema;


var TweetQuerySchema = new Schema({

    query: {
        type: String,
        unique: true,
        index: true
    },

    tweets: [{
        type: Schema.Types.ObjectId,
        ref: 'Tweet'
    }],
}, {
    timestamps: true,
    underscored: false
});

var TweetQuery = mongoose.model('TweetQuery', TweetQuerySchema);
module.exports = TweetQuery;