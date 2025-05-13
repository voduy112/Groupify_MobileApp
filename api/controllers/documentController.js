const cloudinary = require('../config/Cloudinary')
const Document = require("../models/Document");
const Group = require("../models/Group");

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
            const existingDocument = await Document.findById(req.params.id);
            if(!existingDocument) {
                return res.status(404).json({error: "Tài liệu không tồn tại"});
            }

            if (existingDocument) {
                const result = await cloudinary.api.resources({
                    type: 'upload',
                    prefix: existingDocument.imgDocument,
                    max_results: 1
                });

                if(result.resources.length > 0) {
                    const publicId = result.resources[0].public_id;
                    await cloudinary.uploader.destroy(publicId);
                }
            }
            let updateData = {...req.body};

            if(req.file) {
                const uploadResult = await cloudinary.uploader.upload(req.file.path, {
                    folder: "Groupify_MobileApp/img_document",
                    public_id: `${req.params.id}_imgdocument`,
                    overwrite: true,
                });
                updateData.imgDocument = uploadResult.secure_url;                
            }

            const updateGroup = await Group.findByIdAndUpdate(
                req.params.id,
                updateData,
                {new: true}
            );
            res.json(updateGroup);
        } catch (error) {
            console.log(error);
            res.status(500).json({error: "Lỗi cập nhật thông tin tài liệu"});
        }
    },
    uploadDocument : async (req, res) => {
        try {
            const { groupId, title, description, uploaderId } = req.body;
            if (!groupId || !title || !description || !uploaderId) {
                return res.status(400).json({error: "Thiếu thông tin tài liệu"});
            }
            if (!req.file || !req.file.path) {
                return res.status(400).json({ error: "Chưa upload file tài liệu" });
            }          
            const newDocument = new Document({
                groupId,
                title,
                description,
                uploaderId,
                mainFile: req.file.path,
            });
            const uploadDocument = await newDocument.save();
            res.json(uploadDocument);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi tải tài liệu mới"});
        }
    },
};

module.exports = documentController;