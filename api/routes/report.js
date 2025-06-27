const reportController = require('../controllers/reportController.js');
const express = require("express");
const router = express.Router();

router.post("/approve/:documentId", reportController.approveAndDeleteDocument);
router.get("/", reportController.getAllReports);
router.get("/:id", reportController.getReportById);
router.get("/document/:id", reportController.getReportsByDocumentId);
router.get('/document/:documentId/reporter/:reporterId', reportController.getReportByDocumentIdAndReporterId);
router.post("/", reportController.createReport);
router.put("/:id",reportController.updateReport);
router.delete("/:id", reportController.deleteReport);



 
module.exports = router;