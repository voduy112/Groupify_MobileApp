const admin = require("../config/Firebase");
const User = require("../models/User");
const Group = require("../models/Group");

const notificationController = {
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

    try {
      const response = await admin.messaging().send(message);
      res.status(200).send({ success: true, response });
    } catch (error) {
      res.status(500).send({ success: false, error: error.message });
    }
  },

  sendJoinRequestNotification: async (req, res) => {
    const { adminFcmToken, userName, groupName } = req.body;
    console.log(
      "Received request to send join request notification:",
      req.body
    );

    if (!adminFcmToken || !userName || !groupName) {
      return res
        .status(400)
        .send({ success: false, message: "Thiếu dữ liệu cần thiết" });
    }

    const message = {
      notification: {
        title: "Yêu cầu tham gia nhóm",
        body: `Người dùng ${userName} muốn tham gia nhóm ${groupName}`,
      },
      token: adminFcmToken,
    };

    try {
      const response = await admin.messaging().send(message);
      res.status(200).send({ success: true, response });
    } catch (error) {
      res.status(500).send({ success: false, error: error.message });
    }
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
    try {
      const response = await admin.messaging().send(message);
      res.status(200).send({ success: true, response });
    } catch (error) {
      res.status(500).send({ success: false, error: error.message });
    }
  },
};

module.exports = notificationController;
