const resultquizController = require('../controllers/resultquizController.js');
const express = require("express");
const router = express.Router();
const {upload} = require ("../config/Multer");


router.get('/', resultquizController.getAllResultQuiz);
router.get('/quiz/:quizId/user/:userId', resultquizController.getResultByQuizIdAndUserId);


 
module.exports = router;