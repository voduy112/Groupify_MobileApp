const grouprequestController = require("../controllers/grouprequestController.js");
const express = require("express");
const router = express.Router();

router.get("/group/:groupId", grouprequestController.getAllRequestByGroupId);
router.post("/:id", grouprequestController.approveGroupRequest);
router.post("/", grouprequestController.createGroupRequest);
router.delete("/:id", grouprequestController.deleteRequest);

module.exports = router;
