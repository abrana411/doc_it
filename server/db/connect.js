const mongoose = require('mongoose')

//Simply to run mongoose.connect to connect to the data base
const connectDB = (url) => {
        mongoose.set('strictQuery', false);
        return mongoose.connect(url, {
            useNewUrlParser: true,
            useUnifiedTopology: true,
        });
}

module.exports = connectDB
