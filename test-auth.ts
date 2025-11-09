#!/usr/bin/env -S deno run --allow-net --allow-env

const SUPABASE_URL = 'http://127.0.0.1:54321'
const SUPABASE_ANON_KEY = 'sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH'

console.log('Testing basic Auth...\n')

// Test 1: Try to sign up a new user
console.log('Test 1: Sign up new user')
try {
  const signupResponse = await fetch(`${SUPABASE_URL}/auth/v1/signup`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email: `test${Date.now()}@example.com`,
      password: 'testpass123',
    }),
  })

  const signupData = await signupResponse.json()
  console.log('Signup response:', signupResponse.status, signupData)
} catch (error) {
  console.error('Signup error:', error.message)
}

// Test 2: Try to login with Alice
console.log('\nTest 2: Login with Alice')
try {
  const loginResponse = await fetch(`${SUPABASE_URL}/auth/v1/token?grant_type=password`, {
    method: 'POST',
    headers: {
      'apikey': SUPABASE_ANON_KEY,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      email: 'alice@example.com',
      password: 'password123',
    }),
  })

  const loginText = await loginResponse.text()
  console.log('Login response:', loginResponse.status)
  console.log('Response body:', loginText)

  if (loginResponse.ok) {
    const loginData = JSON.parse(loginText)
    console.log('✅ Login successful, token received')
  } else {
    console.error('❌ Login failed')
  }
} catch (error) {
  console.error('Login error:', error.message)
}
