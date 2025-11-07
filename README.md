# Modern Supabase Setup with Docker, Migrations & GitHub Actions

## Project Structure

```
project/
├── .github/
│   └── workflows/          # CI/CD workflows
├── supabase/
│   ├── migrations/         # Database migrations
│   ├── seed.sql           # Seed data (optional)
│   └── config.toml        # Supabase configuration
├── docs/                  # Documentation
├── package.json          # npm scripts
├── .gitignore
└── README.md
```

## Quick Start Guide

### Prerequisites
- [Docker Desktop](https://docs.docker.com/desktop/) installed and running
- Node.js 18+ and npm

### Start in 3 Commands

```bash
git clone https://github.com/gridatek/supabase.git
cd supabase
npm run dev

# That's it! Supabase is running
```

### Seed Test Data

```bash
# Reset database and load seed data (test users & posts)
npm run seed
```

**Test Users:**
- `alice@example.com` / `password123`
- `bob@example.com` / `password123`
- `carol@example.com` / `password123`

## Development Commands

All commands work on Windows, Mac, and Linux:

```bash
# Start Supabase locally
npm run dev

# Stop Supabase
npm run stop

# Reset database (drops all data and re-runs migrations)
npm run reset

# Apply migrations locally
npm run migrate

# Apply migrations to production
npm run migrate:prod

# View database diff
npm run diff

# Check service status
npm run status

# View logs
npm run logs

# Open database shell
npm run shell

# Generate TypeScript types
npm run types

# Link to production project
npm run link

# Seed test data (users & posts)
npm run seed
```

## Service Endpoints

Once running (`npm run dev`), services are available at:

- **API Gateway**: http://localhost:54321 (all services route through here)
- **Database**: Check `npm run status` for connection string
- **Email UI (Inbucket)**: http://localhost:54324

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

This setup uses Supabase CLI which automatically manages:

- **PostgreSQL** - Database with extensions
- **PostgREST** - Auto-generated REST API
- **GoTrue** - Authentication service
- **Realtime** - Real-time subscriptions
- **Storage** - File storage service
- **Kong** - API gateway

## Best Practices

### Migrations
- Use 5-digit sequential numbering (00000, 00001, 00002, etc.)
- Test locally with `npm run reset` before production
- Always enable Row Level Security (RLS) on tables
- Use `npm run diff` to check changes before applying

### Development
- Run `npm run status` to check all services
- Use `npm run logs` to debug issues
- Generate TypeScript types with `npm run types`
- Link to production with `npm run link`