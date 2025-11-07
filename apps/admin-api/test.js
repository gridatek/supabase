// Simple test script to create a user
// Run with: node test.js

const API_URL = 'http://localhost:3001'

async function main() {
  console.log('🔐 Step 1: Login as admin...\n')

  // Login
  const loginResponse = await fetch(`${API_URL}/auth/login`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      email: 'alice@example.com',
      password: 'password123'
    })
  })

  const loginData = await loginResponse.json()

  if (!loginData.success) {
    console.error('❌ Login failed:', loginData.error)
    return
  }

  console.log('✅ Login successful!')
  console.log('   User:', loginData.user.email)
  console.log('   Token:', loginData.access_token.substring(0, 20) + '...\n')

  const token = loginData.access_token

  // Create user
  console.log('👤 Step 2: Creating new user...\n')

  const createResponse = await fetch(`${API_URL}/admin/users`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${token}`
    },
    body: JSON.stringify({
      email: `testuser${Date.now()}@example.com`,
      password: 'testPassword123',
      full_name: 'Test User',
      username: 'testuser'
    })
  })

  const createData = await createResponse.json()

  if (!createData.success) {
    console.error('❌ User creation failed:', createData.error)
    return
  }

  console.log('✅ User created successfully!')
  console.log('   ID:', createData.user.id)
  console.log('   Email:', createData.user.email)
  console.log('   Created:', createData.user.created_at)
  console.log('\n')

  // List users
  console.log('📋 Step 3: Listing all users...\n')

  const listResponse = await fetch(`${API_URL}/admin/users`, {
    headers: { 'Authorization': `Bearer ${token}` }
  })

  const listData = await listResponse.json()

  if (listData.success) {
    console.log(`✅ Found ${listData.users.length} users:`)
    listData.users.forEach((user, index) => {
      console.log(`   ${index + 1}. ${user.email} (${user.id})`)
    })
  }

  console.log('\n🎉 All tests passed!')
}

main().catch(console.error)
