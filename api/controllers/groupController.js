const Group = require("../models/Group");

const cloudinary = require("../config/Cloudinary");

function removeVietnameseTones(str) {
  return str
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/đ/g, "d")
    .replace(/Đ/g, "D");
}

const groupController = {
  searchGroup: async (req, res) => {
    const { query } = req.query;
    try {
      const groups = await Group.find({
        name: { $regex: query, $options: "i" },
      });
      if (groups.length > 0) {
        return res.json(groups);
      }
      const allGroups = await Group.find({});
      const queryNoAccent = removeVietnameseTones(query).toLowerCase();
      const filtered = allGroups.filter((group) =>
        removeVietnameseTones(group.name).toLowerCase().includes(queryNoAccent)
      );
      res.json(filtered);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tìm kiếm nhóm" });
    }
  },
  createGroup: async (req, res) => {
    try {
      const { name, description, subject, ownerId, membersID, inviteCode } =
        req.body;
      if (!name || !description || !subject || !ownerId || !inviteCode) {
        return res.status(400).json({ error: "Thiếu thông tin nhóm" });
      }
      if (!req.files || !req.files.image) {
        return res.status(400).json({ error: "Chưa chọn file ảnh nhóm" });
      }

      const times = Date.now();

      const imgUploadResult = await cloudinary.uploader.upload(
        req.files.image[0].path,
        {
          folder: "Groupify_MobileApp/img_group",
          public_id: `${ownerId}_${times}_imggroup`,
          overwrite: false,
        }
      );
      const newGroup = new Group({
        name,
        description,
        subject,
        ownerId,
        membersID: membersID || [],
        inviteCode,
        imgGroup: imgUploadResult.secure_url,
      });
      const createGroup = await newGroup.save();
      res.json(createGroup);
    } catch (error) {
      console.error("Lỗi createGroup:", error);
      res.status(500).json({ error: "Lỗi khi tạo nhóm mới" });
    }
  },
  getGroupById: async (req, res) => {
    try {
      const group = await Group.findById(req.params.id).populate(
        "ownerId",
        "username fcmToken"
      );
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
      const userId = req.query.userId;
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const skip = (page - 1) * limit;

      let query = {};
      if (userId) {
        query = {
          membersID: { $ne: userId },
          ownerId: { $ne: userId },
        };
      }

      const totalGroups = await Group.countDocuments(query);
      const groups = await Group.find(query)
        .populate("membersID")
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: 1 });

      return res.json({
        totalGroups,
        totalPages: Math.ceil(totalGroups / limit),
        currentPage: page,
        groups,
      });
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
      const { groupId, inviteCode, userId } = req.body;

      const group = await Group.findOne({ _id: groupId, inviteCode });

      if (!group) {
        return res.status(404).json({ error: "INVALID_INVITE_CODE" });
      }

      if (group.membersID.includes(userId)) {
        return res
          .status(400)
          .json({ error: "Người dùng đã tham gia nhóm này" });
      }

      group.membersID.push(userId);
      await group.save();
      return res.json(group);
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
      const times = Date.now();
      if (req.file) {
        const uploadResult = await cloudinary.uploader.upload(req.file.path, {
          folder: "Groupify_MobileApp/img_group",
          public_id: `${req.params.id}_${times}_imggroup`,
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
  /*getGroupMembers: async (req, res) => {
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
  },*/

  getGroupMembers: async (req, res) => {
    try {
      const group = await Group.findById(req.params.id)
        .populate("membersID", "username profilePicture")
        .populate("ownerId", "username profilePicture");

      if (!group) {
        return res.status(404).json({ error: "Không tìm thấy nhóm" });
      }

      // Convert ownerId (User model) to object with consistent structure
      const owner = group.ownerId.toObject();
      owner.role = "owner"; // Thêm thông tin phân biệt

      // Convert members, thêm role nếu cần
      const members = group.membersID.map((member) => {
        const m = member.toObject();
        m.role = "member";
        return m;
      });

      // Kiểm tra nếu owner đã nằm trong members thì không thêm lại
      const isOwnerInMembers = members.some(
        (m) => m._id.toString() === owner._id.toString()
      );
      const allMembers = isOwnerInMembers ? members : [owner, ...members];

      res.json(allMembers);
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
      }).lean();

      res.json(groups);
    } catch (error) {
      console.error("Lỗi getAllGroupByUserId:", error);
      res.status(500).json({ error: "Lỗi máy chủ khi lấy danh sách nhóm" });
    }
  },

  /*getGroupMembers: async (req, res) => {
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
  },*/

  addUserIntoGroup: async (req, res) => {
    try {
      const { groupId, userId } = req.body;

      if (!groupId || !userId) {
        return res.status(400).json({ error: "Thiếu groupId hoặc userId" });
      }

      const group = await Group.findById(groupId);
      if (!group) {
        return res.status(404).json({ error: "Không tìm thấy nhóm" });
      }

      if (group.membersID.includes(userId)) {
        return res.status(400).json({ error: "Người dùng đã có trong nhóm" });
      }

      group.membersID.push(userId);
      await group.save();

      res
        .status(200)
        .json({ message: "Thêm người dùng vào nhóm thành công", group });
    } catch (error) {
      console.error("Lỗi khi thêm người dùng vào nhóm:", error);
      res.status(500).json({ error: "Lỗi khi thêm người dùng vào nhóm" });
    }
  },

  removeMember: async (req, res) => {
    try {
      const { groupId, memberId } = req.body;

      const group = await Group.findById(groupId);
      if (!group) {
        return res.status(404).json({ error: "Không tìm thấy nhóm" });
      }

      // Kiểm tra member có trong nhóm không
      if (!group.membersID.includes(memberId)) {
        return res
          .status(400)
          .json({ error: "Thành viên không tồn tại trong nhóm" });
      }

      // Xoá thành viên
      group.membersID.pull(memberId);
      await group.save();

      res.status(200).json({ message: "Xoá thành viên thành công" });
    } catch (error) {
      console.error("Lỗi khi xoá thành viên:", error);
      res.status(500).json({ error: "Lỗi khi xoá thành viên" });
    }
  },

  changeOwnerId: async (req, res) => {
    try {
      const { groupId, newOwnerId } = req.body;

      if (!groupId || !newOwnerId) {
        return res.status(400).json({ error: "Thiếu groupId hoặc newOwnerId" });
      }

      const group = await Group.findById(groupId);
      if (!group) {
        return res.status(404).json({ error: "Không tìm thấy nhóm" });
      }

      if (!group.membersID.includes(newOwnerId)) {
        return res
          .status(400)
          .json({ error: "Người dùng không phải là thành viên nhóm" });
      }

      const oldOwnerId = group.ownerId.toString();

      // Đổi chủ nhóm
      group.ownerId = newOwnerId;

      // Gỡ newOwnerId khỏi members
      group.membersID = group.membersID.filter(
        (memberId) => memberId.toString() !== newOwnerId
      );

      // Thêm oldOwnerId vào members nếu chưa có
      if (!group.membersID.includes(oldOwnerId)) {
        group.membersID.push(oldOwnerId);
      }

      await group.save();

      return res
        .status(200)
        .json({ message: "Chuyển quyền chủ nhóm thành công", group });
    } catch (error) {
      console.error("Lỗi khi đổi ownerId:", error);
      return res.status(500).json({ error: "Lỗi khi đổi quyền chủ nhóm" });
    }
  },
};

module.exports = groupController;
