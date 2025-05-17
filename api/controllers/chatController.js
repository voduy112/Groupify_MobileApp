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
            .populate('fromUserId', 'username')
            .populate('toUserId', 'username');

            res.json(messages);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi lấy tin nhắn"});
        }
    },
    getChatList : async (req, res) => {
        try {
            const {userId} = req.params;
            const messages = await Message.find({
                $or: [
                    {fromUserId: userId},
                    {toUserId: userId}
                ]
            }).populate('fromUserId', 'username')
              .populate('toUserId', 'username');    

            const usersMap = new Map (); //dung map tranh lay trung tin nhan

            messages.forEach(msg => {
                const otherUser = msg.fromUserId._id.toString() === userId
                    ? msg.toUserId
                    : msg.fromUserId;

                usersMap.set(otherUser._id.toString(), {
                    _id: otherUser._id,
                    username: otherUser.username
                });
            });
            res.json(Array.from(usersMap.values()));
        } catch (error) {
            res.status(500).json({error: "Lỗi khi lấy danh sách trò chuyện"});
        }
    }
}

module.exports = chatController;