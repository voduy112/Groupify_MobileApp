const multer = require("multer");
const cloudinary = require("../config/Cloudinary");
const { CloudinaryStorage } = require("multer-storage-cloudinary");

const storage = new CloudinaryStorage({
  cloudinary,
  params: {
    // folder: "Groupify_MobileApp/avatar_profile",
    allowed_formats: ["jpg", "png"],
    transformation: [{ width: 500, height: 500, crop: "limit" }],
  },
});
const upload = multer({ storage });

module.exports = upload;