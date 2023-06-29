const userModel = require("../models/user_model");
const jwt = require('jsonwebtoken');
//SPI method for sign in the user , basically if the user exists we will not do any thing else if not then we will create a document or new user into the data base
const signInUser = async(req,res)=>{
  try {
    // console.log("Yoo");
    const {name,email,profilePic} = req.body;
    //check if user already exists in db:-
    let user = await userModel.findOne({email:email});
    if(!user)
    {
        //If not there then we will create one
        user = new userModel({name:name,email:email,profilePic:profilePic});
        user = await user.save();//saving it to the database
    }
    
    //Signing the user to get the token: (which will be used for the state persistence later)
    const token = jwt.sign({ id: user._id}, process.env.JWT_SECRET, { //as the payload giving the user id only , and passing the jwt secret key from the .env file
        expiresIn: process.env.JWT_EXPIRETIME, //exiring time from env too
    });
    // console.log(user);
    res.json({token,...user._doc}); //simply placing the token as a field in the user document and then returning it so that could access the token using the res.body['token'] only in the client side
  } catch (error) {
    res.status(500).json({errmsg:`There is an error with message : ${error}`});
  } 
};


const getUserData = async(req,res)=>{
  try {
    //Since this will be a protected route under the auth middleware so we will be using the req.user and the req.token to get the id and the token as set in the auth middleware
    const token = req.token;
    const id = req.user;

    //get the user
    const user = await userModel.findById(id);
    res.json({token,...user._doc});
  } catch (error) {
    res.status(500).json({errmsg:`There is an error with message : ${error}`});
  }
};

module.exports = {signInUser,getUserData};