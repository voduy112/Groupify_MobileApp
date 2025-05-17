
const admin = require('firebase-admin');
const serviceAccount = require('./firebase-service-account.json'); // đường dẫn tới file bạn vừa tải

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

module.exports = admin;
