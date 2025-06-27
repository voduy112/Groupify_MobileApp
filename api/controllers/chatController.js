const Message = require ("../models/Message");
const User = require ("../models/User");
const mongoose = require("mongoose");
const ObjectId = mongoose.Types.ObjectId;

const removeVietnameseTones = (str) => {
  return str
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/đ/g, "d")
    .replace(/Đ/g, "D");
};

const chatController = {
  searchChat: async (req, res) => {
    try {
      const { userId, query = "", page = 1, limit = 10 } = req.query;
  
      const userObjectId = new ObjectId(userId);
  
      const messages = await Message.find({
        $or: [
          { fromUserId: userObjectId },
          { toUserId: userObjectId }
        ]
      })
        .sort({ timestamp: -1 })
        .populate("fromUserId", "username profilePicture email phoneNumber")
        .populate("toUserId", "username profilePicture email phoneNumber");
  
      const usersMap = new Map();
  
      messages.forEach((msg) => {
        const from = msg.fromUserId;
        const to = msg.toUserId;
        if (!from || !to) return;
  
        const isSender = from._id.toString() === userId;
        const otherUser = isSender ? to : from;
  
        if (!usersMap.has(otherUser._id.toString())) {
          usersMap.set(otherUser._id.toString(), {
            _id: otherUser._id,
            username: otherUser.username,
            profilePicture: otherUser.profilePicture || "",
            lastMessage: msg.message,
            isSender: isSender
          });
        }
      });
  
      let allChats = Array.from(usersMap.values());
  
      const q = removeVietnameseTones(query).toLowerCase();
  
      if (q) {
        allChats = allChats.filter((user) => {
          const name = removeVietnameseTones(user.username || "").toLowerCase();
          return name.includes(q);
        });
      }
  
      const totalChats = allChats.length;
      const totalPages = Math.ceil(totalChats / limit);
      const paginatedChats = allChats.slice((page - 1) * limit, page * limit);
  
      res.json({
        totalChats,
        totalPages,
        currentPage: Number(page),
        chats: paginatedChats,
      });
    } catch (error) {
      console.error("Lỗi tìm kiếm chat:", error);
      res.status(500).json({ error: "Lỗi khi tìm kiếm danh sách trò chuyện" });
    }
  },
  
    sendMessage : async (req, res) => {
        try {
            const {fromUserId, toUserId, message} = req.body;
            if(!fromUserId || !toUserId || !message) {
                return res.status(400).json({error: "Thiếu thông tin tin nhắn"});
            };

            const newMessage = await Message.create({fromUserId, toUserId, message});
            return res.status(200).json(newMessage);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi gửi tin nhắn"});
        }
    },
    getMessages : async (req, res) => {
        try {
            const {user1, user2} = req.params;
            const messages = await Message.find({
                $or: [
                    { fromUserId: user1, toUserId: user2},
                    { fromUserId: user2, toUserId: user1}
                ]
            })
            .sort({timestamp: 1})
            .populate('fromUserId', 'username profilePicture email phoneNumber')
            .populate('toUserId', 'username profilePicture email phoneNumber');

            res.json(messages);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi lấy tin nhắn"});
        }
    },
    
    getChatList: async (req, res) => {
        try {
          const { userId } = req.params;
          const page = parseInt(req.query.page) || 1;
          const limit = parseInt(req.query.limit) || 10;
      
          const messages = await Message.find({
            $or: [{ fromUserId: userId }, { toUserId: userId }]
          })
            .sort({ timestamp: -1 }) // tin nhắn mới nhất trước
            .populate('fromUserId', 'username profilePicture email phoneNumber')
            .populate('toUserId', 'username profilePicture email phoneNumber');
      
          const usersMap = new Map();
      
          messages.forEach((msg) => {
            const from = msg.fromUserId;
            const to = msg.toUserId;
      
            if (!from || !to || !from._id || !to._id) return;
      
            const isSender = from._id.toString() === userId;
            const otherUser = isSender ? to : from;
      
            if (!usersMap.has(otherUser._id.toString())) {
              usersMap.set(otherUser._id.toString(), {
                _id: otherUser._id,
                username: otherUser.username,
                profilePicture: otherUser.profilePicture || '',
                lastMessage: msg.message,
                isSender: isSender
              });
            }
          });
      
          const allChats = Array.from(usersMap.values());
          const totalChats = allChats.length;
          const totalPages = Math.ceil(totalChats / limit);
      
          const paginatedChats = allChats.slice((page - 1) * limit, page * limit);
      
          res.json({
            totalChats,
            totalPages,
            currentPage: page,
            chats: paginatedChats,
          });
        } catch (error) {
          console.error("Lỗi getChatList:", error);
          res.status(500).json({
            error: error.message || "Lỗi khi lấy danh sách trò chuyện",
          });
        }
      },      

      deleteChat: async (req, res) => {
        const { user1, user2 } = req.params;
        try {
          const result = await Message.deleteMany({
            $or: [
              { fromUserId: user1, toUserId: user2 },
              { fromUserId: user2, toUserId: user1 }
            ]
          });
      
          res.status(200).json({
            message: "Đã xóa tất cả tin nhắn giữa hai người dùng",
            deletedCount: result.deletedCount
          });
        } catch (error) {
          res.status(500).json({ error: "Lỗi khi xóa tin nhắn" });
        }
      },      
}

module.exports = chatController;