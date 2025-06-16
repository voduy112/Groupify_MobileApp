const ResultQuiz = require('../models/resultQuiz.js');

const resultquizController = {
    getAllResultQuiz : async(req, res) => {
        try {
            const quizes = await ResultQuiz.find();
            res.json(quizes); 
        }catch (error) {
            res.status(404).json({error: "Lỗi lấy bộ câu hỏi"});
        }
    },
    
}
module.exports = resultquizController;
