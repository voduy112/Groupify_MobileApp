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

router.get("/user/:userId", notificationController.getAllNotification);

router.post("/read/:notiId", notificationController.readNotification);

router.get("/muted-groups/:userId", notificationController.getMutedGroups);
router.post("/mute-group", notificationController.muteGroup);
router.post("/unmute-group", notificationController.unmuteGroup);

module.exports = router;
