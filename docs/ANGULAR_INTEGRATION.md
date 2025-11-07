# Angular Integration Guide

This guide walks you through integrating an Angular frontend with your Supabase backend.

## Prerequisites

- Node.js 18+ and npm installed
- Supabase services running (`make up`)
- Basic understanding of Angular and TypeScript

## Quick Start

### 1. Create Angular Application

```bash
# Install Angular CLI globally
npm install -g @angular/cli

# Create new Angular app in the frontend directory
ng new frontend --routing --style=scss

# Navigate to the frontend directory
cd frontend
```

### 2. Install Supabase Client

```bash
npm install @supabase/supabase-js
```

### 3. Configure Environment Variables

Create environment files for Angular:

**`frontend/src/environments/environment.ts`** (Development):
```typescript
export const environment = {
  production: false,
  supabase: {
    url: 'http://localhost:8000',
    anonKey: 'your-anon-key-from-docker-env'
  }
};
```

**`frontend/src/environments/environment.prod.ts`** (Production):
```typescript
export const environment = {
  production: true,
  supabase: {
    url: 'https://your-project.supabase.co',
    anonKey: 'your-production-anon-key'
  }
};
```

> **Note**: Get the `ANON_KEY` from your `docker/.env` file for local development.

### 4. Create Supabase Service

Generate a service to handle Supabase operations:

```bash
ng generate service core/services/supabase
```

**`frontend/src/app/core/services/supabase.service.ts`**:
```typescript
import { Injectable } from '@angular/core';
import { createClient, SupabaseClient, User } from '@supabase/supabase-js';
import { environment } from '../../../environments/environment';
import { BehaviorSubject, Observable } from 'rxjs';

@Injectable({
  providedIn: 'root'
})
export class SupabaseService {
  private supabase: SupabaseClient;
  private currentUser = new BehaviorSubject<User | null>(null);
  public user$: Observable<User | null> = this.currentUser.asObservable();

  constructor() {
    this.supabase = createClient(
      environment.supabase.url,
      environment.supabase.anonKey
    );

    // Initialize auth state
    this.supabase.auth.getSession().then(({ data: { session } }) => {
      this.currentUser.next(session?.user ?? null);
    });

    // Listen to auth changes
    this.supabase.auth.onAuthStateChange((event, session) => {
      this.currentUser.next(session?.user ?? null);
    });
  }

  // Auth methods
  async signUp(email: string, password: string) {
    return await this.supabase.auth.signUp({ email, password });
  }

  async signIn(email: string, password: string) {
    return await this.supabase.auth.signInWithPassword({ email, password });
  }

  async signOut() {
    return await this.supabase.auth.signOut();
  }

  async resetPassword(email: string) {
    return await this.supabase.auth.resetPasswordForEmail(email);
  }

  // Database methods
  get db() {
    return this.supabase.from.bind(this.supabase);
  }

  // Storage methods
  get storage() {
    return this.supabase.storage;
  }

  // Realtime subscriptions
  subscribe(table: string, callback: (payload: any) => void) {
    return this.supabase
      .channel(`public:${table}`)
      .on('postgres_changes', { event: '*', schema: 'public', table }, callback)
      .subscribe();
  }
}
```

### 5. Create Auth Guard

Protect routes that require authentication:

```bash
ng generate guard core/guards/auth
```

**`frontend/src/app/core/guards/auth.guard.ts`**:
```typescript
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { SupabaseService } from '../services/supabase.service';
import { map } from 'rxjs/operators';

export const authGuard = () => {
  const supabaseService = inject(SupabaseService);
  const router = inject(Router);

  return supabaseService.user$.pipe(
    map(user => {
      if (user) {
        return true;
      } else {
        router.navigate(['/login']);
        return false;
      }
    })
  );
};
```

### 6. Create Example Components

#### Login Component

```bash
ng generate component features/auth/login
```

**`frontend/src/app/features/auth/login/login.component.ts`**:
```typescript
import { Component } from '@angular/core';
import { FormBuilder, FormGroup, Validators } from '@angular/forms';
import { Router } from '@angular/router';
import { SupabaseService } from '../../../core/services/supabase.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.scss']
})
export class LoginComponent {
  loginForm: FormGroup;
  loading = false;
  errorMessage = '';

  constructor(
    private fb: FormBuilder,
    private supabaseService: SupabaseService,
    private router: Router
  ) {
    this.loginForm = this.fb.group({
      email: ['', [Validators.required, Validators.email]],
      password: ['', [Validators.required, Validators.minLength(6)]]
    });
  }

  async onSubmit() {
    if (this.loginForm.invalid) return;

    this.loading = true;
    this.errorMessage = '';

    const { email, password } = this.loginForm.value;
    const { error } = await this.supabaseService.signIn(email, password);

    if (error) {
      this.errorMessage = error.message;
      this.loading = false;
    } else {
      this.router.navigate(['/dashboard']);
    }
  }
}
```

