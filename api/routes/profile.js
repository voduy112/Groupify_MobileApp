const profileController = require("../controllers/profileController.js");
const express = require("express");
const authMiddleware = require("../middlewares/authMiddleware.js");
const router = express.Router();

const { upload } = require("../config/Multer");

router.get("/:id", profileController.getProfileById);
router.patch("/:id", upload.single("image"), profileController.updateProfile);
router.get("/", profileController.getAllProflie);
router.delete("/:id", profileController.deleteProfile);
module.exports = router;
