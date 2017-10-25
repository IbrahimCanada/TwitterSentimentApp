module.exports = {

    dev: process.env.MONGODB || process.env.MONGOLAB_URI || process.env.MONGO_URL || 'mongodb://localhost:27017/tsapi',
    production: process.env.MONGODB || process.env.MONGOLAB_URI || process.env.MONGO_URL || 'mongodb://localhost:27017/tsapi',
    test: process.env.MONGODB || process.env.MONGOLAB_URI || process.env.MONGO_URL || 'mongodb://localhost:27017/tsapi'

};