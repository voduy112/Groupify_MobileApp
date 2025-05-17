const authRoutes = require("./auth");
const profileRoutes = require('./profile');
const documentRoutes = require('./document');
const groupRoutes = require('./group');
const notificationRoutes = require('./notification');
const quizRoutes = require('./quiz');
const chatRoutes = require('./chat');


const InitRoutes = (app) => {
  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/document", documentRoutes);
  app.use("/api/group", groupRoutes);
  app.use("/api/notification",notificationRoutes);
  app.use("/api/quiz", quizRoutes);
  app.use("/api/chat", chatRoutes);

};
module.exports = InitRoutes;
