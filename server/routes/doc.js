const express = require('express');
const router = express.Router();
const {createDoc,getDocsOfUser,updateTitle,getDocById,deleteADoc} = require('../controllers/doc');

router.route('/create').post(createDoc);
router.route('/getUser').get(getDocsOfUser);
router.route('/update/title').post(updateTitle);
router.route('/:id').get(getDocById).delete(deleteADoc);

module.exports = router;