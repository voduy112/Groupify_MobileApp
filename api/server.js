const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const connectDB = require('./config/MongoDB');
const InitRoutes = require('./routes/index');
const http = require('http');
const socketIo = require ('socket.io');
const socketHandler = require ('./sockets/socketHandler');


const app = express();
const Server = http.createServer(app);
const io = socketIo(Server, {
  cors: { origin: "*", methods: ["GET", "POST"]}
});
dotenv.config();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
const PORT = process.env.PORT || 5000;

// MongoDB connection
connectDB();

// Routes
InitRoutes(app);

//Sockets
socketHandler(io);

Server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});