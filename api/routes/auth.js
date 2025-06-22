const authController = require("../controllers/authController");
const express = require("express");
const router = express.Router();
const authMiddleware = require("../middlewares/authMiddleware");

// Register route
router.post("/register", authController.register);

// Check email route
router.post("/check-email", authController.checkEmail);

// Login route
router.post("/login", authController.login);

// Logout route
router.post("/logout", authMiddleware.verifyToken, authController.logout);

// Refresh token route
router.post("/refresh-token", authController.refreshToken);

// Change password route
router.post("/change-password", authController.changePassword);

// Verify OTP route
router.post("/verify-otp", authController.verifyOTP);

// Resend OTP route
router.post("/resend-otp", authController.resendOTP);

// Update FCM token route
router.post("/update-fcm-token", authController.updateFcmToken);

module.exports = router;
