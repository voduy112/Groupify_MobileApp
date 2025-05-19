const express = require('express');
const router = express.Router();

const userController = require('../controllers/userController');
const groupController = require('../controllers/groupController');
const quizController = require('../controllers/quizController');
const reportController = require('../controllers/reportController'); 
const documentController = require('../controllers/documentController');

// Route quản lý người dùng
router.get('/users', userController.getAllUsers);
router.post('/users', userController.createUser);

// Route quản lý nhóm học
router.get('/groups', groupController.getAllGroups);

// Route quản lý quiz
router.get('/quiz', quizController.getAllQuizzes);

// Route quản lý báo cáo (nếu có)
router.get('/reports', reportController.getReports); 

// Quản lý tài liệu chia sẻ
router.get('/documents', documentController.getAllDocuments);
router.delete('/documents/:id', documentController.deleteDocument);
router.put('/documents/:id/status', documentController.updateDocumentStatus);

module.exports = router;
