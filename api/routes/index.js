const authRoutes = require("./auth");

const InitRoutes = (app) => {
  app.use("/api/auth", authRoutes);
};
module.exports = InitRoutes;
