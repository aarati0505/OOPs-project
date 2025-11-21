# MongoDB Setup Guide

## Error: `connect ECONNREFUSED ::1:27017, connect ECONNREFUSED 127.0.0.1:27017`

This error means MongoDB is not running on your local machine. Here are solutions:

---

## Option 1: Install and Start MongoDB Locally (Windows)

### Step 1: Install MongoDB

1. **Download MongoDB Community Server:**
   - Visit: https://www.mongodb.com/try/download/community
   - Select: Windows, MSI package
   - Download and run the installer

2. **During Installation:**
   - Choose "Complete" installation
   - Install as a Windows Service (recommended)
   - Install MongoDB Compass (optional GUI tool)

### Step 2: Start MongoDB Service

**If installed as Windows Service:**
```powershell
# Check if service is running
Get-Service MongoDB

# Start the service
Start-Service MongoDB

# Or use Services panel:
# Win + R → services.msc → Find "MongoDB" → Right-click → Start
```

**If NOT installed as service:**
```powershell
# Navigate to MongoDB bin directory (usually)
cd "C:\Program Files\MongoDB\Server\7.0\bin"

# Start MongoDB
.\mongod.exe --dbpath "C:\data\db"
```

**Note:** Create the data directory first:
```powershell
mkdir C:\data\db
```

### Step 3: Verify MongoDB is Running

```powershell
# Test connection
mongosh
# Or if using older version:
mongo
```

If you see the MongoDB shell prompt, it's working!

---

## Option 2: Use MongoDB Atlas (Cloud - Recommended for Development)

### Step 1: Create Free Account

1. Visit: https://www.mongodb.com/cloud/atlas/register
2. Sign up for free (M0 cluster - 512MB, free forever)

### Step 2: Create Cluster

1. Click "Build a Database"
2. Choose "M0 Free" tier
3. Select a cloud provider and region (closest to you)
4. Click "Create"

### Step 3: Get Connection String

1. Click "Connect" on your cluster
2. Choose "Connect your application"
3. Copy the connection string (looks like):
   ```
   mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```

### Step 4: Update .env File

```bash
# Replace <username> and <password> with your Atlas credentials
MONGODB_URI=mongodb+srv://yourusername:yourpassword@cluster0.xxxxx.mongodb.net/ecommerce_db?retryWrites=true&w=majority
```

### Step 5: Configure Network Access

1. In Atlas dashboard, go to "Network Access"
2. Click "Add IP Address"
3. Click "Allow Access from Anywhere" (for development)
   - Or add your specific IP address

---

## Option 3: Use Docker (If You Have Docker)

```bash
# Run MongoDB in Docker container
docker run -d -p 27017:27017 --name mongodb mongo:latest

# Verify it's running
docker ps
```

Then use in `.env`:
```bash
MONGODB_URI=mongodb://localhost:27017/ecommerce_db
```

---

## Quick Test

After setting up MongoDB, test the connection:

```bash
# In backend/nodejs directory
node -e "require('mongoose').connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/ecommerce_db').then(() => { console.log('✅ Connected!'); process.exit(0); }).catch(err => { console.error('❌ Error:', err.message); process.exit(1); })"
```

---

## Update Your .env File

Make sure your `.env` file has the correct `MONGODB_URI`:

**For Local MongoDB:**
```bash
MONGODB_URI=mongodb://localhost:27017/ecommerce_db
```

**For MongoDB Atlas:**
```bash
MONGODB_URI=mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/ecommerce_db?retryWrites=true&w=majority
```

---

## Troubleshooting

### "MongoDB service won't start"
- Check Windows Event Viewer for errors
- Ensure port 27017 is not in use: `netstat -ano | findstr :27017`
- Try running MongoDB manually: `mongod --dbpath C:\data\db`

### "Connection timeout to Atlas"
- Check Network Access in Atlas dashboard
- Verify your IP is whitelisted
- Check firewall settings

### "Authentication failed"
- Verify username/password in connection string
- Check database user permissions in Atlas

---

## Recommended: MongoDB Atlas

For development, **MongoDB Atlas** is recommended because:
- ✅ No installation needed
- ✅ Free tier available
- ✅ Works on any machine
- ✅ Automatic backups
- ✅ Easy to share with team

---

After setting up MongoDB, restart your server:
```bash
npm run dev
```

