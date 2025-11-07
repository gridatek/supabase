# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This project uses a Makefile for common operations:

```bash
# Start all services (Docker-based Supabase stack)
make up

# Stop all services
make down

# Reset database (removes volumes) and run migrations
make reset

# Run migrations only
make migrate

# Seed database
make seed

# View logs (follows output)
make logs

# Open PostgreSQL shell
make shell-db

# Run tests (requires npm/package.json)
make test
```

## Architecture Overview

This is a Docker-based Supabase setup for local development with dual migration tooling support.

### Core Services (docker/compose.yml)
All services run via Docker Compose with health checks and automatic restarts:

- **PostgreSQL Database** (port 5432): Supabase Postgres 15.8.1.060 with extensions
- **PostgREST API** (port 3000): Auto-generated REST API v12.2.12 exposing public, storage, auth schemas
- **Supabase Auth** (port 9999): GoTrue v2.177.0 for authentication with OAuth support
- **Supabase Realtime** (port 4000): v2.34.47 for real-time subscriptions via RLS
- **Supabase Storage** (port 5000): v1.25.7 for file storage (file backend, 50MB limit)
- **Kong Gateway** (port 8000): v3.9.1 API gateway routing all services
- **MailHog** (ports 1025/8025): SMTP testing server for development emails

### Dual Tooling Approach

This project supports both Docker Compose and Supabase CLI workflows:

**Docker Compose (via Makefile):**
- Uses `docker/compose.yml` for service orchestration
- Direct container management with `make up/down`
- Database shell via `docker exec` into supabase-db container

**Supabase CLI (via scripts):**
- `scripts/migrate.sh`: Runs `supabase db push` for local or production
- `scripts/seed.sh`: Applies seed data via `supabase db push --file`
- Checks for running Supabase instance and starts if needed
- Supports ENVIRONMENT variable for production deployment

### Database Management

**Migration Files:** `supabase/migrations/` with 5-digit sequential numbering (00000, 00001, etc.)
- Existing migrations: 00000_create_helper_functions.sql, 00001_create_users_table.sql, 00002_create_posts_table.sql, 00003_add_user_profiles.sql
- Applied via `supabase db push --local` (CLI) or Supabase's built-in migration system

**Configuration:** `supabase/config.toml`
- API port: 54321 (Supabase CLI default, differs from Docker port 3000)
- DB port: 54322 (Supabase CLI default, differs from Docker port 5432)
- Exposed schemas: public, storage
- GitHub OAuth configured via environment variables

### Environment Configuration

Required environment variables in `docker/.env`:
- `POSTGRES_PASSWORD`, `POSTGRES_DB`: Database credentials
- `JWT_SECRET`, `ANON_KEY`, `SERVICE_KEY`: Auth tokens (generate with `openssl rand -base64 32`)
- `API_EXTERNAL_URL`, `SITE_URL`, `URI_ALLOW_LIST`: URL configuration
- Email settings for MailHog (SMTP_HOST=mailhog, SMTP_PORT=1025)

Optional `.env.local` for scripts:
- `ENVIRONMENT`: Set to "production" for production migrations
- `PROJECT_ID`: Supabase project reference for production deployment

### CI/CD Workflows

**`.github/workflows/ci.yml`:**
- Runs on push/PR to main/develop branches
- Uses Supabase CLI to start local instance, apply migrations, and verify with `supabase db diff`
- Includes separate migration-check job with dry-run testing

**Other workflows:** local-dev-test.yml, deploy.yml for environment-specific testing

## Development Workflow

1. **Initial Setup:**
   ```bash
   cp docker/.env.example docker/.env
   # Edit docker/.env with real secrets
   make up
   # Wait for services to be healthy (~5 seconds)
   ```

2. **Creating Migrations:**
   - Create new file: `supabase/migrations/00004_description.sql`
   - Use sequential numbering (next number after highest existing)
   - Apply with `make migrate` (runs `scripts/migrate.sh`)

3. **Database Access:**
   - Shell: `make shell-db` (connects as postgres user)
   - Connection string: `postgresql://localhost:5432/supabase`
   - Note: Supabase CLI uses different ports (54322) than Docker (5432)

4. **Testing Migrations:**
   - Locally: `make reset` (full reset) or `make migrate` (incremental)
   - CI: Automatic validation on push/PR via GitHub Actions

## Migration Best Practices

- Use 5-digit sequential numbering (00000, 00001, 00002, etc.)
- Helper functions go in 00000_create_helper_functions.sql for reusability
- Enable Row Level Security (RLS) on all tables
- Test locally before pushing (CI will validate but catch issues earlier)
- Scripts support production deployment via ENVIRONMENT=production and PROJECT_ID variables

## Service Access

When services are running (`make up`):
- **API Gateway:** http://localhost:8000 (main entry point)
- **Direct PostgREST:** http://localhost:3000
- **Auth:** http://localhost:9999
- **Realtime:** http://localhost:4000
- **Storage:** http://localhost:5000
- **Database:** postgresql://postgres:password@localhost:5432/supabase
- **MailHog UI:** http://localhost:8025

Note: Supabase CLI uses different port scheme (54321, 54322, 54323) when using `supabase start`