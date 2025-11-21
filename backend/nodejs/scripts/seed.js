require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

// Import models
const User = require('../models/User');
const Product = require('../models/Product');
const Category = require('../models/Category');

// Connect to database
const connectDB = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ MongoDB connected for seeding');
  } catch (error) {
    console.error('❌ MongoDB connection error:', error);
    process.exit(1);
  }
};

// Sample data
const categories = [
  { name: 'Fruits & Vegetables', slug: 'fruits-vegetables', description: 'Fresh fruits and vegetables', imageUrl: '🥬' },
  { name: 'Dairy & Eggs', slug: 'dairy-eggs', description: 'Milk, cheese, eggs, and dairy products', imageUrl: '🥛' },
  { name: 'Bakery', slug: 'bakery', description: 'Bread, cakes, and baked goods', imageUrl: '🍞' },
  { name: 'Meat & Seafood', slug: 'meat-seafood', description: 'Fresh meat and seafood', imageUrl: '🍖' },
  { name: 'Beverages', slug: 'beverages', description: 'Drinks and beverages', imageUrl: '🥤' },
  { name: 'Snacks', slug: 'snacks', description: 'Chips, cookies, and snacks', imageUrl: '🍿' },
  { name: 'Pantry', slug: 'pantry', description: 'Rice, flour, oil, and staples', imageUrl: '🌾' },
  { name: 'Personal Care', slug: 'personal-care', description: 'Toiletries and personal care', imageUrl: '🧴' },
];

const users = [
  {
    name: 'John Customer',
    email: 'customer@test.com',
    phone: '+1234567890',
    password: 'password123',
    role: 'customer',
    isEmailVerified: true,
    isPhoneVerified: true,
  },
  {
    name: 'Sarah Retailer',
    email: 'retailer@test.com',
    phone: '+1234567891',
    password: 'password123',
    role: 'retailer',
    businessName: 'Sarah\'s Grocery Store',
    businessAddress: '123 Main Street, City, State 12345',
    location: {
      city: 'New York',
      region: 'NY',
      lat: 40.730610,
      lng: -73.935242,
    },
    isEmailVerified: true,
    isPhoneVerified: true,
  },
  {
    name: 'Mike Wholesaler',
    email: 'wholesaler@test.com',
    phone: '+1234567892',
    password: 'password123',
    role: 'wholesaler',
    businessName: 'Mike\'s Wholesale Supplies',
    businessAddress: '456 Warehouse Ave, City, State 12345',
    location: {
      city: 'New York',
      region: 'NY',
      lat: 40.740610,
      lng: -73.945242,
    },
    isEmailVerified: true,
    isPhoneVerified: true,
  },
  {
    name: 'Emma Retailer',
    email: 'retailer2@test.com',
    phone: '+1234567893',
    password: 'password123',
    role: 'retailer',
    businessName: 'Emma\'s Fresh Market',
    businessAddress: '789 Market St, City, State 12345',
    location: {
      city: 'New York',
      region: 'NY',
      lat: 40.720610,
      lng: -73.925242,
    },
    isEmailVerified: true,
    isPhoneVerified: true,
  },
];

const products = [
  // Fruits & Vegetables
  { name: 'Fresh Apples', description: 'Crisp and sweet red apples', price: 3.99, unit: 'kg', category: 'Fruits & Vegetables' },
  { name: 'Organic Bananas', description: 'Fresh organic bananas', price: 2.49, unit: 'kg', category: 'Fruits & Vegetables' },
  { name: 'Tomatoes', description: 'Ripe red tomatoes', price: 2.99, unit: 'kg', category: 'Fruits & Vegetables' },
  { name: 'Potatoes', description: 'Fresh potatoes', price: 1.99, unit: 'kg', category: 'Fruits & Vegetables' },
  { name: 'Onions', description: 'Yellow onions', price: 1.49, unit: 'kg', category: 'Fruits & Vegetables' },
  
  // Dairy & Eggs
  { name: 'Whole Milk', description: 'Fresh whole milk', price: 4.99, unit: 'liter', category: 'Dairy & Eggs' },
  { name: 'Eggs (Dozen)', description: 'Farm fresh eggs', price: 5.99, unit: 'dozen', category: 'Dairy & Eggs' },
  { name: 'Cheddar Cheese', description: 'Sharp cheddar cheese', price: 7.99, unit: 'kg', category: 'Dairy & Eggs' },
  { name: 'Greek Yogurt', description: 'Plain Greek yogurt', price: 3.99, unit: 'kg', category: 'Dairy & Eggs' },
  
  // Bakery
  { name: 'White Bread', description: 'Fresh white bread loaf', price: 2.99, unit: 'piece', category: 'Bakery' },
  { name: 'Whole Wheat Bread', description: 'Healthy whole wheat bread', price: 3.49, unit: 'piece', category: 'Bakery' },
  { name: 'Croissants', description: 'Buttery croissants', price: 4.99, unit: 'pack', category: 'Bakery' },
  
  // Meat & Seafood
  { name: 'Chicken Breast', description: 'Boneless chicken breast', price: 9.99, unit: 'kg', category: 'Meat & Seafood' },
  { name: 'Ground Beef', description: 'Lean ground beef', price: 12.99, unit: 'kg', category: 'Meat & Seafood' },
  { name: 'Salmon Fillet', description: 'Fresh salmon fillet', price: 19.99, unit: 'kg', category: 'Meat & Seafood' },
  
  // Beverages
  { name: 'Orange Juice', description: 'Fresh orange juice', price: 5.99, unit: 'liter', category: 'Beverages' },
  { name: 'Coca Cola', description: 'Coca Cola soft drink', price: 2.99, unit: 'liter', category: 'Beverages' },
  { name: 'Mineral Water', description: 'Pure mineral water', price: 1.99, unit: 'liter', category: 'Beverages' },
  
  // Snacks
  { name: 'Potato Chips', description: 'Crispy potato chips', price: 3.99, unit: 'pack', category: 'Snacks' },
  { name: 'Chocolate Cookies', description: 'Delicious chocolate cookies', price: 4.49, unit: 'pack', category: 'Snacks' },
  
  // Pantry
  { name: 'Basmati Rice', description: 'Premium basmati rice', price: 8.99, unit: 'kg', category: 'Pantry' },
  { name: 'All Purpose Flour', description: 'White all purpose flour', price: 3.99, unit: 'kg', category: 'Pantry' },
  { name: 'Olive Oil', description: 'Extra virgin olive oil', price: 12.99, unit: 'liter', category: 'Pantry' },
  { name: 'Sugar', description: 'White granulated sugar', price: 2.99, unit: 'kg', category: 'Pantry' },
  
  // Personal Care
  { name: 'Shampoo', description: 'Hair shampoo', price: 6.99, unit: 'bottle', category: 'Personal Care' },
  { name: 'Toothpaste', description: 'Mint toothpaste', price: 3.99, unit: 'tube', category: 'Personal Care' },
];

