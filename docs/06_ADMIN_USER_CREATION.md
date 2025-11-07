# Admin User Creation (Safe Method)

This guide shows how to create users programmatically using Supabase's official Admin API.

## Overview

The **Supabase Admin API** allows you to create users server-side using the `service_role` key. This is the **official, safe, and recommended** way to create users programmatically.

## ⚠️ Important Security Notes

1. **Never expose `service_role` key in client-side code** (browser, mobile apps)
2. **Only use in server-side environments** (Node.js backend, serverless functions, etc.)
3. **The `service_role` key bypasses Row Level Security** - use with caution

## Getting Your Keys

### Local Development

When running `npm run dev`, check your terminal output or run:

```bash
npm run status
```

You'll see:
```
API URL: http://localhost:54321
anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Production

Get your keys from Supabase Dashboard:
1. Go to your project settings
2. Navigate to **API** section
3. Copy the `service_role` key (keep it secret!)

## Method 1: Server-Side Script (Simplest)

Create a Node.js script to create users:

```javascript
// scripts/create-user.js
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'http://localhost:54321'  // Or your production URL
const supabaseServiceKey = 'YOUR_SERVICE_ROLE_KEY'  // Keep this secret!

const supabase = createClient(supabaseUrl, supabaseServiceKey, {
  auth: {
    autoRefreshToken: false,
    persistSession: false
  }
})

async function createUser(email, password, metadata = {}) {
  const { data, error } = await supabase.auth.admin.createUser({
    email: email,
    password: password,
    email_confirm: true,  // Auto-confirm email
    user_metadata: metadata
  })

  if (error) {
    console.error('Error creating user:', error.message)
    return null
  }

  console.log('User created successfully:', data.user)
  return data.user
}

// Example usage
createUser(
  'newuser@example.com',
  'securePassword123',
  {
    full_name: 'John Doe',
    role: 'member'
  }
)
```

Run it:
```bash
node scripts/create-user.js
```

## Method 2: Next.js API Route (Recommended for Web Apps)

Create a protected API endpoint in your Next.js app:

```typescript
// app/api/admin/create-user/route.ts
import { createClient } from '@supabase/supabase-js'
import { NextRequest, NextResponse } from 'next/server'

// Server-side Supabase client with service_role key
const supabaseAdmin = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,  // From environment variable
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

export async function POST(request: NextRequest) {
  try {
    // 1. Verify the caller is authenticated and is an admin
    const authHeader = request.headers.get('authorization')
    if (!authHeader) {
      return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
    }

    // Get the user making the request
    const token = authHeader.replace('Bearer ', '')
    const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token)

    if (authError || !user) {
      return NextResponse.json({ error: 'Invalid token' }, { status: 401 })
    }

    // Check if user is admin (check your profiles table)
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('is_admin')
      .eq('id', user.id)
      .single()

    if (!profile?.is_admin) {
      return NextResponse.json({ error: 'Forbidden: Admin only' }, { status: 403 })
    }

    // 2. Get user data from request body
    const { email, password, metadata } = await request.json()

    // 3. Create the user using Admin API
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true,
      user_metadata: metadata || {}
    })

    if (error) {
      return NextResponse.json({ error: error.message }, { status: 400 })
    }

    return NextResponse.json({
      success: true,
      user: data.user
    })

  } catch (error) {
    return NextResponse.json({
      error: 'Internal server error'
    }, { status: 500 })
  }
}
```

### Environment Variables (.env.local)

```bash
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_service_role_key  # Keep secret!
```

### Client-Side Usage

```typescript
// app/admin/users/create-user-form.tsx
'use client'

import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'

