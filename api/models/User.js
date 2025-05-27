const mongoose = require("mongoose");

const userSchema = new mongoose.Schema(
  {
    username: {
      type: String,
      required: true,
    },
    email: {
      type: String,
      required: true,
      unique: true,
    },
    password: {
      type: String,
      required: true,
    },
    phoneNumber: {
      type: String,
      required: true,
    },
    profilePicture: {
      type: String,
      default:
        "https://res.cloudinary.com/dpl7e9iqw/image/upload/v1748223588/Groupify_MobileApp/avatar_profile/6833c607622862f8ddf2a830_avatar.png",
    },
    bio: {
      type: String,
      default: "I am a new user",
    },
    role: {
      type: String,
      enum: ["user", "admin"],
      default: "user",
    },
    refreshToken: {
      type: String,
      default: "",
    },
    isVerified: {
      type: Boolean,
      default: false,
    },
    otp: {
      type: String,
      default: "",
    },
    otpExpires: {
      type: Date,
    },
  },
  { timestamps: true }
);

module.exports = mongoose.model("User", userSchema);
