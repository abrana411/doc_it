const express = require('express');
const connectDB = require('./db/connect');
const http = require('http');//for creating a server (for the socket to work on)
const cors = require('cors');
require('dotenv').config();

const app = express();
//Making socket get the io object (which is used for listening to when the socket connection is established by any client with this server)
var server = http.createServer(app);
var io = require('socket.io')(server); //getting the socket object
//will use this io below now (above the save method)

//getting the routers:-
const authRouter = require('./routes/auth');
const docRouter = require('./routes/doc');
const authMid = require('./middlewares/auth_middleware');
const docModel = require('./models/doc_model');
//Using middleWares:-
app.use(cors());
app.use(express.json());
app.use('',authRouter);
app.use('/doc',authMid,docRouter);//using the auth middleware too

//Getting port:-
const PORT = process.env.PORT || 3001;

const start = async function(){
    try {
      //Try connecting to the data base:-
      await connectDB(process.env.MONGO_URL);
      console.log("Database is connected!!");

      //socket io object is Listening to the connection made by any client:-
      io.on("connection", (socket) => {
        // console.log("The client is connected");
        socket.on("join", (documentId) => { //getting the id which is send from the client side to this join when emitting
          socket.join(documentId); //joining with this id only (the name can be anything above, but the value will be same ir the doc id passed in the client side while emitting 'join')
          // console.log(`Client has joined room with doc id ${documentId}!!`);
        },
        
        //for the typing one:- ie when the user is typing we will boradcast the data which is changing to each of the other client in a room 
        socket.on("typing",(data)=>{
          socket.broadcast.to(data.room).emit("changes",data); //this is how we broadcast the changes to the client in the room (ie the id of the doc, so that the changes are only broad casted to the clients accessing the room with that doc id only) which is given in the data.room, ie emitting changes event from this end having the data , now each client in the room given by data.room will receive this event and to grab this we will do _socketClient.on("changes") on front end too , to listen to the changes sent by the server 
        }),

        //Saving the document:-
        socket.on("save",async (data)=>{
             //Save the content of current document (from which the data is sent) in the database
             let document = await docModel.findByIdAndUpdate(data.room,{content:data.delta}); //the document id is delta.room so getting that and changing the content (which is defined as a list (the delta is a map , so in mongo both can be considered same))
             
             //Now we can display the save messages in the UI of each client if we want 
             //using the io.to() (to send some data to each clint (including the sender) or socket.to(sending to the sender only))
        })

        )});

      // app.listen(PORT,()=>{  //before socket connection use app for listening
      //    console.log(`Listening on ${PORT}`);

      //Since using the server for getting the socket setup , so now on we will be using server.listen sice have this server where we will be listening now
      server.listen(PORT,()=>{
        console.log(`Listening on ${PORT}`);
      });
    } catch (error) {
      console.log(error);
      //to kill the process now:-
      process.exit(1);
    }
 };
 
 //invoking the start method:-
 start();