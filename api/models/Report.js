const mongoose = require("mongoose")

const reportSchema = new mongoose.Schema({
    reporterId: {
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'User',
        required: true,
    },
    reason: {
        type: String,
        required: true,
    },
    documentId: {
        type: mongoose.Schema.Types.ObjectId, 
        ref: 'Document',
        required: true,
    },
    action: {
        type: String,
    },
    createDate: {
        type: Date,
        default: Date.now
    }
})
module.exports = mongoose.model('Report', reportSchema);