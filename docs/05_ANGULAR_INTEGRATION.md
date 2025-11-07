# Angular Integration Guide

This guide shows how to add Angular to your Supabase template as a monorepo setup.

## Quick Setup

### 1. Create Angular Application

```bash
# Install Angular CLI
npm install -g @angular/cli

# Create Angular app (skip git since we're in a monorepo)
ng new frontend --routing --style=scss --skip-git

# Install Supabase client
cd frontend
npm install @supabase/supabase-js
```

### 2. Configure Supabase Connection

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

> **Note**: For production, use environment variables. The key above is the Supabase CLI default.

### 3. Update .gitignore

Add Angular-specific entries to your root `.gitignore`:

```gitignore
# Angular
frontend/node_modules/
frontend/dist/
frontend/.angular/
frontend/.vscode/
```

### 4. Test the Connection

Update `frontend/src/app/app.component.ts`:

```typescript
import { Component, OnInit } from '@angular/core';
import { SupabaseService } from './supabase.service';

@Component({
  selector: 'app-root',
  template: `
    <h1>Supabase + Angular</h1>
    <p>{{ status }}</p>
  `
})
export class AppComponent implements OnInit {
  status = 'Checking connection...';

  constructor(private supabase: SupabaseService) {}

  async ngOnInit() {
    try {
      const { error } = await this.supabase.client.from('users').select('count');
      this.status = error ? `Error: ${error.message}` : '✅ Connected to Supabase!';
    } catch (e) {
      this.status = '❌ Connection failed';
    }
  }
}
```

## Monorepo Structure

Your project should now look like this:

```
project/
├── frontend/                 # Angular app
│   ├── src/
│   ├── angular.json
│   └── package.json
├── supabase/                # Supabase config & migrations
│   ├── migrations/
│   └── config.toml
├── .github/                 # CI/CD workflows
├── package.json            # Root scripts
└── README.md
```

## Development Workflow

```bash
# Terminal 1: Start Supabase
npm run dev

# Terminal 2: Start Angular
cd frontend
npm start
```

Access:
- Angular: http://localhost:4200
- Supabase API: http://localhost:54321
- Email UI: http://localhost:54324

## Git Workflow

The monorepo is ready for version control:

```bash
# Add Angular to your repo
git add frontend/
git commit -m "Add Angular frontend"

# Both frontend and backend are tracked together
git push
```

## Production Build

```bash
# Build Angular for production
cd frontend
npm run build

# Deploy frontend to your hosting (Vercel, Netlify, etc.)
# Deploy backend with: npm run migrate:prod
```

## What You Have Now

- ✅ Angular + Supabase monorepo
- ✅ Single source of truth for migrations
- ✅ Shared version control
- ✅ Cross-platform dev environment
- ✅ CI/CD ready

## Next Steps

Now you can build your app! Add:
- Authentication UI
- Database queries
- Real-time subscriptions
- File uploads
- Your business logic

## Example Usage

```typescript
// In any component
export class MyComponent {
  constructor(private supabase: SupabaseService) {}

  async loadData() {
    const { data, error } = await this.supabase.client
      .from('your_table')
      .select('*');
  }
}
```

## Troubleshooting

**Connection errors**: Make sure Supabase is running (`npm run status`)

**Port conflicts**: Stop other services using ports 54321 or 4200

**CORS errors**: Shouldn't happen with Supabase CLI, but restart if needed

## Resources

- [Angular Docs](https://angular.io/docs)
- [Supabase JS Client](https://supabase.com/docs/reference/javascript)
- [Supabase Angular Guide](https://supabase.com/docs/guides/getting-started/tutorials/with-angular)

---

That's it! You now have Angular integrated into your Supabase template. Build your features and ship! 🚀
