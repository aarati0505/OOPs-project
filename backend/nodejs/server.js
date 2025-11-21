require('dotenv').config();
const app = require('./app');
const { connect: connectDatabase } = require('./config/database');
const { initializeFirebase } = require('./services/firebase.service');

const PORT = process.env.PORT || 3000;

// Start server
async function startServer() {
  try {
    // Connect to database
    await connectDatabase();
    
    // Initialize Firebase (optional - will work without it)
    initializeFirebase();

    // Start listening
    app.listen(PORT, () => {
      console.log('\n=================================================');
      console.log('🚀 Backend Server Started Successfully!');
      console.log('=================================================');
      console.log(`📡 Port: ${PORT}`);
      console.log(`🌍 Environment: ${process.env.NODE_ENV || 'development'}`);
      console.log(`🗄️  Database: Connected to MongoDB`);
      console.log(`\n🔗 API Endpoints:`);
      console.log(`   Health Check: http://localhost:${PORT}/health`);
      console.log(`   API Base URL: http://localhost:${PORT}/v1`);
      console.log(`\n📚 Available Routes:`);
      console.log(`   /v1/auth        - Authentication`);
      console.log(`   /v1/users       - User management`);
      console.log(`   /v1/products    - Product catalog`);
      console.log(`   /v1/orders      - Order management`);
      console.log(`   /v1/cart        - Shopping cart`);
      console.log(`   /v1/inventory   - Inventory management`);
      console.log(`   /v1/categories  - Categories`);
      console.log(`   /v1/reviews     - Product reviews`);
      console.log(`   /v1/location    - Location services`);
      console.log(`   /v1/notifications - Notifications`);
      console.log(`   /v1/retailers   - Retailer operations`);
      console.log(`   /v1/wholesalers - Wholesaler operations`);
      console.log('=================================================\n');
    });
  } catch (error) {
    console.error('Failed to start server:', error);
    process.exit(1);
  }
}

// Handle graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  process.exit(0);
});

startServer();
