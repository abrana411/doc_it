const jwt = require('jsonwebtoken');
//This middleware will verify token and set the req.user to id for easy access in case verified and if not then this will simply return the error message
//and this will be used in each of the auth protected routes
const authMid = async(req,res,next)=>{
  try {
    // console.log("Yooo");
    //get the token from the header
    const token = req.header("User_token");
    if(!token)
    {
        res.status(401).json({errMsg:"No token is provided, Access denied"});
    }
    
    const isVerified = await jwt.verify(token,process.env.JWT_SECRET);
    if(!isVerified)
    {
        res.status(401).json({errMsg:"Verification of token failed, Access denied"});
    }

    //else if the token is valid then we will simply set the req.user so that in wheich ever route this is going next (since this is middle ware) the id of the signed in user could be accessed using the req.user only
    req.user = isVerified.id;
    req.token = token;//also storing the token in the req.token keyword so that could access this in the next() routes
    next();
  } catch (error) {
    res.status(500).json({errMsg:`An error has occured with message : ${error}`})
  }
};

module.exports = authMid;