**`frontend/src/app/features/auth/login/login.component.html`**:
```html
<div class="login-container">
  <h2>Login</h2>

  <form [formGroup]="loginForm" (ngSubmit)="onSubmit()">
    <div class="form-group">
      <label for="email">Email</label>
      <input
        type="email"
        id="email"
        formControlName="email"
        placeholder="Enter your email"
      />
      <div class="error" *ngIf="loginForm.get('email')?.invalid && loginForm.get('email')?.touched">
        Please enter a valid email
      </div>
    </div>

    <div class="form-group">
      <label for="password">Password</label>
      <input
        type="password"
        id="password"
        formControlName="password"
        placeholder="Enter your password"
      />
      <div class="error" *ngIf="loginForm.get('password')?.invalid && loginForm.get('password')?.touched">
        Password must be at least 6 characters
      </div>
    </div>

    <div class="error" *ngIf="errorMessage">{{ errorMessage }}</div>

    <button type="submit" [disabled]="loading || loginForm.invalid">
      {{ loading ? 'Loading...' : 'Login' }}
    </button>
  </form>
</div>
```

#### Dashboard Component (Protected)

```bash
ng generate component features/dashboard
```

**`frontend/src/app/features/dashboard/dashboard.component.ts`**:
```typescript
import { Component, OnInit, OnDestroy } from '@angular/core';
import { SupabaseService } from '../../core/services/supabase.service';
import { Router } from '@angular/router';
import { RealtimeChannel } from '@supabase/supabase-js';

@Component({
  selector: 'app-dashboard',
  templateUrl: './dashboard.component.html',
  styleUrls: ['./dashboard.component.scss']
})
export class DashboardComponent implements OnInit, OnDestroy {
  posts: any[] = [];
  loading = true;
  private subscription?: RealtimeChannel;

  constructor(
    private supabaseService: SupabaseService,
    private router: Router
  ) {}

  async ngOnInit() {
    await this.loadPosts();
    this.setupRealtimeSubscription();
  }

  async loadPosts() {
    this.loading = true;
    const { data, error } = await this.supabaseService.db('posts')
      .select('*')
      .order('created_at', { ascending: false });

    if (error) {
      console.error('Error loading posts:', error);
    } else {
      this.posts = data || [];
    }
    this.loading = false;
  }

  setupRealtimeSubscription() {
    this.subscription = this.supabaseService.subscribe('posts', (payload) => {
      console.log('Realtime update:', payload);
      this.loadPosts(); // Reload posts on any change
    });
  }

  async logout() {
    await this.supabaseService.signOut();
    this.router.navigate(['/login']);
  }

  ngOnDestroy() {
    this.subscription?.unsubscribe();
  }
}
```

### 7. Configure Routing

**`frontend/src/app/app-routing.module.ts`**:
```typescript
import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './features/auth/login/login.component';
import { DashboardComponent } from './features/dashboard/dashboard.component';
import { authGuard } from './core/guards/auth.guard';

const routes: Routes = [
  { path: '', redirectTo: '/dashboard', pathMatch: 'full' },
  { path: 'login', component: LoginComponent },
  { path: 'dashboard', component: DashboardComponent, canActivate: [authGuard] },
  { path: '**', redirectTo: '/dashboard' }
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
```

### 8. Update Project Structure

Organize your Angular app with this recommended structure:

```
frontend/
├── src/
│   ├── app/
│   │   ├── core/                    # Singleton services, guards, interceptors
│   │   │   ├── guards/
│   │   │   │   └── auth.guard.ts
│   │   │   └── services/
│   │   │       └── supabase.service.ts
│   │   ├── features/                # Feature modules
│   │   │   ├── auth/
│   │   │   │   ├── login/
│   │   │   │   └── register/
│   │   │   └── dashboard/
│   │   ├── shared/                  # Shared components, pipes, directives
│   │   │   ├── components/
│   │   │   └── pipes/
│   │   ├── app-routing.module.ts
│   │   ├── app.component.ts
│   │   └── app.module.ts
│   ├── environments/
│   │   ├── environment.ts
│   │   └── environment.prod.ts
│   └── index.html
├── angular.json
└── package.json
```

## Development Workflow

### Running the Full Stack

1. **Start Supabase services**:
   ```bash
   make up
   ```

2. **Run Angular dev server** (in a new terminal):
   ```bash
   cd frontend
   ng serve
   ```

3. **Access the application**:
   - Frontend: http://localhost:4200
   - API Gateway: http://localhost:8000
   - MailHog: http://localhost:8025

