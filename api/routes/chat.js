const chatController = require('../controllers/chatController.js');
const express = require("express");
const router = express.Router();

router.get('/search', chatController.searchChat);
router.post('/send', chatController.sendMessage);
router.get('/list/:userId', chatController.getChatList);
router.get('/:user1/:user2', chatController.getMessages);
router.delete('/:user1/:user2', chatController.deleteChat);

module.exports = router;