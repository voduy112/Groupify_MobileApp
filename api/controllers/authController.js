const User = require("../models/User");
const bcrypt = require("bcrypt");
const jwt = require("jsonwebtoken");
const nodemailer = require("nodemailer");

const authController = {
  register: async (req, res) => {
    try {
      const { username, email, password, phoneNumber } = req.body;

      if (!username || !email || !password || !phoneNumber) {
        return res.status(400).json({ message: "All fields are required" });
      }
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(password, salt);

      // Sinh OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const otpExpires = Date.now() + 5 * 60 * 1000; // 5 phút

      // Tạo user mới với OTP
      const newUser = new User({
        username,
        email,
        password: hashedPassword,
        phoneNumber,
        otp,
        otpExpires,
      });
      await newUser.save();

      // Gửi OTP qua email
      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: "Mã OTP cho đăng ký tài khoản",
        text: `Mã OTP của bạn là: ${otp}`,
      };
      await transporter.sendMail(mailOptions);

      return res.status(200).json({
        message: "Đăng ký thành công, vui lòng kiểm tra email để xác thực OTP.",
      });
    } catch (error) {
      res.status(500).json({ message: "Error registering user", error });
    }
  },
  // GENERATE ACCESS TOKEN
  generateAccessToken: (user) => {
    return jwt.sign(
      {
        id: user._id,
        role: user.role,
      },
      process.env.ACCESS_TOKEN_SECRET,
      { expiresIn: "15m" }
    );
  },
  // GENERATE REFRESH TOKEN
  generateRefreshToken: (user) => {
    return jwt.sign(
      {
        id: user._id,
        role: user.role,
      },
      process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: "30d" }
    );
  },
  login: async (req, res) => {
    try {
      const user = await User.findOne({ email: req.body.email });
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      const isMatch = await bcrypt.compare(req.body.password, user.password);
      if (!isMatch) {
        return res.status(400).json({ message: "Invalid credentials" });
      }

      // Nếu khớp thông tin:
      const accessToken = authController.generateAccessToken(user);
      const refreshToken = authController.generateRefreshToken(user);

      // Lưu refresh token vào DB
      await User.findByIdAndUpdate(user._id, { refreshToken });

      // Xóa password trước khi trả về cho client
      const { password, ...others } = user._doc;

      if (!user.isVerified) {
        return res.status(403).json({ message: "Please verify your email" });
      }

      // Trả cả 2 token về phía client
      return res.status(200).json({
        ...others,
        accessToken,
        refreshToken,
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({
        message: "Error logging in user",
        error: error.message,
      });
    }
  },
  logout: async (req, res) => {
    try {
      const userId = req.user.id;
      if (!userId) {
        return res.status(400).json({ message: "User ID is required" });
      }

      // Xoá refreshToken khỏi database
      await User.findByIdAndUpdate(userId, { refreshToken: null });

      res.status(200).json({ message: "Logout successful" });
    } catch (error) {
      res.status(500).json({ message: "Error during logout", error });
    }
  },
  sendOTPEmail: async (req, res) => {
    try {
      const { email } = req.body;
      if (!email) {
        return res.status(400).json({ message: "Email is required" });
      }
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: "Mã OTP cho đăng ký tài khoản",
        text: `Mã OTP của bạn là: ${otp}`,
      };
      await transporter.sendMail(mailOptions);
      res.status(200).json({ message: "OTP sent successfully" });
    } catch (error) {
      res.status(500).json({ message: "Error sending OTP", error });
    }
  },
  verifyOTP: async (req, res) => {
    try {
      const { email, otp } = req.body;

      const user = await User.findOne({ email });
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      if (user.otp !== otp) {
        return res.status(400).json({ message: "Invalid OTP" });
      }

      if (user.otpExpires < Date.now()) {
        return res.status(400).json({ message: "OTP has expired" });
      }

      // Đánh dấu đã xác thực
      user.otp = null;
      user.otpExpires = null;
      user.isVerified = true; // đảm bảo model có trường này
      await user.save();

      return res.status(200).json({ message: "OTP verified successfully" });
    } catch (error) {
      res.status(500).json({ message: "Error verifying OTP", error });
    }
  },
  resendOTP: async (req, res) => {
    try {
      const { email } = req.body;
      if (!email) {
        return res.status(400).json({ message: "Email is required" });
      }

      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });
      const mailOptions = {
        from: process.env.EMAIL_USER,
        to: email,
        subject: "Mã OTP cho đăng ký tài khoản",
        text: `Mã OTP của bạn là: ${otp}`,
      };
      await transporter.sendMail(mailOptions);
      await User.findOneAndUpdate(
        { email },
        { otp, otpExpires: Date.now() + 5 * 60 * 1000 } // 5 phút
      );
      res.status(200).json({ message: "OTP sent successfully" });
    } catch (error) {
      res.status(500).json({ message: "Error sending OTP", error });
    }
  },
  changePassword: async (req, res) => {
    try {
      const { email, newPassword } = req.body;
      if (!email || !newPassword) {
        return res.status(400).json({ message: "All fields are required" });
      }
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(newPassword, salt);
      user.password = hashedPassword;
      await user.save();
      res.status(200).json({ message: "Password changed successfully" });
    } catch (error) {
      res.status(500).json({ message: "Error changing password", error });
    }
  },
};

module.exports = authController;