// Seed function
async function seed() {
  try {
    console.log('🌱 Starting database seeding...\n');

    // Clear existing data
    console.log('🗑️  Clearing existing data...');
    await User.deleteMany({});
    await Product.deleteMany({});
    await Category.deleteMany({});
    console.log('✅ Existing data cleared\n');

    // Create categories
    console.log('📁 Creating categories...');
    const createdCategories = await Category.insertMany(categories);
    console.log(`✅ Created ${createdCategories.length} categories\n`);

    // Create users with hashed passwords
    console.log('👥 Creating users...');
    const hashedUsers = await Promise.all(
      users.map(async (user) => ({
        ...user,
        passwordHash: await bcrypt.hash(user.password, 10),
      }))
    );
    const createdUsers = await User.insertMany(hashedUsers);
    console.log(`✅ Created ${createdUsers.length} users:`);
    createdUsers.forEach(user => {
      console.log(`   - ${user.name} (${user.role}) - ${user.email}`);
    });
    console.log();

    // Get retailer and wholesaler IDs
    const retailer = createdUsers.find(u => u.email === 'retailer@test.com');
    const wholesaler = createdUsers.find(u => u.email === 'wholesaler@test.com');
    const retailer2 = createdUsers.find(u => u.email === 'retailer2@test.com');

    // Create products
    console.log('📦 Creating products...');
    const productsWithOwners = products.map((product, index) => {
      // Assign products to wholesaler and retailers
      const owner = index % 3 === 0 ? wholesaler : (index % 3 === 1 ? retailer : retailer2);
      const categoryDoc = createdCategories.find(c => c.name === product.category);
      
      return {
        name: product.name,
        description: product.description,
        price: product.price,
        stock: Math.floor(Math.random() * 500) + 100, // Random stock between 100-600
        categoryId: categoryDoc._id,
        retailerId: owner.role === 'retailer' ? owner._id : null,
        wholesalerId: owner.role === 'wholesaler' ? owner._id : null,
        weight: product.unit,
        region: owner.location?.region || 'NY',
        images: [`https://via.placeholder.com/400x400?text=${encodeURIComponent(product.name)}`],
        isActive: true,
        sourceType: owner.role,
      };
    });
    
    const createdProducts = await Product.insertMany(productsWithOwners);
    console.log(`✅ Created ${createdProducts.length} products\n`);

    // Summary
    console.log('═══════════════════════════════════════');
    console.log('🎉 Database seeding completed!');
    console.log('═══════════════════════════════════════');
    console.log(`📁 Categories: ${createdCategories.length}`);
    console.log(`👥 Users: ${createdUsers.length}`);
    console.log(`   - Customers: ${createdUsers.filter(u => u.role === 'customer').length}`);
    console.log(`   - Retailers: ${createdUsers.filter(u => u.role === 'retailer').length}`);
    console.log(`   - Wholesalers: ${createdUsers.filter(u => u.role === 'wholesaler').length}`);
    console.log(`📦 Products: ${createdProducts.length}`);
    console.log('═══════════════════════════════════════\n');

    console.log('🔐 Test Credentials:');
    console.log('   Customer:   customer@test.com / password123');
    console.log('   Retailer:   retailer@test.com / password123');
    console.log('   Wholesaler: wholesaler@test.com / password123');
    console.log('   Retailer 2: retailer2@test.com / password123\n');

  } catch (error) {
    console.error('❌ Seeding error:', error);
  } finally {
    await mongoose.connection.close();
    console.log('👋 Database connection closed');
    process.exit(0);
  }
}

// Run seeding
connectDB().then(seed);
