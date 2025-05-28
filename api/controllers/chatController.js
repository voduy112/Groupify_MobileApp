const Message = require ("../models/Message");
const User = require ("../models/User");

const chatController = {
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
    getChatList : async (req, res) => {
        try {
          const { userId } = req.params;
      
          const messages = await Message.find({
            $or: [
              { fromUserId: userId },
              { toUserId: userId }
            ]
          })
          .populate('fromUserId', 'username profilePicture email phoneNumber')
          .populate('toUserId', 'username profilePicture email phoneNumber');
      
          const usersMap = new Map();
      
          messages.forEach(msg => {
            const from = msg.fromUserId;
            const to = msg.toUserId;
      
            if (!from || !to || !from._id || !to._id) return;
      
            const isSender = from._id.toString() === userId;
            const otherUser = isSender ? to : from;
      
            // Thêm cả người gửi lẫn người nhận nếu khác userId
            if (otherUser && otherUser._id.toString() !== userId) {
              usersMap.set(otherUser._id.toString(), {
                _id: otherUser._id,
                username: otherUser.username,
                profilePicture: otherUser.profilePicture || ''
              });
            }
          });
      
          res.json(Array.from(usersMap.values()));
        } catch (error) {
          console.error("Lỗi getChatList:", error);
          res.status(500).json({ error: error.message || "Lỗi khi lấy danh sách trò chuyện" });
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