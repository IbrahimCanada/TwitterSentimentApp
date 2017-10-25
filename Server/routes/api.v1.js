var express = require('express');
var moment = require('moment');

var api = express.Router();

api.use(function timeLog(req, res, next) {
    console.log('Time: ', moment().format());
    next();
});

// API STATUS ROUTE
api.get('/', function(req, res, next) {
    res.status(200).json({
        status: 'TwitterSentiment API Service is running.'
    });
});

// Twitter Controller
var twitterController = require('../controllers/twitterController');
api.get('/trends', twitterController.trends);
api.get('/tweets', twitterController.tweets);
api.get('/update', twitterController.updateTweets);

var statsController = require('../controllers/statsController');
api.get('/stats', statsController.stats);

module.exports = api;