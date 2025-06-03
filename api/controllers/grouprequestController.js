const GroupRequest = require("../models/GroupRequest");
const Group = require("../models/Group");

const grouprequestController = {
  createGroupRequest: async (req, res) => {
    try {
      const { groupId, userId } = req.body;
      if (!groupId || !userId) {
        return res.status(400).json({ error: "Thiếu thông tin khi xin vào nhóm" });
      }

      const existingRequest = await GroupRequest.findOne({ groupId, userId });
      if (existingRequest) {
        return res.status(409).json({ error: "Yêu cầu đã tồn tại" }); 
      }

      const newGroupRequest = new GroupRequest({ userId, groupId });
      const createdGroupRequest = await newGroupRequest.save();
      res.json(createdGroupRequest);
    } catch (error) {
      console.error("Lỗi khi xin vào nhóm:", error);
      res.status(500).json({ error: "Lỗi khi xin vào nhóm" });
    }
  },

  approveGroupRequest : async (req, res) => {
    try {
      const requestId = req.params.id;
  
      const groupRequest = await GroupRequest.findById(requestId);
      if (!groupRequest) {
        return res.status(404).json({ error: "Yêu cầu không tồn tại" });
      }
  
      const { groupId, userId } = groupRequest;

      const group = await Group.findById(groupId);
      if (!group) {
        return res.status(404).json({ error: "Nhóm không tồn tại" });
      }
  
      if (group.membersID.includes(userId)) {
        return res.status(400).json({ error: "Người dùng đã có trong nhóm" });
      }
  
      group.membersID.push(userId);
      await group.save();
  
      await GroupRequest.findByIdAndDelete(requestId);
  
      res.status(200).json({
        message: "Duyệt yêu cầu và thêm người dùng vào nhóm thành công",
        group,
      });
    } catch (error) {
      console.error("Lỗi khi duyệt yêu cầu vào nhóm:", error);
      res.status(500).json({ error: "Lỗi khi duyệt yêu cầu vào nhóm" });
    }
  },
  deleteRequest: async (req, res) => {
    try {
      const  groupRequestId = req.params.id;

      if (!groupRequestId) {
        return res.status(400).json({ error: "Thiếu groupRequestId" });
      }

      const deletedRequest = await GroupRequest.findByIdAndDelete(groupRequestId);

      if (!deletedRequest) {
        return res.status(404).json({ error: "Không tìm thấy yêu cầu để xóa" });
      }

      res.status(200).json({ message: "Xóa yêu cầu vào nhóm thành công" });
    } catch (error) {
      console.error("Lỗi khi xóa yêu cầu vào nhóm:", error);
      res.status(500).json({ error: "Lỗi khi xóa yêu cầu vào nhóm" });
    }
  },
  getAllRequestByGroupId: async (req, res) => {
    try {
      const { groupId } = req.params;
      const requests = await GroupRequest.find({ groupId })
        .populate('userId', 'username profilePicture') 
        .sort({ createdAt: -1 });          
  
      res.json(requests);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy yêu cầu theo groupId" });
    }
  }
  
  
  
};

module.exports = grouprequestController;
