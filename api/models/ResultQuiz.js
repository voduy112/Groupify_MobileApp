const mongoose = require('mongoose');

const resultQuizSchema = new mongoose.Schema({
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    quizId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: "Quiz",
        required: true,
    },
    score: {
        type: String,
        required: true,
    },
    testAt: { 
        type: Date, 
        default: Date.now 
    }
    
})

const ResultQuiz = mongoose.models.ResultQuiz || mongoose.model('ResultQuiz', resultQuizSchema);

module.exports = ResultQuiz;