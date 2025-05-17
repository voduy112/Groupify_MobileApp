const mongoose = require('mongoose');

const AnswerSchema = new mongoose.Schema({
  text: String,
  isCorrect: Boolean
});

const QuestionSchema = new mongoose.Schema({
  text: String,
  answers: [AnswerSchema]
});

const QuizSchema = new mongoose.Schema({
  title: String,
  description: String,
  groupId: {
          type: mongoose.Schema.Types.ObjectId,
          required: true,
          ref: 'Group'
      }, 
  questions: [QuestionSchema],
  createdAt: { type: Date, default: Date.now }
})

module.exports = mongoose.model('Quiz', QuizSchema);
