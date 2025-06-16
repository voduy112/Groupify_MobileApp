const express = require('express');
const authRoutes = require("./auth");
const profileRoutes = require('./profile');
const documentRoutes = require('./document');
const groupRoutes = require('./group');
const notificationRoutes = require('./notification');
const quizRoutes = require('./quiz');
const chatRoutes = require('./chat');
const resultRoutes = require('./result');
const chatgroupRoutes = require('./chatGroup');

const adminRoutes = require('./admin');

const initRoutes = (app) => {
  app.use(express.json());

const requestRoutes = require('./grouprequest');

  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/document", documentRoutes);
  app.use("/api/group", groupRoutes);
  app.use("/api/notification", notificationRoutes);
  app.use("/api/quiz", quizRoutes);
  app.use("/api/chat", chatRoutes);
  app.use("/api/admin", adminRoutes);
  app.use("/api/result", resultRoutes);
  app.use("/api/chatgroup", chatgroupRoutes);
  app.use("/api/grouprequest", requestRoutes);
};

module.exports = initRoutes;
