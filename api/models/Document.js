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
    }

}, { timestamps: true });

module.exports = mongoose.model('Document', documentSchema);