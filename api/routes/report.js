const express = require("express");
const router = express.Router();
const documentController = require("../controllers/documentController");

// Lấy tất cả tài liệu bị report 
router.get("/reports", documentController.getReportedDocuments);

// Lấy chi tiết các báo cáo của một tài liệu
router.get("/document/:id", documentController.getReportsByDocumentId);

// Báo cáo tài liệu
router.post("/:id/report", documentController.reportDocument);

// Xoá tất cả báo cáo của một tài liệu
router.delete("/:id/reports", documentController.clearDocumentReports);

module.exports = router;
