const jwt = require("jsonwebtoken");

const authMiddleware = {
  verifyToken: (req, res, next) => {
    const authHeader = req.headers.authorization;
    if (authHeader) {
      const token = authHeader.split(" ")[1]; // Bearer token
      jwt.verify(token, process.env.ACCESS_TOKEN_SECRET, (err, user) => {
        if (err) {
          return res.status(403).json({ message: "Token is not valid!" });
        }
        req.user = user;
        next();
      });
    } else {
      return res.status(401).json({ message: "You are not authenticated!" });
    }
  },
};

module.exports = authMiddleware;
