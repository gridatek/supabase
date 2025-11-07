# Admin API - User Management

A production-ready Express.js API for managing Supabase users with admin authentication.

## Features

✅ Admin-only user creation via API
✅ User listing, updating, and deletion
✅ Secure authentication using Supabase JWT
✅ Admin role verification
✅ Auto-confirm emails for created users
✅ Full CRUD operations on users

## Quick Start

### 1. Install Dependencies

```bash
cd admin-api
npm install
```

### 2. Configure Environment

Create `.env` file:

```bash
cp .env.example .env
```

Edit `.env` and add your Supabase keys:

```env
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key
PORT=3001
```

**Get your keys:**

```bash
# In the main project directory
npm run status
```

Copy the `anon key` and `service_role key` from the output.

### 3. Setup Admin User

First, you need an admin user. Add the `is_admin` column to profiles:

```bash
# In main project directory
cd ..
npm run shell
```

Then run this SQL:

```sql
-- Add is_admin column if not exists
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

-- Make alice an admin
UPDATE public.profiles SET is_admin = true WHERE email = 'alice@example.com';

-- Verify
SELECT id, email, is_admin FROM public.profiles WHERE is_admin = true;
```

Exit with `\q`

### 4. Start the API Server

```bash
cd admin-api
npm start
```

You should see:
```
🚀 Admin API server running on http://localhost:3001
📝 Health check: http://localhost:3001/health
```

### 5. Test It!

Run the test script:

```bash
node test.js
```

You should see:
```
🔐 Step 1: Login as admin...
✅ Login successful!

👤 Step 2: Creating new user...
✅ User created successfully!

📋 Step 3: Listing all users...
✅ Found 4 users:

🎉 All tests passed!
```

## API Endpoints

### Authentication

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "alice@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "success": true,
  "access_token": "eyJhbGc...",
  "user": { "id": "...", "email": "..." }
}
```

### Admin Endpoints (Require Admin Token)

#### Create User
```http
POST /admin/users
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "email": "newuser@example.com",
  "password": "password123",
  "full_name": "John Doe",
  "username": "johndoe",
  "is_admin": false
}
```

**Response:**
```json
{
  "success": true,
  "user": {
    "id": "uuid",
    "email": "newuser@example.com",
    "created_at": "2025-11-07T..."
  }
}
```

#### List All Users
```http
GET /admin/users
Authorization: Bearer YOUR_TOKEN
```

**Response:**
```json
{
  "success": true,
  "users": [
    {
      "id": "uuid",
      "email": "user@example.com",
      "created_at": "2025-11-07T...",
      "last_sign_in_at": "2025-11-07T..."
    }
  ]
}
```

#### Get User By ID
```http
GET /admin/users/:id
Authorization: Bearer YOUR_TOKEN
```

#### Update User
```http
PUT /admin/users/:id
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json

{
  "email": "newemail@example.com",
  "password": "newpassword",
  "user_metadata": {
    "full_name": "Updated Name"
  }
}
```

#### Delete User
```http
DELETE /admin/users/:id
Authorization: Bearer YOUR_TOKEN
```

### Public Endpoints

#### Health Check
```http
GET /health
```

#### Get Current User
```http
GET /me
Authorization: Bearer YOUR_TOKEN
```

## Usage Examples

### Using cURL

```bash
# 1. Login and get token
TOKEN=$(curl -X POST http://localhost:3001/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@example.com","password":"password123"}' \
  | jq -r '.access_token')

# 2. Create a user
curl -X POST http://localhost:3001/admin/users \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "newuser@example.com",
    "password": "password123",
    "full_name": "New User"
  }'

# 3. List users
curl http://localhost:3001/admin/users \
  -H "Authorization: Bearer $TOKEN"
```

### Using JavaScript (fetch)

```javascript
// Login
const loginRes = await fetch('http://localhost:3001/auth/login', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    email: 'alice@example.com',
    password: 'password123'
  })
})
const { access_token } = await loginRes.json()

// Create user
const createRes = await fetch('http://localhost:3001/admin/users', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${access_token}`,
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    email: 'newuser@example.com',
    password: 'password123',
    full_name: 'New User',
    username: 'newuser'
  })
})
const result = await createRes.json()
console.log(result)
```

### Using the HTTP File

If you use VS Code with REST Client extension:

1. Open `test-requests.http`
2. Update the `@token` variable with your token
3. Click "Send Request" above any request

## Security

### Admin Verification

The API verifies admin status on every protected endpoint:

1. Checks JWT token validity
2. Queries `profiles` table for `is_admin = true`
3. Rejects non-admin requests with 403 Forbidden

### Service Role Key

The `SUPABASE_SERVICE_ROLE_KEY` is used to:
- Bypass RLS policies
- Access admin-only auth functions
- Create/update/delete users

**Never expose this key in client-side code!**

### Token Security

- Tokens are validated on every request
- Expired tokens are rejected
- Users can only access admin endpoints if `is_admin = true`

## Error Handling

### Common Errors

**401 Unauthorized:**
- Missing or invalid token
- Expired session

**403 Forbidden:**
- User is not an admin
- Check `is_admin` field in profiles table

**400 Bad Request:**
- Invalid input data
- User already exists
- Password too weak

## Development

### Watch Mode

```bash
npm run dev
```

Auto-restarts server on file changes (Node 18+ required).

### Testing

```bash
# Run test script
node test.js

# Or use test-requests.http in VS Code
```

## Production Deployment

### Environment Variables

Set these in your hosting platform:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_production_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_production_service_role_key
PORT=3001
```

### Recommended Hosting

- **Vercel** - Deploy as serverless functions
- **Railway** - Single command deployment
- **Heroku** - Traditional hosting
- **AWS Lambda** - Serverless deployment

### Additional Security

1. **Rate Limiting**: Add express-rate-limit
2. **HTTPS Only**: Enforce SSL in production
3. **CORS**: Restrict to your domain
4. **Logging**: Add request logging
5. **Monitoring**: Set up error tracking

## Troubleshooting

### "Missing authorization header"

Make sure you include the token:
```http
Authorization: Bearer YOUR_TOKEN_HERE
```

### "Forbidden: Admin access required"

The user is not an admin. Make them admin:
```sql
UPDATE public.profiles SET is_admin = true WHERE email = 'user@example.com';
```

### "Invalid token"

The token has expired. Login again to get a new token.

### Server won't start

Check that:
1. Dependencies are installed (`npm install`)
2. `.env` file exists with correct keys
3. Port 3001 is not in use
4. Supabase is running (`npm run dev` in main project)

## Project Structure

```
admin-api/
├── server.js           # Express server with all endpoints
├── package.json        # Dependencies
├── .env.example        # Environment template
├── .env               # Your config (git-ignored)
├── test.js            # Automated test script
├── test-requests.http # HTTP requests for VS Code
└── README.md          # This file
```

## Next Steps

- [ ] Add password validation
- [ ] Implement rate limiting
- [ ] Add audit logging
- [ ] Create bulk user import
- [ ] Add email notifications
- [ ] Build admin dashboard UI

## License

MIT
