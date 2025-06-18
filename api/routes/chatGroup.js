const chatGroupController = require('../controllers/chatGroupController.js');
const express = require("express");
const router = express.Router();
const authMiddleware = require('../middlewares/authMiddleware.js');

router.post('/message/send/:groupId', chatGroupController.sendGroupMessage);
router.get('/message/:groupId', chatGroupController.getGroupMessages);

router.post(
    '/message/send-image/:groupId',
    chatGroupController.upload.single('image'),
    chatGroupController.sendGroupImage
  );
  
module.exports = router;