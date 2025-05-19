const quizController = require('../controllers/quizController.js');
const express = require("express");
const router = express.Router();
const {upload} = require ("../config/Multer");

router.get('/', quizController.getAllQuiz);
// router.get('/:id', quizController.getQuizById);
router.post('/', quizController.createQuiz);
//Update thông tin của bộ câu hỏi
router.patch('/:id', quizController.updateQuiz);
router.patch('/:id/question', quizController.updateQuestion);


router.delete('/:id', quizController.deleteQuiz);
 
module.exports = router;