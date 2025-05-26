const User = require('../models/User');
const Group = require('../models/Group');
const Quiz = require('../models/Quiz');
const Document = require('../models/Document');
const Report = require('../models/Report');

module.exports = {
    // Quản lý người dùng
    getAllUsers: async (req, res) => {
        const users = await User.find();
        res.json(users);
    },
    createUser: async (req, res) => {
        const newUser = new User(req.body);
        await newUser.save();
        res.status(201).json(newUser);
    },
    updateUser: async (req, res) => {
        const user = await User.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json(user);
    },
    deleteUser: async (req, res) => {
        await User.findByIdAndDelete(req.params.id);
        res.json({ message: 'User deleted' });
    },

    // Quản lý nhóm học
    getAllGroups: async (req, res) => {
        const groups = await Group.find();
        res.json(groups);
    },
    createGroup: async (req, res) => {
        const newGroup = new Group(req.body);
        await newGroup.save();
        res.status(201).json(newGroup);
    },
    deleteGroup: async (req, res) => {
        await Group.findByIdAndDelete(req.params.id);
        res.json({ message: 'Group deleted' });
    },

    // Quản lý quiz
    getAllQuizzes: async (req, res) => {
        const quizzes = await Quiz.find();
        res.json(quizzes);
    },
    deleteQuiz: async (req, res) => {
        await Quiz.findByIdAndDelete(req.params.id);
        res.json({ message: 'Quiz deleted' });
    },

    // Quản lý báo cáo
    getAllReports: async (req, res) => {
        const reports = await Report.find();
        res.json(reports);
    },
    deleteReport: async (req, res) => {
        await Report.findByIdAndDelete(req.params.id);
        res.json({ message: 'Report deleted' });
    },

    // Quản lý tài liệu
    getAllDocuments: async (req, res) => {
        const docs = await Document.find();
        res.json(docs);
    },
    createDocument: async (req, res) => {
        const newDocument = new Document(req.body);
        await newDocument.save();
        res.status(201).json(newDocument);
    },
    deleteDocument: async (req, res) => {
        await Document.findByIdAndDelete(req.params.id);
        res.json({ message: 'Document deleted' });
    },
};
