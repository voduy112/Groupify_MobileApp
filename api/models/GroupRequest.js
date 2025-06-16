const mongoose = require('mongoose');

const groupRequestSchema = new mongoose.Schema({
    groupId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'Group'
    },
    userId: {
        type: mongoose.Schema.Types.ObjectId,
        required: true,
        ref: 'User'
    },
    requestAt: {
        type: Date,
        default: Date.now
    },
}, { timestamps: true });

module.exports = mongoose.model('GroupRequest', groupRequestSchema);