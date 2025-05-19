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
    }
    
})

module.exports = mongoose.model('ResultQuiz', resultQuizSchema);