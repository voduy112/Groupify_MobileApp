const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema({
  groupId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Group'
  },
  title: {
    type: String,
    required: true,
    trim: true
  },
  description: {
    type: String,
    required: true,
    trim: true
  },
  uploaderId: {
    type: mongoose.Schema.Types.ObjectId,
    required: true,
    ref: 'User'
  },
  imgDocument: {
    type: String,
    default: 'default.jpg'
  },
  mainFile: {
    type: String,
    default: 'file.pdf'
  },


  ratings: [
    {
      userId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true
      },
      value: {
        type: Number,
        min: 1,
        max: 5,
        required: true
      }
    }
  ],


  comments: [
    {
      _id: { type: mongoose.Schema.Types.ObjectId, auto: true },
      userId: { type: mongoose.Schema.Types.ObjectId, required: true, ref: 'User' },
      username: { type: String },
      rating: Number,
      avatar: { type: String },
      content: { type: String, required: true },
      createdAt: { type: Date, default: Date.now }
    }
  ],

  reportCount: {
    type: Number,
    default: 0
  },


  deleted: {
    type: Boolean,
    default: false
  }

}, { timestamps: true });

module.exports = mongoose.model('Document', documentSchema);
