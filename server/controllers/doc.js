const docModel = require("../models/doc_model");


//method to create a new document:-
const createDoc = async(req,res)=>{
  try {
    const {createdAt} = req.body;//not using the date when this controller function runs , because there can be sone delay in the server connection so better to get the time from the client side only
    let newDoc = new docModel({
        uid:req.user,
        createdAt,
        title: "Untitled document"
    });
    newDoc = await newDoc.save();
    res.json(newDoc);
  } catch (error) {
    res.status(500).json({errMsg:`Some error occured : ${error}`});
  }
};

//Getting the document of a user(belonging to a certain user)
const getDocsOfUser = async(req,res)=>{
    try {
      let userDocuments = await docModel.find({uid:req.user});//if the uid matches with teh current users id then this docuemtn is what we want
      res.json(userDocuments);//returning the list of user docs
    } catch (error) {
      res.status(500).json({errMsg:`Some error occured : ${error}`});
    }
  };

//Updating the title of the doc
const updateTitle = async(req,res)=>{
    try {
        const {id,title} = req.body;//getting the document id and the new title
        let updatedDoc = await docModel.findByIdAndUpdate(id,{title}); //find by id and update by title
        res.json(updatedDoc);
      } catch (error) {
        res.status(500).json({errMsg:`Some error occured : ${error}`});
      } 
}

//Get a document only:-
const getDocById = async(req,res)=>{
    try {
        const {id} = req.params;//as in the route it will be /doc/:id
        let doc = await docModel.findById(id);
        res.json(doc);
      } catch (error) {
        res.status(500).json({errMsg:`Some error occured : ${error}`});
      } 
}

module.exports = {createDoc,getDocsOfUser,updateTitle,getDocById};