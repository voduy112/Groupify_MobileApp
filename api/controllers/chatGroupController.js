const GroupMessage = require("../models/GroupMessage");
const Group = require("../models/Group");

const chatGroupController = {
    sendGroupMessage : async (req, res) => {
        try {
            const {groupId} = req.params;
            const {fromUserId, message} = req.body;

            if(!fromUserId || !message) {
                return res.status(400).json({error: "Thiếu thông tin"});
            }
            const group = await Group.findOne({_id:groupId, membersID:fromUserId});

            if(!group) {
                return res.status(403).json({error: "Không có quyền gửi tin nhắn vào nhóm"});
            }

            const newMsg = await GroupMessage.create({groupId, fromUserId, message});
            const populatedMsg = await newMsg.populate("fromUserId", "username");
            return res.status(200).json(populatedMsg);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi gửi tin nhắn nhóm"});
        }
    },
    getGroupMessages: async (req, res) => {
        try {
            const { groupId } = req.params;

            const messages = await GroupMessage.find({ groupId })
                .sort({ timestamp: 1 })
                .populate("fromUserId", "username");

            return res.status(200).json(messages);
        } catch (error) {
            console.error("Lỗi khi lấy lịch sử nhóm:", error);
            return res.status(500).json({ error: "Lỗi server khi lấy tin nhắn nhóm" });
        }
    }
};

module.exports = chatGroupController;