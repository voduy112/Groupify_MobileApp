const express = require('express');
const router = express.Router();
const isAdmin = require('../middlewares/isAdmin');
const adminController = require('../controllers/adminController');

// Middleware kiểm tra admin
router.use(isAdmin);

// Quản lý người dùng
router.get('/users', adminController.getAllUsers);
router.post('/users', adminController.createUser);       
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);

// Quản lý nhóm học
router.get('/groups', adminController.getAllGroups);
router.post('/groups', adminController.createGroup);   
router.delete('/groups/:id', adminController.deleteGroup);

// Quản lý quiz
router.get('/quizzes', adminController.getAllQuizzes);  
router.delete('/quizzes/:id', adminController.deleteQuiz);

// Quản lý báo cáo
router.get('/reports', adminController.getAllReports); 
router.delete('/reports/:id', adminController.deleteReport);

// Quản lý tài liệu
router.get('/documents', adminController.getAllDocuments);
router.post('/documents', adminController.createDocument); 
router.delete('/documents/:id', adminController.deleteDocument);

module.exports = router;
