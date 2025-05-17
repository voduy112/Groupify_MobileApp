const Message = require ("../models/Message");

function createRoomId(user1, user2) {
    return [user1, user2].sort().join("_");
}

function socketHandler(io) {
    io.on("connection", (socket) => {
        console.log("Socket connected", socket.id);

        socket.on("joinRoom", ({fromUserId, toUserId}) => {
            const room = createRoomId(fromUserId, toUserId);
            socket.join(room);
            console.log(`${fromUserId} join room ${room}`);
        });

        //Lay lich su tro chuyen

        socket.on("loadMessages", async ({fromUserId, toUserId}) => {
            try {
                const messages = await Message.find({
                    $or: [
                        {fromUserId, toUserId},
                        {fromUserId: toUserId, toUserId: fromUserId}
                    ]
                }).sort({timestamp: 1});

                socket.emit("chatHistory", messages);
            } catch (error) {
                console.error("Lỗi khi lấy lịch trò chuyện");
                socket.emit("chatHistory", []);
            }
        });

        //Gui tin nhan ca nhan va luu vao MongoDB
        socket.on("privateMessage", async ({fromUserId, toUserId, message}) => {
            try {
                const room = createRoomId(fromUserId, toUserId);
                const saved = await Message.create({fromUserId, toUserId, message});

                io.to(room).emit("privateMessage", saved);
            } catch (error) {
                console.log("Error saving message: ", error);
            }
        });

        socket.on("disconnect", () => {
            console.log("Socket disconnected: ", socket.id);
        });
    });
}

module.exports = socketHandler;