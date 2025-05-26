const groupController = require("../controllers/groupController.js");
const express = require("express");
const router = express.Router();

const { upload } = require("../config/Multer");

router.get("/:id", groupController.getGroupById);
router.get("/", groupController.getAllGroup);
router.delete("/:id", groupController.deleteGroup);
router.post("/", groupController.createGroup);
router.post("/join", groupController.joinGroupByCode);
router.get("/user/:id", groupController.getAllGroupByUserId);

router.get('/:id', groupController.getGroupById);
router.get('/', groupController.getAllGroup);
router.delete('/:id', groupController.deleteGroup);
router.post('/', groupController.createGroup);
router.post('/join', groupController.joinGroupByCode);
router.get('/user/:id',groupController.getAllGroupByUserId);


router.put('/:id',
    upload.single('image'),
    groupController.updateGroup
)
router.post('/leave', groupController.leaveGroup);
router.get('/members/:id', groupController.getGroupMembers); //id la id cua group

module.exports = router;