export default function CreateUserForm() {
  const supabase = createClientComponentClient()

  async function handleCreateUser(formData: FormData) {
    // Get admin's session token
    const { data: { session } } = await supabase.auth.getSession()

    if (!session) {
      alert('Not authenticated')
      return
    }

    // Call your protected API endpoint
    const response = await fetch('/api/admin/create-user', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${session.access_token}`
      },
      body: JSON.stringify({
        email: formData.get('email'),
        password: formData.get('password'),
        metadata: {
          full_name: formData.get('full_name'),
          role: formData.get('role')
        }
      })
    })

    const result = await response.json()

    if (result.success) {
      alert('User created successfully!')
    } else {
      alert('Error: ' + result.error)
    }
  }

  return (
    <form action={handleCreateUser}>
      <input name="email" type="email" placeholder="Email" required />
      <input name="password" type="password" placeholder="Password" required />
      <input name="full_name" type="text" placeholder="Full Name" />
      <input name="role" type="text" placeholder="Role" />
      <button type="submit">Create User</button>
    </form>
  )
}
```

## Method 3: Express.js API (Node Backend)

```javascript
// server.js
import express from 'express'
import { createClient } from '@supabase/supabase-js'

const app = express()
app.use(express.json())

const supabaseAdmin = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

// Middleware to verify admin
async function verifyAdmin(req, res, next) {
  const authHeader = req.headers.authorization

  if (!authHeader) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  const token = authHeader.replace('Bearer ', '')
  const { data: { user }, error } = await supabaseAdmin.auth.getUser(token)

  if (error || !user) {
    return res.status(401).json({ error: 'Invalid token' })
  }

  // Check if user is admin
  const { data: profile } = await supabaseAdmin
    .from('profiles')
    .select('is_admin')
    .eq('id', user.id)
    .single()

  if (!profile?.is_admin) {
    return res.status(403).json({ error: 'Forbidden: Admin only' })
  }

  req.user = user
  next()
}

// Create user endpoint
app.post('/api/admin/create-user', verifyAdmin, async (req, res) => {
  const { email, password, metadata } = req.body

  const { data, error } = await supabaseAdmin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: metadata || {}
  })

  if (error) {
    return res.status(400).json({ error: error.message })
  }

  res.json({ success: true, user: data.user })
})

app.listen(3001, () => {
  console.log('Server running on port 3001')
})
```

## Method 4: Serverless Function (Vercel/Netlify)

```typescript
// api/admin/create-user.ts (Vercel serverless function)
import { createClient } from '@supabase/supabase-js'
import type { VercelRequest, VercelResponse } from '@vercel/node'

const supabaseAdmin = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_SERVICE_ROLE_KEY!,
  {
    auth: {
      autoRefreshToken: false,
      persistSession: false
    }
  }
)

export default async function handler(
  req: VercelRequest,
  res: VercelResponse
) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' })
  }

  // Verify admin (same logic as above)
  const authHeader = req.headers.authorization
  if (!authHeader) {
    return res.status(401).json({ error: 'Unauthorized' })
  }

  const token = authHeader.replace('Bearer ', '')
  const { data: { user }, error: authError } = await supabaseAdmin.auth.getUser(token)

  if (authError || !user) {
    return res.status(401).json({ error: 'Invalid token' })
  }

  const { data: profile } = await supabaseAdmin
    .from('profiles')
    .select('is_admin')
    .eq('id', user.id)
    .single()

  if (!profile?.is_admin) {
    return res.status(403).json({ error: 'Forbidden: Admin only' })
  }

  // Create user
  const { email, password, metadata } = req.body

  const { data, error } = await supabaseAdmin.auth.admin.createUser({
    email,
    password,
    email_confirm: true,
    user_metadata: metadata || {}
  })

  if (error) {
    return res.status(400).json({ error: error.message })
  }

  return res.json({ success: true, user: data.user })
}
```

## Admin API Features

### Create User with Options

```javascript
const { data, error } = await supabase.auth.admin.createUser({
  email: 'user@example.com',
  password: 'password123',
  email_confirm: true,  // Skip email confirmation
  phone_confirm: false,
  user_metadata: {
    full_name: 'John Doe',
    department: 'Engineering',
    role: 'developer'
  },
  app_metadata: {
    provider: 'email',
    admin_created: true
  }
})
```

### Update User

```javascript
await supabase.auth.admin.updateUserById(
  'user-uuid',
  {
    email: 'newemail@example.com',
    user_metadata: { role: 'admin' }
  }
)
```

### Delete User

```javascript
await supabase.auth.admin.deleteUser('user-uuid')
```

### List Users

```javascript
const { data: { users }, error } = await supabase.auth.admin.listUsers()
```

## Adding Admin Flag to Database

If you want to track admin users in your database, create a simple migration:

```sql
-- supabase/migrations/00004_add_admin_flag.sql
ALTER TABLE public.profiles
    ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

CREATE INDEX IF NOT EXISTS idx_profiles_is_admin
    ON public.profiles(is_admin) WHERE is_admin = true;
```

Then manually set admins via SQL:

```sql
UPDATE public.profiles
SET is_admin = true
WHERE email = 'admin@example.com';
```

## Security Best Practices

1. **Environment Variables**: Always use environment variables for `service_role` key
2. **Server-Side Only**: Never use `service_role` key in client code
3. **Verify Admin**: Always check if the requesting user is an admin
4. **Rate Limiting**: Add rate limiting to prevent abuse
5. **Logging**: Log all user creation events for audit trails
6. **Validation**: Validate email format and password strength
7. **Error Handling**: Don't expose sensitive error details to clients

## Example: Complete Admin Dashboard

```typescript
// app/admin/users/page.tsx
'use client'

import { useState } from 'react'
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs'

export default function AdminUsersPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const supabase = createClientComponentClient()

  async function createUser(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)

    try {
      const { data: { session } } = await supabase.auth.getSession()

      const response = await fetch('/api/admin/create-user', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${session?.access_token}`
        },
        body: JSON.stringify({ email, password })
      })

      const result = await response.json()

      if (result.success) {
        alert('User created successfully!')
        setEmail('')
        setPassword('')
      } else {
        alert('Error: ' + result.error)
      }
    } catch (error) {
      alert('Failed to create user')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div>
      <h1>Create User (Admin Only)</h1>
      <form onSubmit={createUser}>
        <input
          type="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          placeholder="Email"
          required
        />
        <input
          type="password"
          value={password}
          onChange={(e) => setPassword(e.target.value)}
          placeholder="Password"
          required
        />
        <button type="submit" disabled={loading}>
          {loading ? 'Creating...' : 'Create User'}
        </button>
      </form>
    </div>
  )
}
```

## Troubleshooting

### "Invalid API key"
- Check your `service_role` key is correct
- Verify you're using the right environment (local vs production)

### "User already registered"
- The email is already in use
- Check existing users or use a different email

### "Forbidden: Admin only"
- The authenticated user is not an admin
- Update `is_admin` flag in profiles table

### CORS errors
- Make sure your API route allows requests from your domain
- Add proper CORS headers if using Express

## Summary

✅ **Use `supabase.auth.admin.createUser()`** - Official, safe method
✅ **Server-side only** - Never expose service_role key
✅ **Verify admin status** - Check permissions before creating users
✅ **Environment variables** - Keep secrets safe
✅ **Proper error handling** - Don't leak sensitive info

This approach is **production-ready, secure, and officially supported** by Supabase.
