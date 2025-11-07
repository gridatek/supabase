import express from 'express'
import cors from 'cors'
import dotenv from 'dotenv'
import { createClient } from '@supabase/supabase-js'

dotenv.config()

const app = express()
const PORT = process.env.PORT || 3001

// Middleware
app.use(cors())
app.use(express.json())

// Create Supabase admin client (with service_role key)
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

// Create regular Supabase client (for auth verification)
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_ANON_KEY
)

// Middleware to verify the user is authenticated
async function verifyAuth(req, res, next) {
  const authHeader = req.headers.authorization

  if (!authHeader) {
    return res.status(401).json({ error: 'Missing authorization header' })
  }

  const token = authHeader.replace('Bearer ', '')

  // Verify token using admin client
  const { data: { user }, error } = await supabaseAdmin.auth.getUser(token)

  if (error || !user) {
    return res.status(401).json({ error: 'Invalid token' })
  }

  req.user = user
  next()
}

// Middleware to verify the user is an admin
async function verifyAdmin(req, res, next) {
  const { data: profile, error } = await supabaseAdmin
    .from('profiles')
    .select('is_admin')
    .eq('id', req.user.id)
    .single()

  if (error || !profile?.is_admin) {
    return res.status(403).json({ error: 'Forbidden: Admin access required' })
  }

  next()
}

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Admin API is running' })
})

// Login endpoint (for testing)
app.post('/auth/login', async (req, res) => {
  const { email, password } = req.body

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password required' })
  }

  const { data, error } = await supabase.auth.signInWithPassword({
    email,
    password
  })

  if (error) {
    return res.status(400).json({ error: error.message })
  }

  res.json({
    success: true,
    access_token: data.session.access_token,
    user: data.user
  })
})

// Create user endpoint (admin only)
app.post('/admin/users', verifyAuth, verifyAdmin, async (req, res) => {
  const { email, password, full_name, username, metadata, is_admin } = req.body

  // Validate input
  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' })
  }

  // Prepare user metadata
  const userMetadata = {
    full_name: full_name || '',
    ...metadata
  }

  try {
    // Create user using Admin API
    const { data, error } = await supabaseAdmin.auth.admin.createUser({
      email,
      password,
      email_confirm: true, // Auto-confirm email
      user_metadata: userMetadata
    })

    if (error) {
      return res.status(400).json({ error: error.message })
    }

    // Update profile if username or is_admin is provided
    if (username || is_admin) {
      const updateData = {}
      if (username) updateData.username = username
      if (is_admin !== undefined) updateData.is_admin = is_admin

      const { error: profileError } = await supabaseAdmin
        .from('profiles')
        .update(updateData)
        .eq('id', data.user.id)

      if (profileError) {
        console.error('Profile update error:', profileError)
      }
    }

    res.json({
      success: true,
      user: {
        id: data.user.id,
        email: data.user.email,
        created_at: data.user.created_at
      }
    })
  } catch (error) {
    console.error('Create user error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// List users endpoint (admin only)
app.get('/admin/users', verifyAuth, verifyAdmin, async (req, res) => {
  try {
    const { data, error } = await supabaseAdmin.auth.admin.listUsers()

    if (error) {
      return res.status(400).json({ error: error.message })
    }

    res.json({
      success: true,
      users: data.users.map(user => ({
        id: user.id,
        email: user.email,
        created_at: user.created_at,
        last_sign_in_at: user.last_sign_in_at
      }))
    })
  } catch (error) {
    console.error('List users error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Get user by ID endpoint (admin only)
app.get('/admin/users/:id', verifyAuth, verifyAdmin, async (req, res) => {
  const { id } = req.params

  try {
    const { data, error } = await supabaseAdmin.auth.admin.getUserById(id)

    if (error) {
      return res.status(404).json({ error: 'User not found' })
    }

    res.json({
      success: true,
      user: data.user
    })
  } catch (error) {
    console.error('Get user error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Update user endpoint (admin only)
app.put('/admin/users/:id', verifyAuth, verifyAdmin, async (req, res) => {
  const { id } = req.params
  const { email, password, user_metadata } = req.body

  try {
    const updateData = {}
    if (email) updateData.email = email
    if (password) updateData.password = password
    if (user_metadata) updateData.user_metadata = user_metadata

    const { data, error } = await supabaseAdmin.auth.admin.updateUserById(
      id,
      updateData
    )

    if (error) {
      return res.status(400).json({ error: error.message })
    }

    res.json({
      success: true,
      user: data.user
    })
  } catch (error) {
    console.error('Update user error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Delete user endpoint (admin only)
app.delete('/admin/users/:id', verifyAuth, verifyAdmin, async (req, res) => {
  const { id } = req.params

  try {
    const { error } = await supabaseAdmin.auth.admin.deleteUser(id)

    if (error) {
      return res.status(400).json({ error: error.message })
    }

    res.json({
      success: true,
      message: 'User deleted successfully'
    })
  } catch (error) {
    console.error('Delete user error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Get current user info (authenticated users)
app.get('/me', verifyAuth, async (req, res) => {
  try {
    const { data: profile } = await supabaseAdmin
      .from('profiles')
      .select('*')
      .eq('id', req.user.id)
      .single()

    res.json({
      success: true,
      user: {
        id: req.user.id,
        email: req.user.email,
        profile: profile
      }
    })
  } catch (error) {
    console.error('Get me error:', error)
    res.status(500).json({ error: 'Internal server error' })
  }
})

// Error handler
app.use((err, req, res, next) => {
  console.error('Error:', err)
  res.status(500).json({ error: 'Internal server error' })
})

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Admin API server running on http://localhost:${PORT}`)
  console.log(`📝 Health check: http://localhost:${PORT}/health`)
})
