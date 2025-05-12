const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const bodyParser = require('body-parser');
const dotenv = require('dotenv');
const connectDB = require('./config/MongoDB');


const app = express();
const Server = require('http').createServer(app);
dotenv.config();

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));
const PORT = process.env.PORT || 5000;

// MongoDB connection
connectDB();

Server.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});