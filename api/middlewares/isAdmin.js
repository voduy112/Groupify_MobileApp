module.exports = function (req, res, next) {
  req.user = { role: 'admin' }; 
  next();
};

