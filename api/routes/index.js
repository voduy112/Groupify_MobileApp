const authRoutes = require("./auth");
const profileRoutes = require('./profile');
const InitRoutes = (app) => {
  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
};
module.exports = InitRoutes;
