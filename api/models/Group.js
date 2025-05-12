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
    membersID: {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
        required: true,
    },
    inviteCode: {
        type: String,
        required: true,
    },
    createDate: {
        type: Date,
        required: true,
    }
})
module.exports = mongoose.model('Group', groupSchema);