const documentController = require("../controllers/documentController.js");
const express = require("express");
const router = express.Router();
const { upload, uploadImageAndFile } = require("../config/Multer.js");

router.get("/search", documentController.searchDocument);
router.get("/:id", documentController.getDocumentById);
router.get("/group/:id", documentController.getDocumentsByGroupId);
router.delete("/group/:id", documentController.deleteDocumentsByGroupId);
router.get("/user/:id", documentController.getDocumentsByUserId);
router.put("/:id", uploadImageAndFile, documentController.updateDocument);
router.post("/:id/rate", documentController.rateDocument);
router.get("/:id/rating", documentController.getDocumentRating);
router.post("/:id/comments", documentController.addComment);
router.get("/:id/comments", documentController.getComments);
router.get("/", documentController.getAllDocument);
router.delete("/:id", documentController.deleteDocument);
router.post("/", uploadImageAndFile, documentController.uploadDocument);
router.delete(
  "/comments/:documentId/:commentId",
  documentController.deleteComment
);

module.exports = router;
