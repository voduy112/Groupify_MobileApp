const authRoutes = require("./auth");
const profileRoutes = require('./profile');
const documentRoutes = require('./document');
const groupRoutes = require('./group');
const chatRoutes = require('./chat');
const quizRoutes = require('./quiz');
const express = require('express');
const app = express();


const InitRoutes = (app) => {
  app.use(express.json());
  app.use("/api/auth", authRoutes);
  app.use("/api/profile", profileRoutes);
  app.use("/api/document", documentRoutes);
  app.use("/api/group", groupRoutes);
  app.use("/api/chat", chatRoutes);
  app.use("/api/quiz", quizRoutes); 
};

module.exports = InitRoutes;
