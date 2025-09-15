# Modern Supabase Setup with Docker, Migrations & GitHub Actions

## Project Structure

```
project/
├── .github/
│   └── workflows/
│       ├── ci.yml
│       ├── local-dev-test.yml
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

# 5. Run migrations (if any exist)
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

## Development Commands

This project uses a Makefile for common operations:

```bash
# Start all services (Docker Compose)
make up

# Stop all services
make down

# Reset database and run migrations
make reset

# Run migrations only
make migrate

# Seed database
make seed

# View logs
make logs

# Open PostgreSQL shell
make shell-db

# Run tests
make test
```

## Service Endpoints

Once running, services are available at:

- **API Gateway**: http://localhost:8000
- **PostgREST API**: http://localhost:3000
- **Auth Service**: http://localhost:9999
- **Realtime**: http://localhost:4000
- **Storage**: http://localhost:5000
- **Database**: postgresql://localhost:5432
- **MailHog**: http://localhost:8025

## CI/CD Workflows

### Main CI (`ci.yml`)
- Uses Supabase CLI for testing
- Runs on push/PR to main branches
- Tests migrations and database operations

### Local Dev Test (`local-dev-test.yml`)
- Tests Docker Compose environment
- Validates service connectivity
- Can be triggered manually
- Comprehensive health checks

## Architecture

This setup uses Docker Compose with the latest Supabase service versions:

- **PostgreSQL**: 15.8.1.060
- **PostgREST**: v12.2.12
- **GoTrue (Auth)**: v2.177.0
- **Realtime**: v2.34.47
- **Storage API**: v1.25.7
- **Kong Gateway**: 3.9.1

## Tips & Best Practices

### Database
1. **Migration Naming**: Use sequential numbers (00001, 00002) for migration ordering
2. **RLS Policies**: Always enable Row Level Security on tables
3. **Indexes**: Create indexes for frequently queried columns
4. **Functions**: Keep database functions in separate files for reusability

### Development
5. **Local Testing**: Use `make up` for Docker environment, Supabase CLI for migrations
6. **Environment Files**: Keep `.env` files updated with proper secrets
7. **Service Health**: Check service endpoints are responding before running tests

### Deployment
8. **Testing**: Test migrations locally before deploying to production
9. **Rollback Plan**: Keep rollback scripts for critical migrations
10. **Monitoring**: Set up alerts for failed migrations in production
11. **Documentation**: Document complex migrations and their purposes

### Version Management
- Docker images are pinned to specific versions for security
- GitHub Actions use latest stable versions (v5)
- Update versions monthly or as needed for security patches