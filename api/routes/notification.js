const router = require("express").Router();
const notificationController = require("../controllers/notificationController");
router.post("/send", notificationController.sendNotification);

module.exports = router;
