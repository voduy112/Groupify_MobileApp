const authRoutes = require("./auth");
const profileRoutes = require('./profile');
const documentRoutes = require('./document');
const groupRoutes = require('./group');
const chatRoutes = require('./chat');
const chatgroupRoutes = require('./chatGroup');

const InitRoutes = (app) => {
  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/document", documentRoutes);
  app.use("/api/group", groupRoutes);
  app.use("/api/chat", chatRoutes);
  app.use("/api/chatgroup", chatgroupRoutes);
};
module.exports = InitRoutes;
