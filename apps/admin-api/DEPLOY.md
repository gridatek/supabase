# Deployment Guide - Admin API

Complete guide for running the admin API locally and deploying to production.

---

## 🏠 Running Locally

### Prerequisites

1. **Supabase must be running**
   ```bash
   # In project root
   npm run dev
   ```

2. **Node.js 18+** installed

### Step-by-Step Setup

#### 1. Install Dependencies

```bash
cd apps/admin-api
npm install
```

#### 2. Get Supabase Keys

```bash
# In project root (not in apps/admin-api)
cd ../..
npm run status
```

You'll see output like:
```
API URL: http://localhost:54321
anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### 3. Configure Environment

```bash
cd apps/admin-api
cp .env.example .env
```

Edit `.env` with your keys:
```env
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
PORT=3001
```

#### 4. Setup Admin User

Add `is_admin` column to database:

```bash
# From project root
npm run shell
```

Run this SQL:
```sql
-- Add is_admin column
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

-- Make alice an admin
UPDATE public.profiles
SET is_admin = true
WHERE email = 'alice@example.com';

-- Verify it worked
SELECT id, email, username, is_admin
FROM public.profiles
WHERE is_admin = true;
```

Type `\q` to exit.

#### 5. Start the Server

```bash
cd apps/admin-api
npm start
```

You should see:
```
🚀 Admin API server running on http://localhost:3001
📝 Health check: http://localhost:3001/health
```

#### 6. Test It

**Option A: Run test script**
```bash
node test.js
```

**Option B: Use cURL**
```bash
# Login
curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"password123"}'

# Create user (replace TOKEN)
curl -X POST http://localhost:3001/admin/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "password123",
    "full_name": "New User"
  }'
```

**Option C: Use VS Code REST Client**
1. Install "REST Client" extension
2. Open `test-requests.http`
3. Click "Send Request" above each request

---

## 🚀 Deploying to Production

### Option 1: Railway (Easiest - Recommended)

Railway provides free hosting for Node.js apps.

#### Setup

1. **Create Railway Account**
   - Go to https://railway.app
   - Sign up with GitHub

2. **Install Railway CLI**
   ```bash
   npm install -g @railway/cli
   ```

3. **Login**
   ```bash
   railway login
   ```

4. **Initialize Project**
   ```bash
   cd apps/admin-api
   railway init
   ```

5. **Add Environment Variables**
   ```bash
   railway variables set SUPABASE_URL=https://your-project.supabase.co
   railway variables set SUPABASE_ANON_KEY=your_production_anon_key
   railway variables set SUPABASE_SERVICE_ROLE_KEY=your_production_service_key
   railway variables set PORT=3001
   ```

   Or use the Railway dashboard:
   - Go to your project
   - Click "Variables"
   - Add each variable

6. **Deploy**
   ```bash
   railway up
   ```

7. **Get Your URL**
   ```bash
   railway open
   ```

Your API will be live at `https://your-app.railway.app`

---

### Option 2: Vercel (Serverless)

Deploy as serverless functions.

#### Setup

1. **Install Vercel CLI**
   ```bash
   npm install -g vercel
   ```

2. **Create `vercel.json`**
   ```bash
   cd apps/admin-api
   ```

   Create `vercel.json`:
   ```json
   {
     "version": 2,
     "builds": [
       {
         "src": "server.js",
         "use": "@vercel/node"
       }
     ],
     "routes": [
       {
         "src": "/(.*)",
         "dest": "server.js"
       }
     ],
     "env": {
       "SUPABASE_URL": "@supabase_url",
       "SUPABASE_ANON_KEY": "@supabase_anon_key",
       "SUPABASE_SERVICE_ROLE_KEY": "@supabase_service_role_key"
     }
   }
   ```

3. **Add Environment Variables**
   ```bash
   vercel env add SUPABASE_URL
   vercel env add SUPABASE_ANON_KEY
   vercel env add SUPABASE_SERVICE_ROLE_KEY
   ```

4. **Deploy**
   ```bash
   vercel
   ```

5. **Deploy to Production**
   ```bash
   vercel --prod
   ```

Your API will be at `https://your-app.vercel.app`

---

### Option 3: Render

Free tier with automatic deploys from Git.

#### Setup

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Add admin API"
   git push
   ```

2. **Create Render Account**
   - Go to https://render.com
   - Sign up with GitHub

3. **Create New Web Service**
   - Click "New +" → "Web Service"
   - Connect your GitHub repo
   - Select `apps/admin-api` as root directory

4. **Configure**
   - **Name**: `admin-api`
   - **Environment**: `Node`
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`

5. **Add Environment Variables**
   Click "Environment" tab and add:
   ```
   SUPABASE_URL=https://your-project.supabase.co
   SUPABASE_ANON_KEY=your_production_anon_key
   SUPABASE_SERVICE_ROLE_KEY=your_production_service_key
   PORT=3001
   ```

6. **Deploy**
   Click "Create Web Service"

Your API will be at `https://admin-api-xxx.onrender.com`

---

### Option 4: Heroku

Traditional PaaS hosting.

#### Setup

1. **Install Heroku CLI**
   ```bash
   # Windows
   winget install Heroku.HerokuCLI

   # macOS
   brew install heroku/brew/heroku

   # Linux
   curl https://cli-assets.heroku.com/install.sh | sh
   ```

2. **Login**
   ```bash
   heroku login
   ```

3. **Create App**
   ```bash
   cd apps/admin-api
   heroku create your-admin-api
   ```

