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
            const deleteDocument = await Document.findById(req.params.id);
            if(!deleteDocument) {
                return res.status(404).json({error: "Nhóm không tồn tại"});
            }
            const imageUrl = deleteDocument.imgDocument;
            const fileUrl = deleteDocument.mainFile;
            const filePublicId = fileUrl
            .split('/').slice(-3).join('/').replace(/\.(pdf)$/i, '')
            console.log(filePublicId)
            await cloudinary.uploader.destroy(filePublicId,{ resource_type: "raw" });
            const imgPublicId = imageUrl
            .split('/').slice(-3).join('/').replace(/\.(jpg|jpeg|png|webp)$/i, '')
            await cloudinary.uploader.destroy(imgPublicId);

            await Document.findByIdAndDelete(deleteDocument.id);
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
                const resultimg = await cloudinary.api.resources({
                    type: 'upload',
                    prefix: existingDocument.imgDocument,
                    max_results: 1
                });

                if(resultimg.resources.length > 0) {
                    const publicId = resultimg.resources[0].public_id;
                    await cloudinary.uploader.destroy(publicId);
                }
                const resultfile = await cloudinary.api.resources({
                    type: 'upload',
                    prefix: existingDocument.mainFile,
                    max_result: 1
                });
                if(resultfile.resources.length > 0) {
                    const filepublicId = resultfile.resources[0].public_id;
                    await cloudinary.uploader.destroy(filepublicId);
                }
            }
            let updateData = {...req.body};
            if (req.files && req.files.image && req.files.image[0]) {
                const uploadResult = await cloudinary.uploader.upload(req.files.image[0].path, {
                    folder: "Groupify_MobileApp/img_document",
                    public_id: `${req.params.id}_imgdocument`,
                    overwrite: false,
                });
                updateData.imgDocument = uploadResult.secure_url;
            }
            
            if (req.files && req.files.mainFile && req.files.mainFile[0]) {
                const uploadResult = await cloudinary.uploader.upload(req.files.mainFile[0].path, {
                    folder: "Groupify_MobileApp/file_document",
                    public_id: `${req.params.id}_filedocument`,
                    resource_type: "raw", // rất quan trọng nếu là PDF
                    overwrite: false,
                });
                updateData.mainFile = uploadResult.secure_url;
            }            

            const updateDocument = await Document.findByIdAndUpdate(
                req.params.id,
                updateData,
                {new: true}
            );
            res.json(updateDocument);
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
            if (!req.files || !req.files.mainFile) {
                return res.status(400).json({ error: "Chưa upload file tài liệu" });
            }         
            
            const imgUploadResult = await cloudinary.uploader.upload(req.files.image[0].path, {
                folder: "Groupify_MobileApp/img_document",
                public_id: `${req.params.id}_imgdocument`,
                overwrite: false,
            });
            
            const fileUploadResult = await cloudinary.uploader.upload(req.files.mainFile[0].path, {
                folder: "Groupify_MobileApp/file_document",
                public_id: `${req.params.id}_filedocument`,
                resource_type: "raw",
                overwrite: false,
            });


            const newDocument = new Document({
                groupId,
                title,
                description,
                uploaderId,
                imgDocument: imgUploadResult.secure_url,
                mainFile: fileUploadResult.secure_url,
            });
            const uploadDocument = await newDocument.save();
            res.json(uploadDocument);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi tải tài liệu mới"});
        }
    },
};

module.exports = documentController;