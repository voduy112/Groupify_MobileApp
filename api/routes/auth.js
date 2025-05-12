const authController = require("../controllers/authController");
const express = require("express");
const router = express.Router();

// Register route
router.post("/register", authController.register);

module.exports = router;