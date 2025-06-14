
const mongoose = require('mongoose');

const updateSchema = new mongoose.Schema({

  title: String,
  content: String,
}, { timestamps: true });  

module.exports = mongoose.model('Update', updateSchema);
