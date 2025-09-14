# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

This project uses a Makefile for common operations:

```bash
# Start all services (Docker-based Supabase stack)
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

## Architecture Overview

This is a modern Supabase setup using Docker for local development. The architecture consists of:

### Core Services (docker/docker-compose.yml)
- **PostgreSQL Database** (port 5432): Main database with Supabase extensions
- **PostgREST API** (port 3000): Auto-generated REST API from database schema
- **Supabase Auth** (port 9999): Authentication service (GoTrue)
- **Supabase Realtime** (port 4000): Real-time subscriptions
- **Supabase Storage** (port 5000): File storage service
- **Kong Gateway** (port 8000): API gateway and routing
- **MailHog** (ports 1025/8025): Email testing server

### Database Management
- **Migrations**: Located in `supabase/migrations/` with sequential numbering (00001, 00002, etc.)
- **Configuration**: `supabase/config.toml` for local Supabase settings
- **Migration Script**: `scripts/migrate.sh` handles both local and production migrations

### Key Configuration Files
- `docker/docker-compose.yml`: Complete Supabase stack definition
- `supabase/config.toml`: Supabase CLI configuration
- `Makefile`: Development commands and shortcuts

## Development Workflow

1. **Local Setup**: Use `make up` to start all services via Docker
2. **Database Changes**: Create sequential migration files in `supabase/migrations/`
3. **Apply Migrations**: Use `make migrate` or `scripts/migrate.sh`
4. **Testing**: Use `make test` (requires npm)

## Environment Management

The project expects environment variables for:
- Database credentials (POSTGRES_PASSWORD, POSTGRES_DB)
- JWT secrets and API keys (JWT_SECRET, ANON_KEY, SERVICE_KEY)
- External OAuth providers (GITHUB_CLIENT_ID, GITHUB_CLIENT_SECRET)

Environment files should be copied from examples:
- `cp docker/.env.example docker/.env`
- `cp .env.example .env.local`

## Migration Best Practices

- Use sequential numbering for migration files (00001, 00002, etc.)
- Enable Row Level Security (RLS) on all tables
- Keep database functions in separate files for reusability
- Test migrations locally before production deployment