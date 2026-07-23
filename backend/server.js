require('dotenv').config();

const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');

// Load Mongoose Models
require('./models/User');
require('./models/Task');

const app = express();

// Body Parser Middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// CORS Configuration
// Allows local development and deployed Netlify frontend
app.use(
  cors({
    origin: (origin, callback) => {
      // Allow requests with no origin
      // Examples: Android app, Postman, curl
      if (!origin) {
        return callback(null, true);
      }

      // Production frontend
      const allowedProductionOrigins = [
        'https://tasksphere-manager.netlify.app',
      ];

      // Local development
      const isLocalDevelopment =
        origin.startsWith('http://localhost') ||
        origin.startsWith('http://127.0.0.1') ||
        origin.startsWith('http://10.0.2.2');

      const isProductionFrontend =
        allowedProductionOrigins.includes(origin);

      if (isLocalDevelopment || isProductionFrontend) {
        return callback(null, true);
      }

      return callback(
        new Error('CORS policy check failed: Origin not allowed.')
      );
    },

    credentials: true,
  })
);

// Diagnostic Endpoint 1: Base API Status
app.get('/', (req, res) => {
  res.json({
    message: 'Task Management API is running',
  });
});

// Diagnostic Endpoint 2: Health Check
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'Task Management API is healthy',
  });
});

// Authentication Routes
const authRoutes = require('./routes/authRoutes');
app.use('/api/auth', authRoutes);

// Task Routes
const taskRoutes = require('./routes/taskRoutes');
app.use('/api/tasks', taskRoutes);

// Port declaration
const PORT = process.env.PORT || 5000;

// Connect to Database and start listening
const startServer = async () => {
  await connectDB();

  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
};

startServer();