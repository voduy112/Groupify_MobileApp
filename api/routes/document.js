const documentController = require('../controllers/documentController.js');
const express = require("express");
const router = express.Router();
const {upload, uploadImageAndFile} = require('../config/Multer.js');

router.get('/:id', documentController.getDocumentById);
router.put('/:id',
    uploadImageAndFile,
    documentController.updateDocument);

router.get('/', documentController.getAllDocument);

router.delete('/:id', documentController.deleteDocument);

router.post('/',
    uploadImageAndFile,
    documentController.uploadDocument);
module.exports = router;