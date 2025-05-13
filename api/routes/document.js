const documentController = require('../controllers/documentController.js');
const express = require("express");
const router = express.Router();
const upload = require('../config/Multer.js');

router.get('/:id', documentController.getDocumentById);
router.put('/:id',
    upload.single('image'),
    documentController.updateDocument);

router.get('/', documentController.getAllDocument);

router.delete('/:id', documentController.deleteDocument);

router.post('/',
    upload.single('mainFile'),
    documentController.uploadDocument);
module.exports = router;