const authController = require("../controllers/authController");
const express = require("express");
const router = express.Router();
const authMiddleware = require("../middlewares/authMiddleware");

// Register route
router.post("/register", authController.register);

// Login route

router.post("/login", authController.login);

// Logout route
router.post("/logout", authMiddleware.verifyToken, authController.logout);

// Verify OTP route
router.post("/verify-otp", authController.verifyOTP);

// Resend OTP route
router.post("/resend-otp", authController.resendOTP);

module.exports = router;
