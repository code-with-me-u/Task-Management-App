const dns = require('node:dns');
const mongoose = require('mongoose');

dns.setServers(['8.8.8.8', '8.8.4.4']);

const connectDB = async () => {
  try {
    const mongoURI = process.env.MONGODB_URI;

    // Check if MONGODB_URI exists or is still the initial placeholder
    if (!mongoURI || mongoURI === 'PASTE_YOUR_MONGODB_ATLAS_CONNECTION_STRING_HERE') {
      console.error('Error: MONGODB_URI is missing or contains the default placeholder in your .env file.');
      console.error('Please configure a valid MongoDB Atlas connection string in .env before starting the server.');
      process.exit(1);
    }

    // Attempt Mongoose connection
    await mongoose.connect(mongoURI);

    console.log('MongoDB connected successfully.');
  } catch (error) {
    // Log failure message safely without printing URI or secret credentials
    console.error('Error connecting to MongoDB database.');
    console.error(`Details: ${error.message}`);
    process.exit(1);
  }
};

module.exports = connectDB;
