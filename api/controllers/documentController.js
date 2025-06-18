const cloudinary = require("../config/Cloudinary");
const Document = require("../models/Document");
const User = require("../models/User");

function removeVietnameseTones(str) {
  return str
    .normalize("NFD")
    .replace(/[\u0300-\u036f]/g, "")
    .replace(/đ/g, "d")
    .replace(/Đ/g, "D");
}

const documentController = {
  searchDocument: async (req, res) => {
    const { query } = req.query;
    try {
      const documents = await Document.find({
        title: { $regex: query, $options: "i" },
      });

      if (documents.length > 0) {
        return res.json(documents);
      }

      const allDocs = await Document.find({});
      const queryNoAccent = removeVietnameseTones(query).toLowerCase();
      const filtered = allDocs.filter((doc) =>
        removeVietnameseTones(doc.title).toLowerCase().includes(queryNoAccent)
      );

      res.json(filtered);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi tìm kiếm tài liệu" });
    }
  },
  getAllDocument: async (req, res) => {
    try {
      const page = parseInt(req.query.page) || 1;
      const limit = parseInt(req.query.limit) || 10;
      const skip = (page - 1) * limit;

      const totalDocuments = await Document.countDocuments();
      const documents = await Document.find()
        .skip(skip)
        .limit(limit)
        .sort({ createdAt: -1 });

      res.json({
        totalDocuments,
        totalPages: Math.ceil(totalDocuments / limit),
        currentPage: page,
        documents,
      });
    } catch (error) {
      res.status(404).json({ error: "Lỗi lấy thông tin tài liệu" });
    }
  },
  getDocumentById: async (req, res) => {
    try {
      const document = await Document.findById(req.params.id);
      if (!document)
        return res.status(404).json({ error: "Không tìm thấy tài liệu" });
      res.json(document);
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi lấy thông tin tài liệu" });
    }
  },

  getDocumentsByUserId: async (req, res) => {
    const userId = req.params.id || req.query.id;

    if (!userId) {
      return res.status(400).json({ error: "Thiếu userId" });
    }

    try {
      const documents = await Document.find({
        uploaderId: userId,
        groupId: { $exists: false },
      });

      return res.json(documents);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi khi lấy tài liệu theo userId" });
    }
  },

  getDocumentsByGroupId: async (req, res) => {
    const groupId = req.params.id || req.query.id;

    if (!groupId) {
      return res.status(400).json({ error: "Thiếu groupId" });
    }

    try {
      const groups = await Document.find({
        $or: [{ groupId: groupId }],
      });

      return res.json(groups);
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi khi lấy nhóm theo userId" });
    }
  },

  deleteDocument: async (req, res) => {
    try {
      const deleteDocument = await Document.findById(req.params.id);
      if (!deleteDocument) {
        return res.status(404).json({ error: "Nhóm không tồn tại" });
      }
      const imageUrl = deleteDocument.imgDocument;
      const fileUrl = deleteDocument.mainFile;
      const filePublicId = fileUrl
        .split("/")
        .slice(-3)
        .join("/")
        .replace(/\.(pdf)$/i, "");
      console.log(filePublicId);
      await cloudinary.uploader.destroy(filePublicId, { resource_type: "raw" });
      const imgPublicId = imageUrl
        .split("/")
        .slice(-3)
        .join("/")
        .replace(/\.(jpg|jpeg|png|webp)$/i, "");
      await cloudinary.uploader.destroy(imgPublicId);

      await Document.findByIdAndDelete(deleteDocument.id);
      res.status(200).json({ message: "Xóa tài liệu thành công" });
    } catch (error) {
      res.status(500).json({ error: "Lỗi khi xóa tài liệu" });
    }
  },
  updateDocument: async (req, res) => {
    try {
      const existingDocument = await Document.findById(req.params.id);
      if (!existingDocument) {
        return res.status(404).json({ error: "Tài liệu không tồn tại" });
      }

      if (existingDocument) {
        const resultimg = await cloudinary.api.resources({
          type: "upload",
          prefix: existingDocument.imgDocument,
          max_results: 1,
        });

        if (resultimg.resources.length > 0) {
          const publicId = resultimg.resources[0].public_id;
          await cloudinary.uploader.destroy(publicId);
        }
        const resultfile = await cloudinary.api.resources({
          type: "upload",
          prefix: existingDocument.mainFile,
          max_result: 1,
        });
        if (resultfile.resources.length > 0) {
          const filepublicId = resultfile.resources[0].public_id;
          await cloudinary.uploader.destroy(filepublicId);
        }
      }
      const times = Date.now();
      let updateData = { ...req.body };
      if (req.files && req.files.image && req.files.image[0]) {
        const uploadResult = await cloudinary.uploader.upload(
          req.files.image[0].path,
          {
            folder: "Groupify_MobileApp/img_document",
            public_id: `${existingDocument.id}_${times}_imgdocument`,
            overwrite: false,
          }
        );
        updateData.imgDocument = uploadResult.secure_url;
      }

      if (req.files && req.files.mainFile && req.files.mainFile[0]) {
        const uploadResult = await cloudinary.uploader.upload(
          req.files.mainFile[0].path,
          {
            folder: "Groupify_MobileApp/file_document",
            public_id: `${existingDocument.id}_${times}_filedocument`,
            resource_type: "raw", // rất quan trọng nếu là PDF
            overwrite: false,
          }
        );
        updateData.mainFile = uploadResult.secure_url;
      }

      const updateDocument = await Document.findByIdAndUpdate(
        req.params.id,
        updateData,
        { new: true }
      );
      res.json(updateDocument);
    } catch (error) {
      console.log(error);
      res.status(500).json({ error: "Lỗi cập nhật thông tin tài liệu" });
    }
  },
  uploadDocument: async (req, res) => {
    try {
      const { groupId, title, description, uploaderId } = req.body;
      if (!title || !description || !uploaderId) {
        return res.status(400).json({ error: "Thiếu thông tin tài liệu" });
      }
      if (!req.files || !req.files.mainFile) {
        return res.status(400).json({ error: "Chưa upload file tài liệu" });
      }

      const times = Date.now();

      const imgUploadResult = await cloudinary.uploader.upload(
        req.files.image[0].path,
        {
          folder: "Groupify_MobileApp/img_document",
          public_id: `${uploaderId}_${times}_imgdocument`,
          overwrite: false,
        }
      );

      const fileUploadResult = await cloudinary.uploader.upload(
        req.files.mainFile[0].path,
        {
          folder: "Groupify_MobileApp/file_document",
          public_id: `${uploaderId}_${times}_filedocument`,
          resource_type: "raw",
          overwrite: false,
        }
      );

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
      res.status(500).json({ error: "Lỗi khi tải tài liệu mới" });
    }
  },

  deleteDocumentsByGroupId: async (req, res) => {
    const groupId = req.params.id || req.query.id;

    if (!groupId) {
      return res.status(400).json({ error: "Thiếu groupId" });
    }

    try {
      const documents = await Document.find({ groupId });

      if (documents.length === 0) {
        return res
          .status(404)
          .json({ error: "Không tìm thấy tài liệu thuộc groupId này" });
      }

      for (const doc of documents) {
        // Xử lý xóa file chính
        if (doc.mainFile) {
          const filePublicId = doc.mainFile
            .split("/")
            .slice(-3)
            .join("/")
            .replace(/\.(pdf)$/i, "");
          await cloudinary.uploader.destroy(filePublicId, {
            resource_type: "raw",
          });
        }

        // Xử lý xóa ảnh
        if (doc.imgDocument) {
          const imgPublicId = doc.imgDocument
            .split("/")
            .slice(-3)
            .join("/")
            .replace(/\.(jpg|jpeg|png|webp)$/i, "");
          await cloudinary.uploader.destroy(imgPublicId);
        }

        // Xóa tài liệu khỏi MongoDB
        await Document.findByIdAndDelete(doc._id);
      }

      return res
        .status(200)
        .json({ message: "Đã xóa tất cả tài liệu thuộc groupId thành công" });
    } catch (error) {
      console.error(error);
      return res
        .status(500)
        .json({ error: "Lỗi khi xóa tài liệu theo groupId" });
    }
  },

  rateDocument: async (req, res) => {
    const { userId, ratingValue } = req.body;
    const documentId = req.params.id;

    if (!userId || !ratingValue) {
      return res.status(400).json({ error: "Thiếu thông tin đánh giá" });
    }
    try {
      const document = await Document.findById(documentId);
      if (!document) {
        return res.status(404).json({ error: "Không tìm thấy tài liệu" });
      }

      const existingRatingIndex = document.ratings.findIndex(
        (r) => r.userId.toString() === userId
      );

      if (existingRatingIndex !== -1) {
        document.ratings[existingRatingIndex].value = ratingValue;
      } else {
        document.ratings.push({ userId, value: ratingValue });
      }

      await document.save();
      res.json({ message: "Đánh giá thành công", document });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi khi đánh giá tài liệu" });
    }
  },

  getDocumentRating: async (req, res) => {
    const documentId = req.params.id;

    try {
      const document = await Document.findById(documentId);
      if (!document) {
        return res.status(404).json({ error: "Không tìm thấy tài liệu" });
      }

      const ratings = document.ratings || [];

      const totalRating = ratings.reduce((sum, r) => sum + r.value, 0);
      const averageRating =
        ratings.length > 0 ? totalRating / ratings.length : 0;

      res.json({
        averageRating: averageRating.toFixed(1),
        totalRatings: ratings.length,
        ratings,
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi khi lấy thông tin đánh giá" });
    }
  },

  addComment: async (req, res) => {
    const documentId = req.params.id;
    const { userId, content } = req.body;

    if (!userId || !content) {
      return res.status(400).json({ error: "Thiếu thông tin bình luận" });
    }

    try {
      const document = await Document.findById(documentId);
      if (!document) {
        return res.status(404).json({ error: "Không tìm thấy tài liệu" });
      }

      const user = await User.findById(userId);
      if (!user) {
        return res.status(404).json({ error: "Không tìm thấy người dùng" });
      }

      const comment = {
        userId,
        username: user.username || "Ẩn danh",
        avatar: user.profilePicture || "",
        content,
        createdAt: new Date(),
      };

      document.comments.push(comment);
      await document.save();

      res.status(201).json({ message: "Bình luận thành công", comment });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi khi gửi bình luận" });
    }
  },

  /*getComments: async (req, res) => {
    const documentId = req.params.id;
  
    try {
      const document = await Document.findById(documentId);
      if (!document) {
        return res.status(404).json({ error: 'Không tìm thấy tài liệu' });
      }
  
      const comments = await Promise.all(
        (document.comments || []).map(async (cmt) => {
          if (cmt.username && cmt.avatar) return cmt;
  
          const user = await User.findById(cmt.userId);
          return {
            ...cmt._doc, 
            username: user?.username || 'Ẩn danh',
            avatar: user?.profilePicture || '',
          };
        })
      );
  
      res.json({ comments });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: 'Lỗi khi lấy bình luận' });
    }
  } */

  getComments: async (req, res) => {
    const documentId = req.params.id;
    const limit = parseInt(req.query.limit) || 10;
    const skip = parseInt(req.query.skip) || 0;

    try {
      const document = await Document.findById(documentId).select("comments");
      if (!document) {
        return res.status(404).json({ error: "Không tìm thấy tài liệu" });
      }

      const totalComments = document.comments.length;

      // Lấy bình luận mới nhất trước
      const paginatedComments = document.comments
        .slice()
        .reverse()
        .slice(skip, skip + limit);

      // Bổ sung avatar và username nếu thiếu
      const enrichedComments = await Promise.all(
        paginatedComments.map(async (cmt) => {
          if (cmt.username && cmt.avatar) return cmt;

          try {
            const user = await User.findById(cmt.userId);
            return {
              ...cmt._doc, // nếu cmt là một document
              username: user?.username || "Ẩn danh",
              avatar: user?.profilePicture || "",
            };
          } catch {
            return {
              ...cmt._doc,
              username: "Ẩn danh",
              avatar: "",
            };
          }
        })
      );

      res.json({
        comments: enrichedComments,
        total: totalComments,
        hasMore: skip + limit < totalComments,
      });
    } catch (error) {
      console.error(error);
      res.status(500).json({ error: "Lỗi khi lấy bình luận" });
    }
  },

  deleteComment: async (req, res) => {
    const { documentId, commentId } = req.params;
    const userId = req.body.userId;

    if (!userId) {
      return res.status(400).json({ error: "Thiếu userId" });
    }

    try {
      const document = await Document.findById(documentId);
      if (!document) {
        return res.status(404).json({ error: "Không tìm thấy tài liệu" });
      }

      const comment = document.comments.find(
        (c) => c._id.toString() === commentId
      );

      if (!comment) {
        return res.status(404).json({ error: "Không tìm thấy bình luận" });
      }

      if (comment.userId.toString() !== userId) {
        return res
          .status(403)
          .json({ error: "Bạn không có quyền xóa bình luận này" });
      }

      // Xoá comment bằng filter
      document.comments = document.comments.filter(
        (c) => c._id.toString() !== commentId
      );

      await document.save();

      res.json({ message: "Xóa bình luận thành công" });
    } catch (error) {
      console.error("Lỗi backend:", error);
      res.status(500).json({ error: error.message || "Lỗi khi xóa bình luận" });
    }
  },
};

module.exports = documentController;