4. **Add Environment Variables**
   ```bash
   heroku config:set SUPABASE_URL=https://your-project.supabase.co
   heroku config:set SUPABASE_ANON_KEY=your_anon_key
   heroku config:set SUPABASE_SERVICE_ROLE_KEY=your_service_key
   ```

5. **Create `Procfile`**
   ```bash
   echo "web: npm start" > Procfile
   ```

6. **Deploy**
   ```bash
   git init
   git add .
   git commit -m "Deploy admin API"
   git push heroku main
   ```

Your API will be at `https://your-admin-api.herokuapp.com`

---

### Option 5: AWS Lambda (Advanced)

Deploy as serverless function using AWS Lambda.

#### Setup

1. **Install Serverless Framework**
   ```bash
   npm install -g serverless
   ```

2. **Create `serverless.yml`**
   ```yaml
   service: admin-api

   provider:
     name: aws
     runtime: nodejs18.x
     region: us-east-1
     environment:
       SUPABASE_URL: ${env:SUPABASE_URL}
       SUPABASE_ANON_KEY: ${env:SUPABASE_ANON_KEY}
       SUPABASE_SERVICE_ROLE_KEY: ${env:SUPABASE_SERVICE_ROLE_KEY}

   functions:
     api:
       handler: lambda.handler
       events:
         - http:
             path: /{proxy+}
             method: ANY
   ```

3. **Create `lambda.js`**
   ```javascript
   import serverless from 'serverless-http'
   import express from './server.js'

   export const handler = serverless(express)
   ```

4. **Deploy**
   ```bash
   serverless deploy
   ```

---

## 🔐 Production Security Checklist

Before deploying to production:

### 1. Environment Variables
- [ ] Never commit `.env` file
- [ ] Use production Supabase URL
- [ ] Use production service_role key
- [ ] Keep service_role key secret

### 2. CORS Configuration
Update `server.js`:
```javascript
import cors from 'cors'

app.use(cors({
  origin: 'https://yourdomain.com', // Replace with your domain
  credentials: true
}))
```

### 3. Rate Limiting
Add rate limiting:
```bash
npm install express-rate-limit
```

Update `server.js`:
```javascript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100 // limit each IP to 100 requests per windowMs
})

app.use('/admin', limiter)
```

### 4. HTTPS Only
Add to `server.js`:
```javascript
app.use((req, res, next) => {
  if (req.header('x-forwarded-proto') !== 'https' && process.env.NODE_ENV === 'production') {
    res.redirect(`https://${req.header('host')}${req.url}`)
  } else {
    next()
  }
})
```

### 5. Logging
Add logging middleware:
```bash
npm install morgan
```

```javascript
import morgan from 'morgan'
app.use(morgan('combined'))
```

### 6. Error Handling
Don't expose stack traces in production:
```javascript
app.use((err, req, res, next) => {
  console.error(err.stack)
  res.status(500).json({
    error: process.env.NODE_ENV === 'production'
      ? 'Internal server error'
      : err.message
  })
})
```

---

## 🧪 Testing Production Deployment

Once deployed, test your endpoints:

```bash
# Replace with your production URL
API_URL=https://your-api.railway.app

# Health check
curl $API_URL/health

# Login
curl -X POST $API_URL/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@example.com","password":"your_password"}'

# Create user (with token from login)
curl -X POST $API_URL/admin/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "password123"
  }'
```

---

## 🔧 Troubleshooting

### Local Issues

**"Cannot connect to Supabase"**
- Make sure Supabase is running: `npm run dev`
- Check `SUPABASE_URL` in `.env` is `http://localhost:54321`

**"Forbidden: Admin access required"**
- Make sure you set `is_admin = true` for your user
- Run: `npm run shell` then check the SQL queries above

**Port already in use**
- Change `PORT` in `.env` to different port (e.g., 3002)

### Production Issues

**"Invalid token"**
- Make sure production `SUPABASE_URL` matches your Supabase project
- Check that `SUPABASE_ANON_KEY` is correct

**"Internal server error"**
- Check logs in your hosting platform
- Verify all environment variables are set
- Make sure `SUPABASE_SERVICE_ROLE_KEY` is correct

**CORS errors**
- Update CORS configuration to allow your domain
- See security checklist above

---

## 📊 Monitoring

### Railway
```bash
railway logs
```

### Vercel
```bash
vercel logs
```

### Render
- Go to dashboard → Your service → Logs

### Heroku
```bash
heroku logs --tail
```

---

## 🎯 Quick Comparison

| Platform | Cost | Ease | Performance | Best For |
|----------|------|------|-------------|----------|
| **Railway** | Free tier | ⭐⭐⭐⭐⭐ | Good | Quick deploys |
| **Vercel** | Free tier | ⭐⭐⭐⭐ | Excellent | Serverless |
| **Render** | Free tier | ⭐⭐⭐⭐ | Good | Git-based |
| **Heroku** | $7/mo | ⭐⭐⭐ | Good | Traditional |
| **AWS Lambda** | Pay-per-use | ⭐⭐ | Excellent | Scale |

**Recommendation**: Start with **Railway** for easiest deployment.

---

## 📝 Summary

### Local Development
```bash
cd apps/admin-api
npm install
cp .env.example .env
# Add your keys to .env
npm start
```

### Production Deployment
```bash
# Railway (recommended)
railway login
railway init
railway up

# Or Vercel
vercel

# Or Render
# Push to GitHub, then connect repo in Render dashboard
```

That's it! Your admin API is now running locally and can be deployed to production in minutes. 🚀
