const express = require('express');
const router = express.Router();
const {signInUser,getUserData} = require('../controllers/auth');
const authMid = require('../middlewares/auth_middleware');

router.route('/signin').post(signInUser);
router.get('/',authMid,getUserData);//using the auth middleware in this route

module.exports = router;