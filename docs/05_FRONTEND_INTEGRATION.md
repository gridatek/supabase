# Frontend Integration Guide

This guide shows how to add a frontend to your Supabase template as a monorepo setup. Choose your preferred framework!

## General Setup Pattern

All frontend frameworks follow a similar pattern:

1. Create frontend app in a `frontend/` directory
2. Install `@supabase/supabase-js` client
3. Configure connection to local Supabase (http://localhost:54321)
4. Update `.gitignore` for frontend-specific files
5. Set up monorepo structure

## Framework Guides

### Angular

#### Quick Setup

```bash
# Install Angular CLI
npm install -g @angular/cli

# Create Angular app (skip git since we're in a monorepo)
ng new frontend --routing --style=scss --skip-git

# Install Supabase client
cd frontend
npm install @supabase/supabase-js
```

#### Configure Supabase Connection

Create `frontend/src/app/supabase.service.ts`:

```typescript
import { Injectable } from '@angular/core';
import { createClient, SupabaseClient } from '@supabase/supabase-js';

@Injectable({
  providedIn: 'root'
})
export class SupabaseService {
  private supabase: SupabaseClient;

  constructor() {
    this.supabase = createClient(
      'http://localhost:54321',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
    );
  }

  get client() {
    return this.supabase;
  }
}
```

### React

#### Quick Setup

```bash
# Create React app with Vite
npm create vite@latest frontend -- --template react-ts

# Install Supabase client
cd frontend
npm install
npm install @supabase/supabase-js
```

#### Configure Supabase Connection

Create `frontend/src/lib/supabase.ts`:

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'http://localhost:54321'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

Use in components:

```typescript
import { supabase } from './lib/supabase'

function App() {
  const [users, setUsers] = useState([])

  useEffect(() => {
    async function fetchUsers() {
      const { data, error } = await supabase
        .from('users')
        .select('*')

      if (data) setUsers(data)
    }
    fetchUsers()
  }, [])

  return <div>{/* Your UI */}</div>
}
```

### Vue

#### Quick Setup

```bash
# Create Vue app
npm create vue@latest frontend

# Install Supabase client
cd frontend
npm install
npm install @supabase/supabase-js
```

#### Configure Supabase Connection

Create `frontend/src/lib/supabase.ts`:

```typescript
import { createClient } from '@supabase/supabase-js'

const supabaseUrl = 'http://localhost:54321'
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'

export const supabase = createClient(supabaseUrl, supabaseAnonKey)
```

Use in components:

```vue
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from './lib/supabase'

const users = ref([])

onMounted(async () => {
  const { data } = await supabase.from('users').select('*')
  if (data) users.value = data
})
</script>
```

### Next.js

#### Quick Setup

```bash
# Create Next.js app
npx create-next-app@latest frontend

# Install Supabase client
cd frontend
npm install @supabase/supabase-js
```

#### Configure Supabase Connection

Create `frontend/lib/supabase.ts`:

```typescript
import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL || 'http://localhost:54321',
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
)
```

Create `frontend/.env.local`:

```env
NEXT_PUBLIC_SUPABASE_URL=http://localhost:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

### Svelte

#### Quick Setup

```bash
# Create Svelte app with Vite
npm create vite@latest frontend -- --template svelte-ts

# Install Supabase client
cd frontend
npm install
npm install @supabase/supabase-js
```

#### Configure Supabase Connection

Create `frontend/src/lib/supabase.ts`:

```typescript
import { createClient } from '@supabase/supabase-js'

export const supabase = createClient(
  'http://localhost:54321',
  'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0'
)
```

## Monorepo Configuration

### Update Root .gitignore

Add framework-specific entries:

```gitignore
# Frontend (adjust based on your framework)
frontend/node_modules/
frontend/dist/
frontend/build/
frontend/.next/
frontend/.angular/
frontend/.svelte-kit/
frontend/.vscode/
```

### Monorepo Structure

Your project should now look like this:

```
project/
├── frontend/                 # Your chosen frontend framework
│   ├── src/
│   ├── package.json
│   └── ...
├── supabase/                # Supabase backend
│   ├── migrations/
│   └── config.toml
├── .github/                 # CI/CD workflows
├── docs/                    # Documentation
├── package.json            # Root scripts
└── README.md
```

## Development Workflow

### Terminal 1: Start Supabase

```bash
npm run dev
```

### Terminal 2: Start Frontend

```bash
cd frontend
npm run dev  # or npm start, depending on framework
```

### Access Points

- **Frontend**: Varies by framework (usually http://localhost:3000 or :4200 or :5173)
- **Supabase API**: http://localhost:54321
- **Email UI**: http://localhost:54324

## Testing Connection

Test your setup by querying the users table:

```typescript
// Example: Fetch users from seed data
const { data, error } = await supabase
  .from('users')
  .select('*')

console.log(data) // Should show Alice, Bob, Carol
```

## Production Configuration

### Environment Variables

For production, use environment variables:

```typescript
// ✅ Good - uses environment variables
const supabase = createClient(
  process.env.VITE_SUPABASE_URL,  // or NEXT_PUBLIC_SUPABASE_URL, etc.
  process.env.VITE_SUPABASE_ANON_KEY
)

// ❌ Bad - hardcoded production credentials
const supabase = createClient(
  'https://xxxxx.supabase.co',
  'eyJhbGc...'
)
```

### Local Development

```env
# .env.local (or .env.development)
VITE_SUPABASE_URL=http://localhost:54321
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
```

### Production

```env
# .env.production (not committed to git!)
VITE_SUPABASE_URL=https://your-project.supabase.co
VITE_SUPABASE_ANON_KEY=your-production-anon-key
```

Get production credentials from:
- Supabase Dashboard → Settings → API

## Git Workflow

The monorepo keeps frontend and backend together:

```bash
# Add frontend to your repo
git add frontend/
git commit -m "Add React frontend"

# Both frontend and backend are tracked together
git push
```

## CI/CD Integration

The template includes an Angular integration workflow at `.github/workflows/angular-integration.yml`.

To adapt for your framework:

1. Open `.github/workflows/angular-integration.yml`
2. Change the name and paths as needed
3. Update the build and test commands

Example for React:

```yaml
- run: npm ci
  working-directory: ./frontend

- run: npm run build
  working-directory: ./frontend

- run: npm test
  working-directory: ./frontend
```

## Common Features

### Authentication

```typescript
// Sign up
const { data, error } = await supabase.auth.signUp({
  email: 'user@example.com',
  password: 'password123'
})

// Sign in
const { data, error } = await supabase.auth.signInWithPassword({
  email: 'alice@example.com',
  password: 'password123'
})

// Sign out
await supabase.auth.signOut()
```

### Real-time Subscriptions

```typescript
// Subscribe to changes
supabase
  .channel('posts')
  .on('postgres_changes',
    { event: '*', schema: 'public', table: 'posts' },
    (payload) => console.log('Change!', payload)
  )
  .subscribe()
```

### File Storage

```typescript
// Upload file
const { data, error } = await supabase.storage
  .from('avatars')
  .upload('public/avatar.png', file)

// Get public URL
const { data } = supabase.storage
  .from('avatars')
  .getPublicUrl('public/avatar.png')
```

## TypeScript Types

Generate types from your database:

```bash
# In root directory
npm run types
```

Use in your frontend:

```typescript
import { Database } from '../types/database.types'

// Type-safe queries
const { data } = await supabase
  .from('users')
  .select('*')
  .returns<Database['public']['Tables']['users']['Row'][]>()
```

## Deployment Options

### Frontend Hosting

Popular options:
- **Vercel** - Best for Next.js, also supports others
- **Netlify** - Great for all frameworks
- **Cloudflare Pages** - Fast global CDN
- **AWS Amplify** - AWS ecosystem
- **Firebase Hosting** - Google ecosystem

### Build Commands

```bash
cd frontend
npm run build
```

Deploy the `dist/` or `build/` directory.

## Troubleshooting

### CORS Errors

Shouldn't happen with Supabase CLI (it handles CORS). If you get CORS errors:

1. Restart Supabase: `npm run stop && npm run dev`
2. Check you're using http://localhost:54321 (not 127.0.0.1)

### Connection Refused

1. Verify Supabase is running: `npm run status`
2. Check the API URL matches (54321)
3. Ensure Docker is running

### RLS Blocking Queries

If queries return empty:

1. Check RLS policies in your migrations
2. Test with service role key (development only)
3. Sign in first for authenticated queries

## Resources

### Framework Documentation
- [Angular](https://angular.io/docs)
- [React](https://react.dev)
- [Vue](https://vuejs.org/guide/)
- [Next.js](https://nextjs.org/docs)
- [Svelte](https://svelte.dev/docs)

### Supabase Guides
- [Supabase JS Client](https://supabase.com/docs/reference/javascript)
- [Framework Quickstarts](https://supabase.com/docs/guides/getting-started/quickstarts)
- [Authentication](https://supabase.com/docs/guides/auth)
- [Database](https://supabase.com/docs/guides/database)
- [Storage](https://supabase.com/docs/guides/storage)
- [Realtime](https://supabase.com/docs/guides/realtime)

---

Choose your framework, follow the guide, and start building! 🚀
