const jwt = require('jsonwebtoken');

const authMiddleware = {
  verifyToken: (req, res, next) => {
    const token = req.headers.token;

    if (token) {
      const accessToken = token.split(" ")[1];
      console.log("Access Token: ", accessToken);
      jwt.verify(accessToken, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
        if (err) {
          return res.status(403).json("Token is not valid!");
        }
        req.user = user; // gán user vào request
        // console.log("User: ", user);
        next();
      });
    } else {
      return res.status(401).json("You are not authenticated!");
    }
  }
};

module.exports = authMiddleware;
