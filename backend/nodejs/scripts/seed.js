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
    name: 'Raj Kumar',
    email: 'customer@test.com',
    phone: '+919876543210',
    password: 'password123',
    role: 'customer',
    isEmailVerified: true,
    isPhoneVerified: true,
  },
  {
    name: 'Priya Sharma',
    email: 'retailer@test.com',
    phone: '+919876543211',
    password: 'password123',
    role: 'retailer',
    businessName: 'Priya\'s Grocery Store',
    businessAddress: 'Shop 12, MG Road, Mumbai, Maharashtra 400001',
    location: {
      city: 'Mumbai',
      region: 'Maharashtra',
      lat: 19.075984,
      lng: 72.877656,
    },
    isEmailVerified: true,
    isPhoneVerified: true,
  },
  {
    name: 'Amit Patel',
    email: 'wholesaler@test.com',
    phone: '+919876543212',
    password: 'password123',
    role: 'wholesaler',
    businessName: 'Amit Wholesale Supplies',
    businessAddress: 'Warehouse 5, APMC Market, Vashi, Navi Mumbai 400703',
    location: {
      city: 'Navi Mumbai',
      region: 'Maharashtra',
      lat: 19.066330,
      lng: 73.013901,
    },
    isEmailVerified: true,
    isPhoneVerified: true,
  },
  {
    name: 'Sneha Reddy',
    email: 'retailer2@test.com',
    phone: '+919876543213',
    password: 'password123',
    role: 'retailer',
    businessName: 'Sneha\'s Fresh Market',
    businessAddress: 'Plot 45, Bandra West, Mumbai, Maharashtra 400050',
    location: {
      city: 'Mumbai',
      region: 'Maharashtra',
      lat: 19.059984,
      lng: 72.829544,
    },
    isEmailVerified: true,
    isPhoneVerified: true,
  },
];

const products = [
  // Fruits & Vegetables
  { name: 'Fresh Apples', description: 'Crisp and sweet red apples', price: 120, unit: 'kg', category: 'Fruits & Vegetables', image: 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400' },
  { name: 'Organic Bananas', description: 'Fresh organic bananas', price: 60, unit: 'kg', category: 'Fruits & Vegetables', image: 'https://images.unsplash.com/photo-1603833665858-e61d17a86224?w=400' },
  { name: 'Tomatoes', description: 'Ripe red tomatoes', price: 40, unit: 'kg', category: 'Fruits & Vegetables', image: 'https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400' },
  { name: 'Potatoes', description: 'Fresh potatoes', price: 30, unit: 'kg', category: 'Fruits & Vegetables', image: 'https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400' },
  { name: 'Onions', description: 'Yellow onions', price: 35, unit: 'kg', category: 'Fruits & Vegetables', image: 'https://images.unsplash.com/photo-1508747703725-719777637510?w=400' },
  
  // Dairy & Eggs
  { name: 'Whole Milk', description: 'Fresh whole milk', price: 60, unit: 'liter', category: 'Dairy & Eggs', image: 'https://images.unsplash.com/photo-1563636619-e9143da7973b?w=400' },
  { name: 'Eggs (Dozen)', description: 'Farm fresh eggs', price: 80, unit: 'dozen', category: 'Dairy & Eggs', image: 'https://images.unsplash.com/photo-1582722872445-44dc5f7e3c8f?w=400' },
  { name: 'Paneer', description: 'Fresh cottage cheese', price: 350, unit: 'kg', category: 'Dairy & Eggs', image: 'https://images.unsplash.com/photo-1631452180519-c014fe946bc7?w=400' },
  { name: 'Curd', description: 'Fresh curd/dahi', price: 50, unit: 'kg', category: 'Dairy & Eggs', image: 'https://images.unsplash.com/photo-1628088062854-d1870b4553da?w=400' },
  
  // Bakery
  { name: 'White Bread', description: 'Fresh white bread loaf', price: 40, unit: 'piece', category: 'Bakery', image: 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400' },
  { name: 'Whole Wheat Bread', description: 'Healthy whole wheat bread', price: 45, unit: 'piece', category: 'Bakery', image: 'https://images.unsplash.com/photo-1586444248902-2f64eddc13df?w=400' },
  { name: 'Pav Buns', description: 'Soft pav buns', price: 30, unit: 'pack', category: 'Bakery', image: 'https://images.unsplash.com/photo-1608198093002-ad4e005484ec?w=400' },
  
  // Meat & Seafood
  { name: 'Chicken Breast', description: 'Boneless chicken breast', price: 280, unit: 'kg', category: 'Meat & Seafood', image: 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400' },
  { name: 'Mutton', description: 'Fresh mutton', price: 650, unit: 'kg', category: 'Meat & Seafood', image: 'https://images.unsplash.com/photo-1602470520998-f4a52199a3d6?w=400' },
  { name: 'Fish (Pomfret)', description: 'Fresh pomfret fish', price: 450, unit: 'kg', category: 'Meat & Seafood', image: 'https://images.unsplash.com/photo-1535591273668-578e31182c4f?w=400' },
  
  // Beverages
  { name: 'Mango Juice', description: 'Fresh mango juice', price: 120, unit: 'liter', category: 'Beverages', image: 'https://images.unsplash.com/photo-1600271886742-f049cd451bba?w=400' },
  { name: 'Coca Cola', description: 'Coca Cola soft drink', price: 80, unit: 'liter', category: 'Beverages', image: 'https://images.unsplash.com/photo-1554866585-cd94860890b7?w=400' },
  { name: 'Mineral Water', description: 'Pure mineral water', price: 20, unit: 'liter', category: 'Beverages', image: 'https://images.unsplash.com/photo-1548839140-29a749e1cf4d?w=400' },
  
  // Snacks
  { name: 'Potato Chips', description: 'Crispy potato chips', price: 50, unit: 'pack', category: 'Snacks', image: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400' },
  { name: 'Parle-G Biscuits', description: 'Classic glucose biscuits', price: 30, unit: 'pack', category: 'Snacks', image: 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?w=400' },
  
  // Pantry
  { name: 'Basmati Rice', description: 'Premium basmati rice', price: 150, unit: 'kg', category: 'Pantry', image: 'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=400' },
  { name: 'Wheat Flour (Atta)', description: 'Whole wheat flour', price: 45, unit: 'kg', category: 'Pantry', image: 'https://images.unsplash.com/photo-1628672795205-4d0e6bfeb7f6?w=400' },
  { name: 'Mustard Oil', description: 'Pure mustard oil', price: 180, unit: 'liter', category: 'Pantry', image: 'https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400' },
  { name: 'Sugar', description: 'White granulated sugar', price: 50, unit: 'kg', category: 'Pantry', image: 'https://images.unsplash.com/photo-1582169296194-e4d644c48063?w=400' },
  
  // Personal Care
  { name: 'Shampoo', description: 'Hair shampoo', price: 250, unit: 'bottle', category: 'Personal Care', image: 'https://images.unsplash.com/photo-1631730486572-226d1f595b68?w=400' },
  { name: 'Toothpaste', description: 'Mint toothpaste', price: 80, unit: 'tube', category: 'Personal Care', image: 'https://images.unsplash.com/photo-1622372738946-62e02505feb3?w=400' },
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
        images: [product.image || `https://via.placeholder.com/400x400?text=${encodeURIComponent(product.name)}`],
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
