const Document = require("../models/Document");

const documentController = {
    getAllDocument : async (req, res) => {
        try {
            const documents = await Document.find();
            res.json(documents); 
        } catch (error) {
            res.status(404).json({error: "Lỗi lấy thông tin tài liệu"});
        }
    },
    getDocumentById : async (req, res) => {
        try {
            const document = await Document.findById(req.params.id);
            if(!document)
                return res.status(404).json({error: "Không tìm thấy tài liệu"});
            res.json(document);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi lấy thông tin tài liệu"});
        }
    },
    deleteDocument : async (req, res) => {
        try {
            const deleteDoucument = await Document.findByIdAndDelete(req.params.id);
            if(!deleteDoucument) {
                return res.status(404).json({error: "Tài liệu không tồn tại"});
            }
            res.status(200).json({message: "Xóa tài liệu thành công"});
        } catch (error) {
            res.status(500).json({error: "Lỗi khi xóa tài liệu"});
        }
    },
    updateDocument : async (req, res) => {
        try {
            const { groupId, title, description, uploaderId } = req.body;
            const updateDocument = await Document.findByIdAndUpdate(req.params.id, req.body, {new: true});
            res.json(updateDocument);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi cập nhật thông tin tài liệu"});
        }
    },
    uploadDocument : async (req, res) => {
        try {
            const { groupId, title, description, uploaderId } = req.body;
            if (!groupId || !title || !description || !uploaderId) {
                return res.status(400).json({error: "Thiếu thông tin tài liệu"});
            }
            const newDocument = new Document({
                groupId,
                title,
                description,
                uploaderId,
            });
            const uploadDocument = await newDocument.save();
            res.json(uploadDocument);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi tải tài liệu mới"});
        }
    },
};

module.exports = documentController;