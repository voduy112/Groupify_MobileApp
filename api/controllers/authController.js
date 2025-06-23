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
        return res.status(404).json({ message: "Không tìm thấy tài khoản" });
      }

      const isMatch = await bcrypt.compare(req.body.password, user.password);
      if (!isMatch) {
        return res.status(400).json({ message: "Mật khẩu không đúng" });
      }

      // Nếu khớp thông tin:
      const accessToken = authController.generateAccessToken(user);
      const refreshToken = authController.generateRefreshToken(user);

      // Lưu refresh token vào DB
      await User.findByIdAndUpdate(user._id, { refreshToken });

      // Xóa password trước khi trả về cho client
      const { password, ...others } = user._doc;

      if (!user.isVerified) {
        return res.status(403).json({ message: "Vui lòng xác thực email" });
      }

      // Trả cả 2 token về phía client
      return res.status(200).json({
        ...others,
        accessToken,
        refreshToken,
      });
    } catch (error) {
      res.status(500).json({
        message: "Lỗi đăng nhập",
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
      await User.findByIdAndUpdate(userId, { fcmToken: null });

      res.status(200).json({ message: "Logout successful" });
    } catch (error) {
      res.status(500).json({ message: "Error during logout", error });
    }
  },
  checkEmail: async (req, res) => {
    try {
      const { email } = req.body;
      const user = await User.findOne({ email });
      if (user) {
        return res.status(200).json({ message: "Email đã tồn tại" });
      }
      return res.status(200).json({ message: "Email chưa tồn tại" });
    } catch (error) {
      res.status(500).json({ message: "Error checking email", error });
    }
  },
  refreshToken: async (req, res) => {
    try {
      const { refreshToken } = req.body;
      if (!refreshToken) {
        return res.status(400).json({ message: "Refresh token required" });
      }
      console.log("refreshToken: ", refreshToken);

      const decoded = jwt.verify(
        refreshToken,
        process.env.REFRESH_TOKEN_SECRET
      );
      const user = await User.findById(decoded.id);
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }

      // So sánh với refresh token đã lưu (nếu có)
      console.log("storedRefreshToken: ", user.refreshToken);
      console.log("refreshToken: ", refreshToken);
      if (user.refreshToken !== refreshToken) {
        return res.status(403).json({ message: "Invalid refresh token" });
      }

      const accessToken = authController.generateAccessToken(user);
      res.status(200).json({ accessToken });
    } catch (error) {
      if (
        error.name === "TokenExpiredError" ||
        error.name === "JsonWebTokenError"
      ) {
        return res
          .status(401)
          .json({ message: "Invalid or expired refresh token" });
      }
      res.status(500).json({ message: "Error refreshing token" });
    }
  },
  sendOTPEmail: async (req, res) => {
    try {
      const { email } = req.body;

      if (!email) {
        return res.status(400).json({ message: "Email is required" });
      }

      const user = await User.findOne({ email });

      if (!user) {
        return res.status(404).json({ message: "Người dùng không tồn tại" });
      }

      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      const otpExpires = Date.now() + 5 * 60 * 1000; // OTP hết hạn sau 5 phút

      // Gửi email OTP
      const transporter = nodemailer.createTransport({
        service: "gmail",
        auth: {
          user: process.env.EMAIL_USER,
          pass: process.env.EMAIL_PASS,
        },
      });

      const mailOptions = {
        from: `"Groupify App" <${process.env.EMAIL_USER}>`,
        to: email,
        subject: "Mã OTP đặt lại mật khẩu",
        text: `Mã OTP của bạn là: ${otp}. Mã có hiệu lực trong 5 phút.`,
      };

      await transporter.sendMail(mailOptions);

      // Cập nhật OTP và thời gian hết hạn vào user
      user.otp = otp;
      user.otpExpires = otpExpires;
      await user.save();

      res.status(200).json({ message: "OTP đã được gửi tới email của bạn" });
    } catch (error) {
      console.error("Lỗi gửi OTP:", error);
      res.status(500).json({ message: "Lỗi gửi OTP", error });
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
      const { email, oldPassword, newPassword } = req.body;
      if (!email || !oldPassword || !newPassword) {
        return res.status(400).json({ message: "All fields are required" });
      }
      const user = await User.findOne({ email });
      if (!user) {
        return res.status(404).json({ message: "User not found" });
      }
      const isMatch = await bcrypt.compare(oldPassword, user.password);
      if (!isMatch) {
        return res.status(400).json({ message: "Mật khẩu cũ không đúng" });
      }
      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(newPassword, salt);
      user.password = hashedPassword;
      await user.save();
      res.status(200).json({ message: "Mật khẩu đã được thay đổi thành công" });
    } catch (error) {
      res.status(500).json({ message: "Lỗi khi thay đổi mật khẩu", error });
    }
  },
  updateFcmToken: async (req, res) => {
    try {
      const { userId, fcmToken } = req.body;
      if (!userId || !fcmToken) {
        return res.status(400).json({ message: "All fields are required" });
      }
      await User.findByIdAndUpdate(userId, { fcmToken });
      res.status(200).json({ message: "FCM token updated successfully" });
    } catch (error) {
      res.status(500).json({ message: "Error updating FCM token", error });
    }
  },
  resetPassword: async (req, res) => {
    try {
      const { email, newPassword } = req.body;

      if (!email || !newPassword) {
        return res.status(400).json({ message: "Thiếu thông tin cần thiết" });
      }

      const user = await User.findOne({ email });

      if (!user) {
        return res.status(404).json({ message: "Người dùng không tồn tại" });
      }

      const salt = await bcrypt.genSalt(10);
      const hashedPassword = await bcrypt.hash(newPassword, salt);

      user.password = hashedPassword;
      await user.save();

      return res.status(200).json({ message: "Đặt lại mật khẩu thành công" });
    } catch (error) {
      res.status(500).json({ message: "Lỗi đặt lại mật khẩu", error });
    }
  },
};

module.exports = authController;
