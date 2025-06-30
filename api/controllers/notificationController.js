const admin = require("../config/Firebase");
const User = require("../models/User");
const Group = require("../models/Group");
const Notification = require("../models/Notification");

const notificationController = {
  getAllNotification: async (req, res) => {
    const { userId } = req.params;
    const notifications = await Notification.find({ userId: userId })
      .sort({ createdAt: -1 })
      .limit(8);
    res.status(200).send({ success: true, notifications });
  },

  readNotification: async (req, res) => {
    const { notiId } = req.params;
    await Notification.findByIdAndUpdate(notiId, { isRead: true });
    res.status(200).send({ success: true });
  },

  sendNotification: async (req, res) => {
    const { token, title, body } = req.body;
    console.log("Received request to send notification:", req.body);

    if (!token || !title || !body) {
      return res
        .status(400)
        .send({ success: false, message: "Thiếu dữ liệu cần thiết" });
    }

    const message = {
      notification: {
        title: title,
        body: body,
      },
      token: token,
    };

    // Chỉ gửi FCM, không lưu notification vào DB ở hàm này
    try {
      const response = await admin.messaging().send(message);
      res.status(200).send({ success: true, response });
    } catch (error) {
      res.status(500).send({ success: false, error: error.message });
    }
  },

  sendJoinRequestNotification: async (req, res) => {
    const { adminFcmToken, userName, groupName, groupId, userId } = req.body;
    console.log(
      "Received request to send join request notification:",
      req.body
    );

    if (!adminFcmToken || !userName || !groupName || !groupId || !userId) {
      return res
        .status(400)
        .send({ success: false, message: "Thiếu dữ liệu cần thiết" });
    }

    const group = await Group.findById(groupId);
    if (!group) {
      return res
        .status(404)
        .send({ success: false, message: "Không tìm thấy group" });
    }

    const message = {
      notification: {
        title: "Yêu cầu tham gia nhóm",
        body: `Người dùng ${userName} muốn tham gia nhóm ${groupName}`,
      },
      token: adminFcmToken,
    };

    let fcmResponse = null;
    try {
      fcmResponse = await admin.messaging().send(message);
    } catch (error) {
      // Có thể log lỗi nếu muốn, nhưng vẫn tiếp tục
    }
    // Luôn lưu notification vào DB
    await Notification.create({
      userId: group.ownerId, // admin nhận
      type: "join_request",
      title: "Yêu cầu tham gia nhóm",
      body: `Người dùng ${userName} muốn tham gia nhóm ${groupName}`,
      groupId: group._id,
      senderId: userId, // người gửi yêu cầu
    });
    res.status(200).send({ success: true, response: fcmResponse });
  },

  sendAcceptJoinNotification: async (req, res) => {
    const { userId, groupId } = req.body;
    if (!userId || !groupId) {
      return res
        .status(400)
        .send({ success: false, message: "Thiếu dữ liệu cần thiết" });
    }
    const user = await User.findById(userId);
    const group = await Group.findById(groupId);
    if (!user || !group) {
      return res
        .status(404)
        .send({ success: false, message: "Không tìm thấy user hoặc group" });
    }
    const userFcmToken = user.fcmToken;
    const groupName = group.name;
    const message = {
      notification: {
        title: "Chấp nhận vào nhóm",
        body: `Bạn đã được chấp nhận vào nhóm ${groupName}`,
      },
      token: userFcmToken,
    };
    let fcmResponse = null;
    try {
      fcmResponse = await admin.messaging().send(message);
    } catch (error) {
      // Có thể log lỗi nếu muốn, nhưng vẫn tiếp tục
    }
    // Luôn lưu notification vào DB
    await Notification.create({
      userId: userId, // người dùng nhận
      type: "join_accepted",
      title: "Chấp nhận vào nhóm",
      body: `Bạn đã được chấp nhận vào nhóm ${groupName}`,
      groupId: group._id,
      senderId: group.ownerId, // admin xác nhận
    });
    res.status(200).send({ success: true, response: fcmResponse });
  },

  sendPersonalChatNotification: async (req, res) => {
    const { receiverId, senderName, message } = req.body;
    if (!receiverId || !senderName || !message) {
      return res
        .status(400)
        .send({ success: false, message: "Thiếu dữ liệu cần thiết" });
    }
    const user = await User.findById(receiverId);
    if (!user || !user.fcmToken) {
      return res
        .status(404)
        .send({ success: false, message: "Không tìm thấy user hoặc fcmToken" });
    }
    const fcmToken = user.fcmToken;
    const payload = {
      notification: {
        title: `Tin nhắn mới từ ${senderName}`,
        body: message,
      },
      token: fcmToken,
    };
    let fcmResponse = null;
    try {
      fcmResponse = await admin.messaging().send(payload);
    } catch (error) {
      // Có thể log lỗi nếu muốn, nhưng vẫn tiếp tục
    }
    // Luôn lưu notification vào DB
    await Notification.create({
      userId: receiverId,
      type: "personal_chat",
      title: `Tin nhắn mới từ ${senderName}`,
      body: message,
      senderId: null, // Nếu muốn lưu senderId thì truyền vào
    });
    res.status(200).send({ success: true, response: fcmResponse });
  },

  sendGroupDocumentNotification: async (req, res) => {
    const { groupId, adminName, documentTitle } = req.body;
    if (!groupId || !adminName || !documentTitle) {
      return res
        .status(400)
        .send({ success: false, message: "Thiếu dữ liệu cần thiết" });
    }

    const group = await Group.findById(groupId).populate(
      "membersID",
      "fcmToken mutedGroups"
    );
    if (!group) {
      return res
        .status(404)
        .send({ success: false, message: "Không tìm thấy group" });
    }

    for (const member of group.membersID) {
      if (
        member._id.toString() !== group.ownerId.toString() &&
        !(
          member.mutedGroups &&
          member.mutedGroups
            .map((id) => id.toString())
            .includes(group._id.toString())
        )
      ) {
        // Nếu có fcmToken thì gửi FCM, còn không thì bỏ qua bước gửi FCM
        if (member.fcmToken) {
          const message = {
            notification: {
              title: `Tài liệu mới từ admin ${adminName} nhóm ${group.name}`,
              body: `Admin vừa gửi tài liệu: ${documentTitle}`,
            },
            token: member.fcmToken,
          };
          try {
            await admin.messaging().send(message);
          } catch (error) {
            // Có thể log lỗi nếu muốn, nhưng vẫn tiếp tục
          }
        }
        // Luôn lưu notification vào DB
        console.log("Lưu notification cho user:", member._id);
        try {
          await Notification.create({
            userId: member._id,
            type: "group_document",
            title: `Tài liệu mới từ admin ${adminName} nhóm ${group.name}`,
            body: `Admin vừa gửi tài liệu: ${documentTitle}`,
            groupId: group._id,
            senderId: group.ownerId,
          });
          console.log("Đã lưu notification thành công cho user:", member._id);
        } catch (err) {
          console.error("Lỗi khi lưu notification:", err);
        }
      }
    }
    res.status(200).send({
      success: true,
      message: "Đã gửi xong thông báo cho các thành viên",
    });
  },
  sendQuizNotification: async (req, res) => {
    const { groupId, quizTitle } = req.body;
    if (!groupId || !quizTitle) {
      return res
        .status(400)
        .send({ success: false, message: "Thiếu dữ liệu cần thiết" });
    }
    const group = await Group.findById(groupId).populate(
      "membersID",
      "fcmToken mutedGroups"
    );
    if (!group) {
      return res
        .status(404)
        .send({ success: false, message: "Không tìm thấy group" });
    }
    for (const member of group.membersID) {
      if (
        member._id.toString() !== group.ownerId.toString() &&
        !(
          member.mutedGroups &&
          member.mutedGroups
            .map((id) => id.toString())
            .includes(group._id.toString())
        )
      ) {
        if (member.fcmToken) {
          const message = {
            notification: {
              title: `Quiz mới từ admin nhóm ${group.name}`,
              body: `Admin vừa gửi quiz: ${quizTitle}`,
            },
            token: member.fcmToken,
          };
          try {
            await admin.messaging().send(message);
          } catch (error) {
            // Có thể log lỗi nếu muốn, nhưng vẫn tiếp tục
          }
        }
        // Luôn lưu notification vào DB
        console.log("Lưu notification cho user:", member._id);
        try {
          await Notification.create({
            userId: member._id,
            type: "quiz",
            title: `Quiz mới từ admin nhóm ${group.name}`,
            body: `Admin vừa gửi quiz: ${quizTitle}`,
            groupId: group._id,
            senderId: group.ownerId,
          });
          console.log("Đã lưu notification thành công cho user:", member._id);
        } catch (err) {
          console.error("Lỗi khi lưu notification:", err);
        }
      }
    }
    res.status(200).send({
      success: true,
      message: "Đã gửi xong thông báo cho các thành viên",
    });
  },

  getMutedGroups: async (req, res) => {
    try {
      const { userId } = req.params;
      const user = await User.findById(userId);
      if (!user) {
        return res
          .status(404)
          .send({ success: false, message: "User not found" });
      }
      const mutedGroups = user.mutedGroups;
      const groups = await Group.find({ _id: { $in: mutedGroups } });
      res.status(200).send({ success: true, groups });
    } catch (err) {
      res.status(500).send({ success: false, message: "Server error" });
    }
  },
  muteGroup: async (req, res) => {
    try {
      const { groupId, userId } = req.body;
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ error: "Không tìm thấy user" });
      }
      if (user.mutedGroups.includes(groupId)) {
        return res.status(400).json({ error: "Đã mute nhóm" });
      }
      user.mutedGroups.push(groupId);
      await user.save();
      res.status(200).json({ message: "Đã mute nhóm" });
    } catch (error) {
      console.error("Lỗi khi mute nhóm:", error);
      res.status(500).json({ error: "Lỗi khi mute nhóm" });
    }
  },
  unmuteGroup: async (req, res) => {
    try {
      const { groupId, userId } = req.body;
      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ error: "Không tìm thấy user" });
      }
      user.mutedGroups = user.mutedGroups.filter(
        (id) => id.toString() !== groupId
      );
      await user.save();
      res.status(200).json({ message: "Đã unmute nhóm" });
    } catch (error) {
      console.error("Lỗi khi unmute nhóm:", error);
      res.status(500).json({ error: "Lỗi khi unmute nhóm" });
    }
  },
  readAllNotifications: async (req, res) => {
    const { userId } = req.params;
    try {
      await Notification.updateMany(
        { userId: userId, isRead: false },
        { $set: { isRead: true } }
      );
      res.status(200).send({
        success: true,
        message: "Đã đánh dấu tất cả thông báo là đã đọc",
      });
    } catch (error) {
      res.status(500).send({ success: false, message: "Lỗi server" });
    }
  },
};

module.exports = notificationController;
