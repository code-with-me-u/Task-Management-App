const jwt = require('jsonwebtoken');
const User = require('../models/User');

// Helper function to generate JWT token
const generateToken = (id) => {
  if (!process.env.JWT_SECRET) {
    throw new Error('FATAL: JWT_SECRET environment variable is missing.');
  }
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '7d',
  });
};

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public
const registerUser = async (req, res) => {
  try {
    const { name, email, password } = req.body;

    // Validate required fields
    if (!name || !email || !password) {
      return res.status(400).json({ message: 'Please provide all required fields' });
    }

    // Normalize email
    const normalizedEmail = email.toLowerCase().trim();

    // Check if user already exists
    const userExists = await User.findOne({ email: normalizedEmail });
    if (userExists) {
      return res.status(400).json({ message: 'User already exists' });
    }

    // Create user (Pre-save hook in User model automatically hashes the password)
    const user = await User.create({
      name: name.trim(),
      email: normalizedEmail,
      password,
    });

    if (user) {
      return res.status(201).json({
        token: generateToken(user._id),
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
        },
      });
    } else {
      return res.status(400).json({ message: 'Invalid user data received' });
    }
  } catch (error) {
    console.error('Register User Error:', error.message);
    return res.status(500).json({ message: 'Server error during registration' });
  }
};

// @desc    Authenticate user & get token
// @route   POST /api/auth/login
// @access  Public
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    // Validate required fields
    if (!email || !password) {
      return res.status(400).json({ message: 'Please provide email and password' });
    }

    // Normalize email
    const normalizedEmail = email.toLowerCase().trim();

    // Find user by normalized email
    const user = await User.findOne({ email: normalizedEmail });

    // Compare entered password with stored bcrypt hash
    if (user && (await user.matchPassword(password))) {
      return res.status(200).json({
        token: generateToken(user._id),
        user: {
          _id: user._id,
          name: user.name,
          email: user.email,
        },
      });
    } else {
      // Generic authentication error to prevent email enumeration
      return res.status(401).json({ message: 'Invalid credentials' });
    }
  } catch (error) {
    console.error('Login User Error:', error.message);
    return res.status(500).json({ message: 'Server error during login' });
  }
};

// @desc    Get current user profile
// @route   GET /api/auth/me
// @access  Private (Protected by protect middleware)
const getMe = async (req, res) => {
  try {
    if (!req.user) {
      return res.status(401).json({ message: 'Not authorized, user profile unavailable' });
    }

    return res.status(200).json({
      _id: req.user._id,
      name: req.user.name,
      email: req.user.email,
      createdAt: req.user.createdAt,
    });
  } catch (error) {
    console.error('Get Me Error:', error.message);
    return res.status(500).json({ message: 'Server error retrieving user profile' });
  }
};

module.exports = {
  registerUser,
  loginUser,
  getMe,
};
