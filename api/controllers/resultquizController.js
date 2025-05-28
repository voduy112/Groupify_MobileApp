const ResultQuiz = require('../models/ResultQuiz.js');

const resultquizController = {
    getAllResultQuiz : async(req, res) => {
        try {
            const quizes = await ResultQuiz.find();
            res.json(quizes); 
        }catch (error) {
            res.status(404).json({error: "Lỗi lấy bộ câu hỏi"});
        }
    },
    getResultByQuizIdAndUserId: async (req, res) => {
        try {
            const { quizId, userId } = req.params;
    
            if (!quizId || !userId) {
                return res.status(400).json({ error: "Thiếu quizId hoặc userId" });
            }
    
            const results = await ResultQuiz.find({ quizId, userId }).sort({ testAt: -1 });

            if (!results || results.length === 0) {
                return res.status(404).json({ message: "Không tìm thấy kết quả" });
            }
            return res.json(results);
        } catch (error) {
            console.error("Lỗi khi lấy kết quả:", error);
            res.status(500).json({ error: "Lỗi server khi lấy kết quả" });
        }
    }
    
}
module.exports = resultquizController;
