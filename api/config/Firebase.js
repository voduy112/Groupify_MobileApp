const admin = require("firebase-admin");
const serviceAccount = require("./firebase-service-account.json"); // đường dẫn tới file bạn vừa tải

serviceAccount.private_key = serviceAccount.private_key.replace(/\\n/g, "\n");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
