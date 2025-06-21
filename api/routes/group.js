const groupController = require("../controllers/groupController.js");
const express = require("express");
const router = express.Router();

const { upload, uploadImageAndFile } = require("../config/Multer.js");
const authMiddleware = require("../middlewares/authMiddleware.js");

router.get("/search", groupController.searchGroup);
router.get("/:id", groupController.getGroupById);
router.get("/", groupController.getAllGroup);
router.delete("/:id", groupController.deleteGroup);
router.post("/", uploadImageAndFile, groupController.createGroup);
router.post("/join", groupController.joinGroupByCode);
router.get(
  "/user/:id",
  authMiddleware.verifyToken,
  groupController.getAllGroupByUserId
);

router.put("/:id", upload.single("image"), groupController.updateGroup);
router.post("/leave", groupController.leaveGroup);
router.post("/remove-member", groupController.removeMember);
router.get("/members/:id", groupController.getGroupMembers);
router.get("/user/:id", groupController.getAllGroupByUserId);
router.post("/adduser", groupController.addUserIntoGroup);
router.post("/change-owner", groupController.changeOwnerId);

module.exports = router;
