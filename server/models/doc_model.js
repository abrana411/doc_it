const mongoose = require("mongoose");

const documentSchema = new mongoose.Schema({
  //Id of the user whoi created the document
  uid: {
    required: true,
    type: String,
  },
  //time of the creation
  createdAt: {
    required: true,
    type: Number,
  },
  //Title of the document (initially it will be "Unititled docuemnt" when first created,  later the user can update it of course)
  title: {
    required: true,
    type: String,
    trim: true,
  },
  //content will be an array of all the stuff , text ,italic bold whatever , but initially it will be empty and not required
  content: {
    type: Array,
    default: [],
  },
});

module.exports =  mongoose.model("Document", documentSchema);//Creating a document model/collection using the above created document schema