# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This project uses npm scripts with Supabase CLI (cross-platform compatible):

```bash
# Start Supabase locally (starts all services)
npm run dev

# Stop all services
npm run stop

# Reset database and re-run migrations
npm run reset

# Apply migrations locally
npm run migrate

# Apply migrations to production
npm run migrate:prod

# View service status
npm run status

# View logs
npm run logs

# Open database shell
npm run shell

# Generate TypeScript types
npm run types

# Seed test data (users & posts)
npm run seed
```

## Test Data

Run `npm run seed` to populate the database with:
- **3 test users** (alice, bob, carol) - Password: `password123`
- **6 sample posts** (mix of published and draft)
- **Follow relationships** between users

Perfect for development and testing!

## Architecture Overview

This is a Supabase CLI-based setup for local development. The CLI manages all Docker containers automatically.

### Core Services
All services are managed by Supabase CLI and run in Docker automatically:

- **PostgreSQL Database** (port 54322): Postgres with Supabase extensions
- **PostgREST API** (port 54321): Auto-generated REST API
- **Supabase Auth** (port 54321): Authentication service with OAuth support
- **Supabase Realtime** (port 54321): Real-time subscriptions via RLS
- **Supabase Storage** (port 54321): File storage service
- **Kong Gateway** (port 54321): API gateway routing (main entry point)
- **Inbucket** (port 54324): Email testing UI for development

### Database Management

**Migration Files:** `supabase/migrations/` with 5-digit sequential numbering (00000, 00001, etc.)
- Existing migrations: 00000_create_helper_functions.sql, 00001_create_users_table.sql, 00002_create_posts_table.sql, 00003_add_user_profiles.sql
- Applied via `npm run migrate` which runs `supabase db push --local`
- Production: `npm run migrate:prod` runs `supabase db push`

**Configuration:** `supabase/config.toml`
- All Supabase CLI settings
- Database version, ports, schemas
- Auth providers and settings
- Storage configuration

### Environment Configuration

All configuration is in `supabase/config.toml`. No environment files needed for local development.

For production deployment:
- Set `SUPABASE_ACCESS_TOKEN` for authentication
- Set `PROJECT_ID` for your Supabase project reference
- Run `npm run link` to link to production project

### CI/CD Workflows

**`.github/workflows/ci.yml`:**
- Tests migrations with Supabase CLI
- Runs on all platforms (Linux, Mac, Windows)

**`.github/workflows/docker-stack-test.yml`:**
- Tests Docker stack compatibility
- Cross-platform testing

**`.github/workflows/angular-integration.yml`:**
- Tests Angular frontend integration (if exists)
- Creates test project if not present

**`.github/workflows/deploy.yml`:**
- Deploys migrations to production
- Manual trigger only

## Development Workflow

1. **Initial Setup:**
   ```bash
   npm install -g supabase
   npm run dev
   ```

2. **Creating Migrations:**
   - Create new file: `supabase/migrations/00004_description.sql`
   - Use sequential numbering (next number after highest existing)
   - Apply with `npm run migrate`

3. **Database Access:**
   - Shell: `npm run shell`
   - Check status: `npm run status`
   - View connection string in status output

4. **Testing Migrations:**
   - Locally: `npm run reset` (full reset) or `npm run migrate` (incremental)
   - View diff: `npm run diff`
   - CI: Automatic validation on push/PR via GitHub Actions

## Migration Best Practices

- Use 5-digit sequential numbering (00000, 00001, 00002, etc.)
- Helper functions go in 00000_create_helper_functions.sql for reusability
- Enable Row Level Security (RLS) on all tables
- Test locally with `npm run diff` before applying
- Use `npm run reset` to test migrations from scratch

## Service Access

When services are running (`npm run dev`):
- **API Gateway:** http://localhost:54321 (main entry point via Kong)
- **Database:** Check `npm run status` for connection string
- **Email UI (Inbucket):** http://localhost:54324

All services are accessible through port 54321 (Kong gateway)