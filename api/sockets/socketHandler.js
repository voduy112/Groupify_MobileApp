const Message = require ("../models/Message");
const GroupMessage = require ("../models/GroupMessage");

function createRoomId(user1, user2) {
    return [user1, user2].sort().join("_");
}

function socketHandler(io) {
    io.on("connection", (socket) => {
        console.log("Socket connected", socket.id);

        //1v1
        socket.on("joinRoom", ({fromUserId, toUserId}) => {
            const room = createRoomId(fromUserId, toUserId);
            socket.join(room);
            console.log(`${fromUserId} join room ${room}`);
        });

        //group
        socket.on("joinGroup", ({groupId}) => {
            socket.join(groupId);
            console.log(`Socket ${socket.id} joined group ${groupId}`);
        });

        //Lay lich su tro chuyen
        socket.on("loadMessages", async ({fromUserId, toUserId}) => {
            try {
                const messages = await Message.find({
                    $or: [
                        {fromUserId, toUserId},
                        {fromUserId: toUserId, toUserId: fromUserId}
                    ]
                })
                .sort({timestamp: 1})
                .populate("fromUserId", "username profilePicture email phoneNumber")
                .populate("toUserId", "username profilePicture email phoneNumber");

                // Ham de test hien thi thong bao loi
                // socket.emit('chatHistory', [{ invalid: 'errorTest' }]);
                
                socket.emit("chatHistory", messages);
            } catch (error) {
                console.error("Lỗi khi lấy lịch trò chuyện", error);
                socket.emit("chatHistory", []);
            }
        });
        
        //Lay lich su tro chuyen nhom
        socket.on("loadGroupMessages", async ({groupId}) => {
            try {
                const messages = await GroupMessage.find({groupId})
                    .sort({timestamp: 1})
                    .populate("fromUserId", "username profilePicture");
                socket.emit("groupChatHistory", messages);
            } catch (error) {
                console.error("Lỗi khi lấy tin nhắn nhóm", error);
                socket.emit("groupChatHistory", []);
            }
        });

        //Gui tin nhan ca nhan va luu vao MongoDB
        socket.on("privateMessage", async ({ fromUserId, toUserId, message }) => {
            try {
              const room = createRoomId(fromUserId, toUserId);
          
              const saved = await Message.create({ fromUserId, toUserId, message });

              const populatedMsg = await Message.findById(saved._id)
                .populate("fromUserId", "username profilePicture email phoneNumber")
                .populate("toUserId", "username profilePicture email phoneNumber");
          
              io.to(room).emit("privateMessage", populatedMsg);
            } catch (error) {
              console.log("Error saving message: ", error);
            }
          });
          
        //Gui tin nhan nhom va luu vao MongoDB
        socket.on("groupMessage", async ({groupId, fromUserId, message, imageUrl}) => {
            try {
                const saved = await GroupMessage.create({groupId, fromUserId, message, imageUrl});
                const populatedMsg = await saved.populate("fromUserId", "username profilePicture");

                io.to(groupId).emit("groupMessage", populatedMsg);
            } catch (error) {
                console.error("Lỗi khi gửi tin nhắn nhóm", error);
            }
        });

        socket.on("disconnect", () => {
            console.log("Socket disconnected: ", socket.id);
        });
    });
}

module.exports = socketHandler;