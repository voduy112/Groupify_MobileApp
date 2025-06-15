const User = require('../models/User');
const Group = require('../models/Group');
const Document = require('../models/Document');
const Report = require('../models/Report');
const dayjs = require('dayjs');

module.exports = {
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
    const { id } = req.params;
    const { username, email, phoneNumber, bio } = req.body;
  
    if (!username || !email) {
      return res.status(400).json({ error: "Username and email are required" });
    }
  
    try {
      const user = await User.findById(id);
      if (!user) return res.status(404).json({ error: "User not found" });
  
      user.username = username;
      user.email = email;
      user.phoneNumber = phoneNumber || '';
      user.bio = bio || '';
  
      await user.save();
  
      res.json({ message: "User updated successfully", user });
    } catch (error) {
      console.error("Update error:", error);
      res.status(500).json({ error: "Internal server error" });
    }
  },
  
  deleteUser: async (req, res) => {
    await User.findByIdAndDelete(req.params.id);
    res.json({ message: 'User deleted' });
  },

  getUserCount: async (req, res) => {
    try {
      const count = await User.countDocuments();
      res.json({ count });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi đếm người dùng' });
    }
  },

  getAllGroups: async (req, res) => {
    try {
      const groups = await Group.find().populate("ownerId", "username");
      res.json(groups);
    } catch (err) {
      console.error("Lỗi khi lấy nhóm:", err);
      res.status(500).json({ error: "Lỗi server" });
    }
  },

  createGroup: async (req, res) => {
    const newGroup = new Group(req.body);
    await newGroup.save();
    res.status(201).json(newGroup);
  },

  updateGroup: async (req, res) => {
    try {
      const { id } = req.params;
      const { name, description } = req.body;

      const updated = await Group.findByIdAndUpdate(id, { name, description }, { new: true });
      if (!updated) {
        return res.status(404).json({ message: 'Group not found' });
      }

      res.json(updated);
    } catch (err) {
      console.error(err);
      res.status(500).json({ message: 'Update failed' });
    }
  },

  deleteGroup: async (req, res) => {
    await Group.findByIdAndDelete(req.params.id);
    res.json({ message: 'Group deleted' });
  },

  getGroupCount: async (req, res) => {
    try {
      const count = await Group.countDocuments();
      res.json({ count });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi đếm nhóm học' });
    }
  },

  getAllReports: async (req, res) => {
    const reports = await Report.find();
    res.json(reports);
  },

  deleteReport: async (req, res) => {
    await Report.findByIdAndDelete(req.params.id);
    res.json({ message: 'Report deleted' });
  },

  getReportCount: async (req, res) => {
    try {
      const count = await Report.countDocuments();
      res.json({ count });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi đếm báo cáo' });
    }
  },

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

  getDocumentCount: async (req, res) => {
    try {
      const count = await Document.countDocuments();
      res.json({ count });
    } catch (error) {
      res.status(500).json({ message: 'Lỗi khi đếm tài liệu' });
    }
  },

  getUpdateCountToday: async (req, res) => {
    try {
      const startOfToday = new Date();
      startOfToday.setHours(0, 0, 0, 0);

      const endOfToday = new Date();
      endOfToday.setHours(23, 59, 59, 999);

      const [userUpdates, groupUpdates, documentUpdates, reportUpdates] = await Promise.all([
        User.countDocuments({
          $or: [
            { createdAt: { $gte: startOfToday, $lte: endOfToday } },
            { updatedAt: { $gte: startOfToday, $lte: endOfToday } }
          ]
        }),
        Group.countDocuments({
          $or: [
            { createdAt: { $gte: startOfToday, $lte: endOfToday } },
            { updatedAt: { $gte: startOfToday, $lte: endOfToday } }
          ]
        }),
        Document.countDocuments({
          $or: [
            { createdAt: { $gte: startOfToday, $lte: endOfToday } },
            { updatedAt: { $gte: startOfToday, $lte: endOfToday } }
          ]
        }),
        Report.countDocuments({
          $or: [
            { createdAt: { $gte: startOfToday, $lte: endOfToday } },
            { updatedAt: { $gte: startOfToday, $lte: endOfToday } }
          ]
        })
      ]);

      const count = userUpdates + groupUpdates + documentUpdates + reportUpdates;

      return res.json({ count });
    } catch (error) {
      console.error('Lỗi getUpdateCountToday:', error);
      return res.status(500).json({ message: 'Lỗi khi đếm cập nhật hôm nay' });
    }
  },
  getWeeklyStatistics: async (req, res) => {
    const period = req.query.period;
  
    if (period !== 'weekly') {
      return res.status(400).json({ message: 'Chỉ hỗ trợ thống kê theo tuần' });
    }
  
    try {
      const numberOfWeeks = 8;
      const labels = Array.from({ length: numberOfWeeks }, (_, i) => `Tuần ${i + 1}`);
  
      const documents = [];
      const users = [];
      const groups = [];
  
      const baseDate = dayjs('2025-05-12'); 
  
      for (let i = 0; i < numberOfWeeks; i++) {
        const start = baseDate.add(i, 'week').startOf('day').toDate();
        const end = baseDate.add(i + 1, 'week').startOf('day').toDate();
  
        const docCount = await Document.countDocuments({ createdAt: { $gte: start, $lt: end } });
        const userCount = await User.countDocuments({ createdAt: { $gte: start, $lt: end } });
        const groupCount = await Group.countDocuments({ createdAt: { $gte: start, $lt: end } });
  
        documents.push(docCount);
        users.push(userCount);
        groups.push(groupCount);
      }
  
      res.json({
        labels,
        datasets: { documents, users, groups }
      });
    } catch (err) {
      console.error('Lỗi khi thống kê:', err);
      res.status(500).json({ message: 'Lỗi server khi thống kê theo tuần' });
    }
  },  

  getReportedDocuments: async (req, res) => {
    try {
      const reportedDocs = await Document.find({ reportCount: { $gt: 0 } })
        .sort({ reportCount: -1 })
        .populate('uploaderId', 'name email')
        .populate('groupId', 'name');

      res.json(reportedDocs);
    } catch (error) {
      console.error("Lỗi khi lấy tài liệu bị báo cáo:", error);
      res.status(500).json({ message: "Lỗi server" });
    }
  }
};
