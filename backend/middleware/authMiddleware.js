const jwt = require('jsonwebtoken');
const User = require('../models/User');

const protect = async (req, res, next) => {
  let token;

  // Check for Authorization header starting with Bearer
  if (
    req.headers.authorization &&
    req.headers.authorization.startsWith('Bearer')
  ) {
    try {
      // Extract token from Bearer <token>
      token = req.headers.authorization.split(' ')[1];

      if (!token) {
        return res.status(401).json({ message: 'Not authorized, no token provided' });
      }

      if (!process.env.JWT_SECRET) {
        console.error('FATAL: JWT_SECRET environment variable is missing.');
        return res.status(500).json({ message: 'Server configuration error' });
      }

      // Verify token signature and expiration
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Find user by decoded ID, excluding password hash
      req.user = await User.findById(decoded.id).select('-password');

      if (!req.user) {
        return res.status(401).json({ message: 'Not authorized, user no longer exists' });
      }

      return next();
    } catch (error) {
      console.error('Auth Middleware Error:', error.message);
      return res.status(401).json({ message: 'Not authorized, token failed' });
    }
  }

  if (!token) {
    return res.status(401).json({ message: 'Not authorized, no token provided' });
  }
};

module.exports = { protect };
