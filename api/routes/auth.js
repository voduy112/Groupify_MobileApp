const authController = require("../controllers/authController");
const express = require("express");
const router = express.Router();

// Register route
router.post("/register", authController.register);

// Login route

router.post("/login", authController.login);

module.exports = router;