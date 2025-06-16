const chatGroupController = require('../controllers/chatGroupController.js');
const express = require("express");
const router = express.Router();

router.post('/message/send/:groupId', chatGroupController.sendGroupMessage);
router.get('/message/:groupId', chatGroupController.getGroupMessages);
module.exports = router;