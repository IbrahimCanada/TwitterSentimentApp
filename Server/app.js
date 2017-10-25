var express = require('express');
var logger = require('morgan');
var bodyParser = require('body-parser');
var compress = require('compression');

var app = express();
app.use(compress());
app.disable('x-powered-by');

// Mongoose
var mongoose = require('mongoose');
var db = require('./config/db');

if (app.get('env') === 'production') {
    mongoose.connect(db.production);
} else {
    mongoose.connect(db.dev);
}
mongoose.connection.on('error', function() {
    console.log('MongoDB Connection Error. Please make sure that MongoDB is running.');
    process.exit(1);
});

app.use(logger('dev'));
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({
    extended: true
}));

var api = require('./routes/api.v1.js');

app.use('/api/v1', api);

module.exports = app;