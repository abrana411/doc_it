const express = require('express');
const connectDB = require('./db/connect');
const app = express();
const cors = require('cors');
require('dotenv').config();

//getting the routers:-
const authRouter = require('./routes/auth');
//Using middleWares:-
app.use(cors());
app.use(express.json());
app.use('/api',authRouter);

//Getting port:-
const PORT = process.env.PORT || 3001;

const start = async function(){
    try {
      //Try connecting to the data base:-
      await connectDB(process.env.MONGO_URL);
      console.log("Database is connected!!");
      app.listen(PORT,()=>{
         console.log(`Listening on ${PORT}`);
     })
    } catch (error) {
      console.log(error);
      //to kill the process now:-
      process.exit(1);
    }
 };
 
 //invoking the start method:-
 start();