const GroupMessage = require("../models/GroupMessage");
const Group = require("../models/Group");
const cloudinary = require("../config/Cloudinary");

const multer = require('multer');
const storage = multer.memoryStorage();
const upload = multer({ storage });

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
    },

    //Ham gui anh khi chat nhom
    /*sendGroupImage: async (req, res) => {
        try {
          const { groupId } = req.params;
          const { fromUserId } = req.body;
  
          if (!fromUserId) {
            return res.status(400).json({ error: "Thiếu thông tin người gửi" });
          }
          const group = await Group.findOne({ _id: groupId, membersID: fromUserId });
          if (!group) {
            return res.status(403).json({ error: "Không có quyền gửi ảnh trong nhóm" });
          }
          if (!req.file) {
            return res.status(400).json({ error: "Không có file ảnh được gửi" });
          }
  
          // Upload ảnh lên Cloudinary
          const uploadFromBuffer = (buffer) => {
            return new Promise((resolve, reject) => {
              const stream = cloudinary.uploader.upload_stream(
                { folder: `/Groupify_MobileApp/group_messages/${groupId}` },
                (error, result) => {
                  if (error) reject(error);
                  else resolve(result);
                }
              );
              stream.end(buffer);
            });
          };
  
          const result = await uploadFromBuffer(req.file.buffer);
  
          const newMsg = await GroupMessage.create({
            groupId,
            fromUserId,
            message: '',
            imageUrl: result.secure_url,
          });
  
          const populatedMsg = await newMsg.populate("fromUserId", "username");
          return res.status(200).json(populatedMsg);
  
        } catch (error) {
          console.error(error);
          res.status(500).json({ error: "Lỗi server khi gửi ảnh nhóm" });
        }
      }*/

    sendGroupImage: async (req, res) => {
    try {
      const { groupId } = req.params;
      const { fromUserId } = req.body;

      if (!fromUserId) {
        return res.status(400).json({ error: "Thiếu thông tin người gửi" });
      }

      const group = await Group.findOne({ _id: groupId, membersID: fromUserId });
      if (!group) {
        return res.status(403).json({ error: "Không có quyền gửi ảnh trong nhóm" });
      }

      if (!req.file) {
        return res.status(400).json({ error: "Không có file ảnh được gửi" });
      }

      // Upload ảnh lên Cloudinary
      const uploadFromBuffer = (buffer) => {
        return new Promise((resolve, reject) => {
          const stream = cloudinary.uploader.upload_stream(
            { folder: `/Groupify_MobileApp/group_messages/${groupId}` },
            (error, result) => {
              if (error) reject(error);
              else resolve(result);
            }
          );
          stream.end(buffer);
        });
      };

      const result = await uploadFromBuffer(req.file.buffer);

      const newMsg = await GroupMessage.create({
        groupId,
        fromUserId,
        message: '',
        imageUrl: result.secure_url,
      });

      const populatedMsg = await newMsg.populate("fromUserId", "username");

      // 🔥 Emit socket group message tại đây
      const io = req.app.get("io");
      if (io) {
        io.to(groupId).emit("groupMessage", populatedMsg);
      }

      return res.status(200).json(populatedMsg);

    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi server khi gửi ảnh nhóm" });
    }
}

};

module.exports = { ...chatGroupController, upload };