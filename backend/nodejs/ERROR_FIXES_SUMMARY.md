# Error Fixes Summary

## Issues Fixed

### ✅ 1. Mongoose Duplicate Index Warnings

**Problem:** Mongoose was warning about duplicate indexes on several fields.

**Root Cause:** Fields with `unique: true` automatically create indexes, but we were also manually creating indexes on the same fields.

**Fixed Models:**
- ✅ `User.js` - Removed duplicate indexes on `email` and `phone`
- ✅ `OtpToken.js` - Removed duplicate index on `expiresAt` (kept TTL index)
- ✅ `Category.js` - Removed duplicate indexes on `name` and `slug`
- ✅ `Cart.js` - Removed duplicate index on `userId`

**Solution:** When a field has `unique: true`, it automatically creates an index. We removed the manual `schema.index()` calls for those fields.

---

### ⚠️ 2. MongoDB Connection Error

**Error:** `connect ECONNREFUSED ::1:27017, connect ECONNREFUSED 127.0.0.1:27017`

**Problem:** MongoDB is not running on your local machine.

**Solutions:**

#### Option A: Install MongoDB Locally (Windows)

1. **Download MongoDB:**
   - Visit: https://www.mongodb.com/try/download/community
   - Download Windows MSI installer
   - Install with "Complete" option
   - Install as Windows Service (recommended)

2. **Start MongoDB Service:**
   ```powershell
   # Check service status
  mongodb://localhost:27017/
   
   # Start service
   Start-Service MongoDB
   ```

3. **Or start manually:**
   ```powershell
   # Create data directory
   mkdir C:\data\db
   
   # Start MongoDB
   "C:\Program Files\MongoDB\Server\7.0\bin\mongod.exe" --dbpath "C:\data\db"
   ```

#### Option B: Use MongoDB Atlas (Recommended - Free Cloud Database)

1. **Sign up:** https://www.mongodb.com/cloud/atlas/register
2. **Create free M0 cluster** (512MB, free forever)
3. **Get connection string** from Atlas dashboard
4. **Update `.env` file:**
   ```bash
   MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/ecommerce_db?retryWrites=true&w=majority
   ```
5. **Whitelist your IP** in Atlas Network Access settings

**See `MONGODB_SETUP.md` for detailed instructions.**

---

## Next Steps

1. **Fix MongoDB Connection:**
   - Choose Option A (local) or Option B (Atlas)
   - Update `MONGODB_URI` in `.env` file
   - Restart server: `npm run dev`

2. **Verify Fixes:**
   - Duplicate index warnings should be gone
   - MongoDB connection should succeed
   - Server should start without errors

---

## Quick Test

After setting up MongoDB, test the connection:

```bash
# Test MongoDB connection
node -e "require('mongoose').connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ecommerce_db').then(() => { console.log('✅ MongoDB Connected!'); process.exit(0); }).catch(err => { console.error('❌ Error:', err.message); process.exit(1); })"
```

---

## Files Modified

- ✅ `models/User.js` - Fixed duplicate email/phone indexes
- ✅ `models/OtpToken.js` - Fixed duplicate expiresAt index
- ✅ `models/Category.js` - Fixed duplicate name/slug indexes
- ✅ `models/Cart.js` - Fixed duplicate userId index

---

**All duplicate index warnings are now fixed!** ✅

**MongoDB connection needs to be set up - see `MONGODB_SETUP.md` for instructions.**

