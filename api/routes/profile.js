const profileController = require('../controllers/profileController.js');
const express = require("express");
const router = express.Router();

router.get('/:id', profileController.getProfileById);
router.put('/:id', profileController.updateProfile);
router.get('/', profileController.getAllProflie);
router.delete('/:id', profileController.deleteProfile);
module.exports = router;