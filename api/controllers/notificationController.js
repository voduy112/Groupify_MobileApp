
const notificationController = {
    sendNotification: async (req, res) => {
        try {
            const { title, body, token } = req.body;

            // Kiểm tra xem token có hợp lệ không
            if (!token) {
                return res.status(400).json({ error: "Token không hợp lệ" });
            }

            // Tạo payload cho thông báo
            const payload = {
                notification: {
                    title: title,
                    body: body,
                },
                data: {
                    click_action: "FLUTTER_NOTIFICATION_CLICK",
                    id: "1",
                    status: "done",
                },
                token: token,
            };

            // Gửi thông báo
            const response = await admin.messaging().send(payload);
            console.log("Thông báo đã được gửi:", response);
            res.status(200).json({ message: "Thông báo đã được gửi thành công" });
        } catch (error) {
            console.error("Lỗi khi gửi thông báo:", error);
            res.status(500).json({ error: "Lỗi khi gửi thông báo" });
        }
    }
}