const router = require("express").Router();
const notificationController = require("../controllers/notificationController");

router.post("/send", notificationController.sendNotification);

router.post(
  "/send-join-request",
  notificationController.sendJoinRequestNotification
);

router.post(
  "/send-accept-join",
  notificationController.sendAcceptJoinNotification
);

router.post(
  "/send-personal-chat",
  notificationController.sendPersonalChatNotification
);

router.post(
  "/send-group-document",
  notificationController.sendGroupDocumentNotification
);

module.exports = router;
