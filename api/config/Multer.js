const multer = require("multer");
const cloudinary = require("../config/Cloudinary");
const { CloudinaryStorage } = require("multer-storage-cloudinary");

const storage = new CloudinaryStorage({
  cloudinary,
  params: async (req, file) => {
    const isPdf = file.mimetype === 'application/pdf';

    return {
      // ...(isPdf && { folder: "Groupify_MobileApp/file_document" }),
      allowed_formats: ["jpg", "png", "pdf"],
      resource_type: isPdf ? "raw" : "image", // PDF phải dùng resource_type: "raw"
      transformation: isPdf
        ? undefined
        : [{ width: 500, height: 500, crop: "limit" }],
    };
  },
});

const upload = multer({ storage });

module.exports = {
  upload,
  uploadImageAndFile: upload.fields([
    { name: "image", maxCount: 1 },
    { name: "mainFile", maxCount: 1 },
  ]),
};