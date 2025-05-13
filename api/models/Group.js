const mongoose = require("mongoose")

const groupSchema = new mongoose.Schema({
    name: {
        type: String,
        required: true,
    },
    description: {
        type: String,
        required: true,
    },
    subject: {
        type: String,
        required: true,
    },
    ownerId: {
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User',
        required: true,
    },
    membersID: [{
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
    }],
    inviteCode: {
        type: String,
        required: true,
    },
    createDate: {
        type: Date,
        default: Date.now
    }
})
module.exports = mongoose.model('Group', groupSchema);