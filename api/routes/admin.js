const express = require('express');
const router = express.Router();
const isAdmin = require('../middlewares/isAdmin');
const adminController = require('../controllers/adminController');

router.use(isAdmin);

// ----- User -----
router.get('/users', adminController.getAllUsers);
router.post('/users', adminController.createUser);       
router.put('/users/:id', adminController.updateUser);
router.delete('/users/:id', adminController.deleteUser);
router.get('/users/count', adminController.getUserCount);

// ----- Group -----
router.get('/groups', adminController.getAllGroups);
router.post('/groups', adminController.createGroup);   
router.put('/groups/:id', adminController.updateGroup);
router.delete('/groups/:id', adminController.deleteGroup);
router.get('/groups/count', adminController.getGroupCount);

// ----- Document -----
router.get('/documents', adminController.getAllDocuments);
router.post('/documents', adminController.createDocument); 
router.delete('/documents/:id', adminController.deleteDocument);
router.get('/documents/count', adminController.getDocumentCount);

// ----- Report -----
router.get('/reports', adminController.getAllReports);           
router.delete('/reports/:id', adminController.deleteReport);      
router.get('/reports/count', adminController.getReportCount);
router.get('/reported-documents', adminController.getReportedDocuments); 

// ----- Thống kê -----
router.get('/updates/today', adminController.getUpdateCountToday);
router.get('/statistics', adminController.getWeeklyStatistics);

module.exports = router;
