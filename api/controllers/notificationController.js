const admin = require("../config/Firebase");

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
};

module.exports = notificationController;
