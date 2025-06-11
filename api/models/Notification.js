const mongoose = require("mongoose");

const notificationSchema = new mongoose.Schema({
  userId: {
    // Người nhận thông báo
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
  },
  type: {
    // Loại thông báo: 'join_request', 'join_accepted', 'group_document', ...
    type: String,
    required: true,
    enum: ["join_request", "join_accepted", "group_document", "chat", "other"],
  },
  title: { type: String, required: true },
  body: { type: String, required: true },
  groupId: {
    // Nếu liên quan đến group
    type: mongoose.Schema.Types.ObjectId,
    ref: "Group",
  },
  senderId: {
    // Người tạo ra thông báo (có thể là user hoặc admin)
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
  },
  isRead: { type: Boolean, default: false },
  createdAt: { type: Date, default: Date.now },
});

module.exports = mongoose.model("Notification", notificationSchema);
