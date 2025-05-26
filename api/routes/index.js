const express = require('express');
const authRoutes = require("./auth");
const profileRoutes = require('./profile');
const documentRoutes = require('./document');
const groupRoutes = require('./group');
const notificationRoutes = require('./notification');
const quizRoutes = require('./quiz');
const chatRoutes = require('./chat');
const chatgroupRoutes = require('./chatGroup');
const adminRoutes = require('./admin');

const initRoutes = (app) => {
  app.use(express.json());

  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/document", documentRoutes);
  app.use("/api/group", groupRoutes);
  app.use("/api/notification", notificationRoutes);
  app.use("/api/quiz", quizRoutes);
  app.use("/api/chat", chatRoutes);
  app.use("/api/admin", adminRoutes);
  app.use("/api/chatgroup", chatgroupRoutes);
};

module.exports = initRoutes;
