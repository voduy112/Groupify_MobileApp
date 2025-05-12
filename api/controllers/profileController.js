const Profile = require("../models/User.js");

const profileController = {
    getAllProflie : async (req, res) => {
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
            const updatedUser = await Profile.findByIdAndUpdate(
                req.params.id,
                req.body,
                { new: true }
            );
            res.json(updatedUser);
        } catch (error) {
            res.status(500).json({ error: "Lỗi cập nhật thông tin" });
        }
    },
    deleteProfile: async (req, res) => {
        try {
            const deleteUser = await Profile.findByIdAndDelete(req.params.id);
            if(!deleteUser) {
                return res.status(404).json({error: "Người dùng không tồn tại"});
            }
        } catch (error){
            res.status(500).json({ error: "Lỗi xóa người dùng"});
        }
    },
};

module.exports = profileController;
