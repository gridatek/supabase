# Modern Supabase Setup with Docker, Migrations & GitHub Actions

## Project Structure

```
project/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       └── deploy.yml
├── supabase/
│   ├── migrations/
│   │   ├── 00001_create_users_table.sql
│   │   ├── 00002_create_posts_table.sql
│   │   └── 00003_add_user_profiles.sql
│   ├── seed.sql
│   ├── functions/
│   │   └── handle_new_user.sql
│   └── config.toml
├── docker/
│   ├── compose.yml
│   └── .env.example
├── scripts/
│   ├── migrate.sh
│   └── seed.sh
├── .env.local
├── .gitignore
├── Dockerfile
└── README.md
```

## Quick Start Guide

```bash
# 1. Clone the repository
git clone <your-repo>
cd <your-project>

# 2. Copy environment files
cp docker/.env.example docker/.env
cp .env.example .env.local

# 3. Generate secrets
# For JWT_SECRET, ANON_KEY, and SERVICE_KEY:
openssl rand -base64 32

# 4. Start services with Docker
make up

# 5. Run migrations
make migrate

# 6. Seed database (optional)
make seed

# 7. Install Supabase CLI (for local development)
npm install -g supabase

# 8. Initialize Supabase project
supabase init

# 9. Link to remote project (if you have one)
supabase link --project-ref your-project-id

# 10. Start development
npm run dev
```

## Tips & Best Practices

1. **Migration Naming**: Use sequential numbers (00001, 00002) for migration ordering
2. **RLS Policies**: Always enable Row Level Security on tables
3. **Indexes**: Create indexes for frequently queried columns
4. **Functions**: Keep database functions in separate files for reusability
5. **Testing**: Test migrations locally before deploying to production
6. **Rollback Plan**: Keep rollback scripts for critical migrations
7. **Monitoring**: Set up alerts for failed migrations in production
8. **Documentation**: Document complex migrations and their purposes