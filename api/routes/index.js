const authRoutes = require("./auth");
const profileRoutes = require('./profile');
const documentRoutes = require('./document');
const groupRoutes = require('./group');
const notificationRoutes = require('./notification');

const InitRoutes = (app) => {
  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/document", documentRoutes);
  app.use("/api/group", groupRoutes);
  app.use("/api/notfication",notificationRoutes);
};
module.exports = InitRoutes;
