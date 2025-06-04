const router = require("express").Router();
const notificationController = require("../controllers/notificationController");
router.post("/send", notificationController.sendNotification);

router.post(
  "/send-join-request",
  notificationController.sendJoinRequestNotification
);

module.exports = router;