### Proxy Configuration (Optional)

To avoid CORS issues during development, create a proxy config:

**`frontend/proxy.conf.json`**:
```json
{
  "/api": {
    "target": "http://localhost:8000",
    "secure": false,
    "changeOrigin": true,
    "pathRewrite": {
      "^/api": ""
    }
  }
}
```

Update `angular.json`:
```json
{
  "serve": {
    "options": {
      "proxyConfig": "proxy.conf.json"
    }
  }
}
```

Run with proxy:
```bash
ng serve --proxy-config proxy.conf.json
```

## Common Use Cases

### Fetching Data with Row Level Security

```typescript
async getUserPosts(userId: string) {
  const { data, error } = await this.supabaseService
    .db('posts')
    .select('*')
    .eq('user_id', userId);

  return { data, error };
}
```

### Inserting Data

```typescript
async createPost(title: string, content: string) {
  const { data, error } = await this.supabaseService
    .db('posts')
    .insert([{ title, content }])
    .select();

  return { data, error };
}
```

### Uploading Files

```typescript
async uploadAvatar(file: File, userId: string) {
  const filePath = `avatars/${userId}/${Date.now()}_${file.name}`;

  const { data, error } = await this.supabaseService
    .storage
    .from('avatars')
    .upload(filePath, file);

  if (error) return { data: null, error };

  // Get public URL
  const { data: urlData } = this.supabaseService
    .storage
    .from('avatars')
    .getPublicUrl(filePath);

  return { data: urlData.publicUrl, error: null };
}
```

### Real-time Subscriptions

```typescript
subscribeToTable(table: string) {
  return this.supabaseService
    .subscribe(table, (payload) => {
      switch (payload.eventType) {
        case 'INSERT':
          console.log('New record:', payload.new);
          break;
        case 'UPDATE':
          console.log('Updated record:', payload.new);
          break;
        case 'DELETE':
          console.log('Deleted record:', payload.old);
          break;
      }
    });
}
```

## Testing

### Unit Testing Services

**`frontend/src/app/core/services/supabase.service.spec.ts`**:
```typescript
import { TestBed } from '@angular/core/testing';
import { SupabaseService } from './supabase.service';

describe('SupabaseService', () => {
  let service: SupabaseService;

  beforeEach(() => {
    TestBed.configureTestingModule({});
    service = TestBed.inject(SupabaseService);
  });

  it('should be created', () => {
    expect(service).toBeTruthy();
  });

  it('should have a user observable', (done) => {
    service.user$.subscribe(user => {
      expect(user).toBeDefined();
      done();
    });
  });
});
```

### E2E Testing

Install Cypress or Playwright for end-to-end testing:

```bash
ng add @cypress/schematic
```

## Production Build

### Build Angular App

```bash
cd frontend
ng build --configuration production
```

This creates optimized files in `frontend/dist/`.

### Deployment Options

1. **Static hosting**: Deploy `dist/` folder to Netlify, Vercel, or Cloudflare Pages
2. **Docker**: Create a Dockerfile to serve the Angular app with nginx
3. **Supabase hosting**: Use Supabase's edge functions with static hosting

### Environment Variables for Production

Update `environment.prod.ts` with your production Supabase URL and keys:

```typescript
export const environment = {
  production: true,
  supabase: {
    url: 'https://your-project-ref.supabase.co',
    anonKey: 'your-production-anon-key'
  }
};
```

## Troubleshooting

### CORS Issues

If you encounter CORS errors, ensure:
1. You're using the Kong Gateway URL (`http://localhost:8000`) not the direct service URLs
2. Your `docker/.env` has the correct `SITE_URL` and `URI_ALLOW_LIST` settings

### Auth Not Working

1. Check MailHog at http://localhost:8025 for confirmation emails
2. Verify `GOTRUE_MAILER_AUTOCONFIRM` in `docker/compose.yml` (set to `true` for development)
3. Check browser console for auth errors

### Real-time Not Connecting

1. Ensure Realtime service is running: `docker ps | grep realtime`
2. Check that your table has `REPLICA IDENTITY FULL` enabled
3. Verify RLS policies allow the current user to subscribe

## Additional Resources

- [Angular Documentation](https://angular.io/docs)
- [Supabase JavaScript Client](https://supabase.com/docs/reference/javascript/introduction)
- [Supabase Angular Tutorial](https://supabase.com/docs/guides/getting-started/tutorials/with-angular)
- [RxJS Documentation](https://rxjs.dev/)

## Next Steps

1. Implement user registration and password reset flows
2. Add form validation and error handling
3. Create reusable UI components
4. Set up state management (NgRx or Akita)
5. Add loading states and error boundaries
6. Implement file upload functionality
7. Add E2E tests with Cypress
