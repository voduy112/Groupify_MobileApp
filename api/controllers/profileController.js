const Profile = require("../models/User.js");
const cloudinary = require("../config/Cloudinary");

const profileController = {
    getAllProflie: async (req, res) => {
        try {
            const users = await Profile.find();
            res.json(users);
        } catch (error) {
            res.status(404).json({error: "Lỗi lấy thông tin người dùng"});
        }
    },

    getProfileById: async (req, res) => {
        try {
            //console.log(req.params);
            const user = await Profile.findById(req.params.id).select("-password");
            if (!user)
                return res.status(404).json({ error: "Không tìm thấy người dùng" });
            res.json(user);
        } catch (error) {
            res.status(500).json({ error: "Lỗi lấy thông tin người dùng" });
        }
    },

    updateProfile: async (req, res) => {
        try {
            let updateData = { ...req.body };
    
            // Nếu có ảnh được gửi kèm
            if (req.file) {
                const result = await cloudinary.uploader.upload(req.file.path, {
                    folder: "Groupify_MobileApp/avatar_profile",
                    public_id: `${req.params.id}_avatar`,  // Dùng params thay vì req.user
                    overwrite: true,
                });
    
                updateData.profilePicture = result.secure_url;
            }
    
            // Cập nhật người dùng theo id từ URL
            const updatedUser = await Profile.findByIdAndUpdate(
                req.params.id,
                updateData,
                { new: true }
            );
    
            res.json(updatedUser);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "Lỗi cập nhật thông tin người dùng" });
        }
    },

    deleteProfile: async (req, res) => {
        try {
            const deleteUser = await Profile.findById(req.params.id);
            if(!deleteUser) {
                return res.status(404).json({error: "Người dùng không tồn tại"});
            }

            const imageUrl = deleteUser.profilePicture;
            const publicId = imageUrl
            .split('/').slice(-3).join('/').replace(/\.(jpg|jpeg|png|webp)$/i, '')
            await cloudinary.uploader.destroy(publicId);
            await Profile.findByIdAndDelete(deleteUser.id);
            res.json({message: "Xóa người dùng thành công"});
        } catch (error){
            res.status(500).json({ error: "Lỗi xóa người dùng"});
        }
    },
};

module.exports = profileController;
