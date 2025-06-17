const authRoutes = require("./auth");
const profileRoutes = require('./profile');
const documentRoutes = require('./document');
const groupRoutes = require('./group');
const notificationRoutes = require('./notification');
const quizRoutes = require('./quiz');
const chatRoutes = require('./chat');
const resultRoutes = require('./result');
const chatgroupRoutes = require('./chatGroup');
const requestRoutes = require('./grouprequest');
const reportRoutes = require('./report');

const InitRoutes = (app) => {
  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/document", documentRoutes);
  app.use("/api/group", groupRoutes);
  app.use("/api/notification",notificationRoutes);
  app.use("/api/quiz", quizRoutes);
  app.use("/api/chat", chatRoutes);
  app.use("/api/result", resultRoutes);
  app.use("/api/chatgroup", chatgroupRoutes);
  app.use("/api/grouprequest", requestRoutes);
  app.use("/api/report", reportRoutes);
};
module.exports = InitRoutes;
