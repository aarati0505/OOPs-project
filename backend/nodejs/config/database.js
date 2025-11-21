const mongoose = require('mongoose');

/**
 * Database connection configuration
 * MongoDB + Mongoose
 */

const connect = async () => {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/ecommerce_db';
    
    const options = {
      // Remove deprecated options - use defaults
    };

    await mongoose.connect(mongoUri, options);
    
    console.log('MongoDB connected successfully');
    console.log(`Database: ${mongoose.connection.name}`);
    
    // Handle connection events
    mongoose.connection.on('error', (err) => {
      console.error('MongoDB connection error:', err);
    });

    mongoose.connection.on('disconnected', () => {
      console.log('MongoDB disconnected');
    });

    return mongoose.connection;
  } catch (error) {
    console.error('Failed to connect to MongoDB:', error);
    throw error;
  }
};

const disconnect = async () => {
  try {
    await mongoose.connection.close();
    console.log('MongoDB connection closed');
  } catch (error) {
    console.error('Error closing MongoDB connection:', error);
    throw error;
  }
};

module.exports = {
  connect,
  disconnect,
};
