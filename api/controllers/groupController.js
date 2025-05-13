const Group = require ("../models/Group");

const groupController = {
    createGroup : async (req, res) => {
        try {
            const { name, description, subject, ownerId, membersID, inviteCode} = req.body;
            if (!name || !description || !subject || !ownerId || !inviteCode) {
                return res.status(400).json({error: "Thiếu thông tin nhóm"});
            }
            const newGroup = new Group({
                name,
                description, 
                subject,
                ownerId,
                membersID,
                inviteCode,
            });
            const createGroup = await newGroup.save();
            res.json(createGroup);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi tạo nhóm mới"});
        }
    },
    getGroupById : async (req, res) => {
        try {
            const group = await Group.findById(req.params.id);
            if(!group) {
                return res.status(404).json({error: "Không tìm thấy nhóm"});
            }
            res.json(group);
        } catch (error) {
            res.status(500).json({error: "Lỗi khi lấy thông tin nhóm"});
        }
    },
    getAllGroup : async (req, res) => {
        try {
            const groups = await Group.find()
                .populate("membersID");
            return res.json(groups);
        } catch (error) {
            res.status(404).json({error: "Lỗi khi lấy thông tin nhóm"});
        }
    },
    deleteGroup : async (req, res) => {
        try {
            const deleteGroup = await Group.findByIdAndDelete(req.params.id);
            if(!deleteGroup) {
                return res.status(404).json({error: "Tài liệu không tồn tại"});
            }
            res.status(200).json({message: "Xóa nhóm thành công"});
        } catch (error) {
            res.status(500).json({error: "Lỗi khi xóa nhóm"});
        }
    },
    joinGroupByCode : async (req, res) => {
        try {
            const {inviteCode, userId} = req.body;
            const group = await Group.findOne({inviteCode});

            if(!group) {
                return res.status(404).json({error: "Không tìm thấy nhóm với mã này"});
            }

            if(group.membersID.includes(userId)){
                return res.status(400).json({error: "Người dùng đã tham gia nhóm này"});
            }
            group.membersID.push(userId);
            await group.save();
            res.json(group);
        } catch (error) {
            return res.status(500).json({error: "Lỗi khi tham gia nhóm"});
        }
    },
    leaveGroup : async (req, res) => {
        try {
            const { groupId, userId } = req.body;
            const group = await Group.findById(groupId);
            if(!group) {
                return res.status(404).json({error: "Không tìm thấy nhóm"});
            }
            if(!group.membersID.includes(userId)) {
                return res.status(400).json({ error: "Người dùng không phải là thành viên"});
            }
            group.membersID.pull(userId);
            await group.save();
            res.status(200).json({ messasge: "Rời nhóm thành công"});
        } catch (error) {
            res.status(500).json({ error: "Lỗi khi rời nhóm"});
        }
    },
    getGroupMembers: async (req, res) => {
        try {
            const group = await Group.findById(req.params.id).populate("membersID");
            if (!group) {
                return res.status(404).json({ error: "Không tìm thấy nhóm" });
            }
            res.json(group.membersID);
        } catch (error) {
            console.error(error);
            res.status(500).json({ error: "Lỗi khi lấy danh sách thành viên" });
        }
    }
    
};

module.exports = groupController;