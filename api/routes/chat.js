const chatController = require('../controllers/chatController.js');
const express = require("express");
const router = express.Router();

router.post('/send', chatController.sendMessage);
router.get('/list/:userId', chatController.getChatList);
router.get('/:user1/:user2', chatController.getMessages);

module.exports = router;