const mongoose = require('mongoose');

const documentSchema = new mongoose.Schema({
    groupId: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'Group'
    },
    title: {
        type: String,
        required: true, 
    },
    description: {
        type: String,
        required: true, 
    },
    uploaderId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User'
    },
    createdAt: {
        type: Date,
        default: Date.now
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
          userId: { type: String, required: true },
          username: { type: String }, // có thể lấy từ user hiện tại
          content: { type: String, required: true },
          createdAt: { type: Date, default: Date.now }
        }
      ],
      

}, { timestamps: true });

module.exports = mongoose.model('Document', documentSchema);