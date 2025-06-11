const Quiz = require('../models/Quiz');
const ResultQuiz = require('../models/ResultQuiz');

const quizController = {

    getQuizById : async(req, res) => {
        try {
            const quiz = await Quiz.findById(req.params.id);
            if (!quiz) {
            return res.status(404).json({ error: "Không tìm thấy quiz" });
            }
            res.json(quiz);
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi lấy thông tin quiz" });
        }
    },

    createQuiz : async(req, res) => {
        try {
            const { title, description, groupId, questions } = req.body;
            if (!title || !groupId || !questions || !Array.isArray(questions)) {
                return res.status(400).json({ message: 'Thiếu tiêu đề, groupId hoặc danh sách câu hỏi không hợp lệ.' });
            }
          
            const newQuiz = new Quiz({
                title,
                description,
                groupId,
                questions
            });
    
            const savedQuiz = await newQuiz.save();
          
            res.status(201).json({ message: 'Tạo quiz thành công.', quiz: savedQuiz });
        } catch (error) {
            console.error('Lỗi khi tạo quiz:', error);
            res.status(500).json({ message: 'Đã xảy ra lỗi khi tạo quiz.' });
        }
    },
    
    updateQuiz: async (req, res) => {
        try {
            const { id } = req.params;
            const { title, description, groupId } = req.body;

            const quiz = await Quiz.findById(id);
            if (!quiz) {
                return res.status(404).json({error: 'Không tìm thấy bộ câu hỏi'});
            }
            if(title !== undefined) quiz.title = title;
            if(description !== undefined) quiz.description = description;
            if(groupId) quiz.groupId = groupId;

            await quiz.save();
            return res.status(200).json({message: "Cập nhật thông tin thành công"});
        } catch (error) {
            console.error("Lỗi khi cập nhật thông tin quiz:", error);
            return res.status(500).json({ error: "Không thể cập nhật thông tin Quiz"});
        }
    },
    updateQuestion: async (req, res) => {
        try {
            const { id } = req.params;
            const { updates } = req.body;
    
            const quiz = await Quiz.findById(id);
            if (!quiz) {
                return res.status(404).json({ error: 'Không tìm thấy bộ câu hỏi' });
            }
    
            if (!Array.isArray(updates)) {
                return res.status(400).json({ error: 'Dữ liệu cập nhật không hợp lệ' });
            }
    
            updates.forEach(update => {
                const { action, questionIndex, newData } = update;
    
                if (action === 'update') {
                    if (
                        typeof questionIndex !== 'number' ||
                        questionIndex < 0 ||
                        questionIndex >= quiz.questions.length
                    ) {
                        console.warn('Cập nhật bị bỏ qua do chỉ số không hợp lệ:', questionIndex);
                        return;
                    }
    
                    const question = quiz.questions[questionIndex];
                    if (newData.text !== undefined) question.text = newData.text;
    
                    if (Array.isArray(newData.answers)) {
                        newData.answers.forEach(ansUpdate => {
                            const a = question.answers[ansUpdate.answerIndex];
                            if (!a) return;
                            if (ansUpdate.text !== undefined) a.text = ansUpdate.text;
                            if (ansUpdate.isCorrect !== undefined) a.isCorrect = ansUpdate.isCorrect;
                        });
                    }
                }
    
                else if (action === 'add') {
                    if (newData && newData.text && Array.isArray(newData.answers)) {
                        quiz.questions.push(newData);
                    }
                }
    
                else if (action === 'delete') {
                    if (
                        typeof questionIndex !== 'number' ||
                        questionIndex < 0 ||
                        questionIndex >= quiz.questions.length
                    ) {
                        console.warn('Xoá bị bỏ qua do chỉ số không hợp lệ:', questionIndex);
                        return;
                    }
                    quiz.questions.splice(questionIndex, 1);
                }
            });
    
            const saved = await quiz.save();
            return res.status(200).json({ message: 'Cập nhật câu hỏi thành công', quiz: saved });
    
        } catch (error) {
            console.error('Lỗi khi cập nhật câu hỏi:', error);
            return res.status(500).json({ error: 'Không thể cập nhật câu hỏi' });
        }
    },

    deleteQuiz : async (req, res) => {
        try {
            const quiz = await Quiz.findById(req.params.id);
            if(!quiz) return res.status(404).json({message: "Không tìm thấy bộ câu hỏi"});
            await Quiz.findByIdAndDelete(req.params.id);
            return res.json({ message: "Xóa thành công bộ câu hỏi"});
        } catch (error) {
            res.status(500).json({message: error.message});
        }
    },

    checkQuizResult: async (req, res) => {
        try {
            const { id: quizId } = req.params;
            const { userId, answers } = req.body;
    
            if (!userId || !Array.isArray(answers)) {
                return res.status(400).json({ error: 'Thiếu userId hoặc danh sách câu trả lời' });
            }
    
            const quiz = await Quiz.findById(quizId);
            if (!quiz) {
                return res.status(404).json({ error: 'Không tìm thấy quiz' });
            }
    
            let score = 0;
            const results = [];
    
            for (const userAnswer of answers) {
                const { questionIndex, answerIndex } = userAnswer;
    
                const question = quiz.questions[questionIndex];
                if (!question) {
                    results.push({ questionIndex, correct: false, reason: 'Câu hỏi không tồn tại' });
                    continue;
                }
    
                const selectedAnswer = question.answers[answerIndex];
                if (!selectedAnswer) {
                    results.push({ questionIndex, correct: false, reason: 'Đáp án không tồn tại' });
                    continue;
                }
    
                const isCorrect = selectedAnswer.isCorrect === true;
                if (isCorrect) score++;
                const correctAnswerIndex = question.answers.findIndex(ans => ans.isCorrect === true);
    
                results.push({
                    questionIndex,
                    selectedAnswerIndex: answerIndex,
                    correctAnswerIndex, 
                    correct: isCorrect
                });
            }
    
            const scoreText = `${score}/${quiz.questions.length}`;
    
            // Lưu kết quả vào MongoDB (không có times)
            const result = new ResultQuiz({
                userId,
                quizId,
                score: scoreText
            });
    
            await result.save();
    
            return res.status(200).json({
                message: 'Chấm điểm và lưu kết quả thành công',
                score,
                total: quiz.questions.length,
                scoreText,
                results
            });
    
        } catch (error) {
            console.error('Lỗi khi chấm điểm quiz:', error);
            return res.status(500).json({ error: 'Không thể chấm điểm quiz' });
        }
    },
    getQuizsByGroupId: async (req, res) => {
            const groupId = req.params.id || req.query.id;
                
                    if (!groupId) {
                        return res.status(400).json({ error: "Thiếu groupId" });
                    }
                
                    try {
                        const quizes = await Quiz.find({
                            $or: [
                                { groupId: groupId },
                                                    ]
                        });
                
                        return res.json(quizes);
                    } catch (error) {
                        console.error(error);
                        res.status(500).json({ error: "Lỗi khi lấy bộ câu hỏi theo groupId" });
                    }
        },
    
        deleteQuizzesByGroupId: async (req, res) => {
            const { groupId } = req.params;
        
            if (!groupId) {
                return res.status(400).json({ error: "Thiếu groupId" });
            }
        
            try {
                const result = await Quiz.deleteMany({ groupId });
        
                return res.status(200).json({
                    message: "Đã xoá tất cả quiz thuộc group thành công",
                    deletedCount: result.deletedCount
                });
            } catch (error) {
                console.error("Lỗi khi xoá quiz theo groupId:", error);
                return res.status(500).json({ error: "Không thể xoá quiz theo groupId" });
            }
        },
        
    
    
}

module.exports = quizController;