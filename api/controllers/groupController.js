const Group = require("../models/Group");

const cloudinary = require("../config/Cloudinary");

const groupController = {
  createGroup: async (req, res) => {
    try {
      const { name, description, subject, ownerId, membersID, inviteCode } =
        req.body;
      if (!name || !description || !subject || !ownerId || !inviteCode) {
        return res.status(400).json({ error: "Thiếu thông tin nhóm" });
      }
      const newGroup = new Group({
        name,
        description,
        subject,
        ownerId,
        membersID,
        inviteCode,
      });
      const createGroup = await newGroup.save();
      res.json(createGroup);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tạo nhóm mới" });
    }
  },
  getGroupById: async (req, res) => {
    try {
      const group = await Group.findById(req.params.id);
      if (!group) {
        return res.status(404).json({ error: "Không tìm thấy nhóm" });
      }
      res.json(group);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin nhóm" });
    }
  },
  getAllGroup: async (req, res) => {
    try {
      const groups = await Group.find().populate("membersID");
      return res.json(groups);
    } catch (error) {
      res.status(404).json({ error: "Lỗi khi lấy thông tin nhóm" });
    }
  },
  deleteGroup: async (req, res) => {
    try {
      const deleteGroup = await Group.findById(req.params.id);
      if (!deleteGroup) {
        return res.status(404).json({ error: "Nhóm không tồn tại" });
      }
      const imageUrl = deleteGroup.imgGroup;
      const publicId = imageUrl
        .split("/")
        .slice(-3)
        .join("/")
        .replace(/\.(jpg|jpeg|png|webp)$/i, "");
      await cloudinary.uploader.destroy(publicId);
      await Group.findByIdAndDelete(deleteGroup.id);
      res.status(200).json({ message: "Xóa nhóm thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa nhóm" });
    }
  },
  joinGroupByCode: async (req, res) => {
    try {
      const { inviteCode, userId } = req.body;
      const group = await Group.findOne({ inviteCode });

      if (!group) {
        return res
          .status(404)
          .json({ error: "Không tìm thấy nhóm với mã này" });
      }

      if (group.membersID.includes(userId)) {
        return res
          .status(400)
          .json({ error: "Người dùng đã tham gia nhóm này" });
      }
      group.membersID.push(userId);
      await group.save();
      res.json(group);
    } catch (error) {
      return res.status(500).json({ error: "Lỗi khi tham gia nhóm" });
    }
  },
  updateGroup: async (req, res) => {
    try {
      const existingGroup = await Group.findById(req.params.id);
      if (!existingGroup) {
        return res.status(404).json({ error: "Nhóm không tồn tại" });
      }

      if (existingGroup) {
        const result = await cloudinary.api.resources({
          type: "upload",
          prefix: existingGroup.imgGroup,
          max_results: 1,
        });

        if (result.resources.length > 0) {
          const publicId = result.resources[0].public_id;
          await cloudinary.uploader.destroy(publicId);
        }
      }
      let updateData = { ...req.body };

      if (req.file) {
        const uploadResult = await cloudinary.uploader.upload(req.file.path, {
          folder: "Groupify_MobileApp/img_group",
          public_id: `${req.params.id}_imggroup`,
          overwrite: true,
        });
        updateData.imgGroup = uploadResult.secure_url;
      }

      const updateGroup = await Group.findByIdAndUpdate(
        req.params.id,
        updateData,
        { new: true }
      );
      res.json(updateGroup);
    } catch (error) {
      console.log(error);
      res.status(500).json({ error: "Lỗi cập nhật thông tin nhóm" });
    }
  },

  leaveGroup: async (req, res) => {
    try {
      const { groupId, userId } = req.body;
      const group = await Group.findById(groupId);
      if (!group) {
        return res.status(404).json({ error: "Không tìm thấy nhóm" });
      }
      if (!group.membersID.includes(userId)) {
        return res
          .status(400)
          .json({ error: "Người dùng không phải là thành viên" });
      }
      group.membersID.pull(userId);
      await group.save();
      res.status(200).json({ messasge: "Rời nhóm thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi rời nhóm" });
    }
  },
  getGroupMembers: async (req, res) => {
    try {
      const group = await Group.findById(req.params.id).populate("membersID");
      if (!group) {
        return res.status(404).json({ error: "Không tìm thấy nhóm" });
      }
      res.json(group.membersID);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi khi lấy danh sách thành viên" });
    }
  },
  getAllGroupByUserId: async (req, res) => {
    const userId = req.params.id || req.query.id;
    if (!userId) {
      return res.status(400).json({ error: "Thiếu userId" });
    }

    try {
      const groups = await Group.find({
        $or: [{ ownerId: userId }, { membersID: userId }],
      }).populate("membersID");

      return res.json(groups);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi khi lấy nhóm theo userId" });
    }
  },
};

module.exports = groupController;
