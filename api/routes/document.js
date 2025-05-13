const documentController = require('../controllers/documentController.js');
const express = require("express");
const router = express.Router();

router.get('/:id', documentController.getDocumentById);
router.put('/:id', documentController.updateDocument);
router.get('/', documentController.getAllDocument);
router.delete('/:id', documentController.deleteDocument);
router.post('/', documentController.uploadDocument);
module.exports = router;