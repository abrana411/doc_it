const express = require('express');
const router = express.Router();
const {createDoc,getDocsOfUser,updateTitle,getDocById} = require('../controllers/doc');

router.route('/create').post(createDoc);
router.route('/getUser').get(getDocsOfUser);
router.route('/update/title').post(updateTitle);
router.route('/:id').get(getDocById);

module.exports = router;