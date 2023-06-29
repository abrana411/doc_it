const mongoose = require('mongoose');

//The user model will simply have the userName , userEmail and the profile picture given by google (There is no need of password here, so we do not have to use the bycrpt.js to tackle thta thing too)
const userSchema = new mongoose.Schema({
    name:{
        type:String,
        required:true,
    },
    email:{
        type:String,
        required:true,
    },
    profilePic:{
        type:String,
        required:true,
    }
});

module.exports = mongoose.model("User",userSchema);//Creating a model in the database (ie collection) and exporting it