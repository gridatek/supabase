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
├── docs/                  # Documentation (ordered guides)
├── package.json          # npm scripts
├── .gitignore
└── README.md
```

## Quick Start Guide

### Prerequisites
- [Docker Desktop](https://docs.docker.com/desktop/) installed and running (required for local development)
- Node.js 18+ and npm
- **Note**: GitHub Actions automatically sets up Docker on all platforms (Ubuntu, Windows, macOS)

### Start in 3 Commands

```bash
git clone https://github.com/gridatek/supabase.git
cd supabase
npm run dev

# That's it! Supabase is running on all platforms
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
- **Multi-platform testing**: Ubuntu, Windows, macOS
- **Automated Docker setup**: Uses `docker/setup-docker-action` for cross-platform compatibility
- **Database testing**: Runs migrations, checks diff, and validates data
- **Health checks**: Tests API endpoints and database connectivity
- **Dogfooding**: Uses same npm commands as local development

The workflow includes an optional health check step that verifies:
- API services are responding
- Database tables are accessible
- Seed data is loaded correctly

Users can remove the health check step if not needed.

### Angular Integration (`angular-integration.yml`)
- Only runs when frontend/ or supabase/ directories change
- Tests Angular app build and unit tests
- Validates integration with Supabase backend

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

## Documentation

Comprehensive guides are available in the `docs/` folder:

1. **[Getting Started](./docs/01_GETTING_STARTED.md)** - Installation, setup, and first steps
2. **[Migrations](./docs/02_MIGRATIONS.md)** - Database migrations and schema management
3. **[CI/CD](./docs/03_CI_CD.md)** - GitHub Actions workflows and automation
4. **[Deployment](./docs/04_DEPLOYMENT.md)** - Production deployment guide
5. **[Frontend Integration](./docs/05_FRONTEND_INTEGRATION.md)** - Add Angular frontend to the template

📖 **[View all documentation](./docs/README.md)**

## What You Get

✅ **Cross-platform**: Works on Windows, Mac, and Linux
✅ **Docker-based**: Local development with all Supabase services
✅ **Version-controlled migrations**: Track database changes in git
✅ **Seed data**: Test users and data for development
✅ **Multi-platform CI/CD**: Automated testing on Ubuntu, Windows, macOS
✅ **Health checks**: Automated API and database validation
✅ **Production ready**: Deploy to Supabase with one command
✅ **Well documented**: Comprehensive guides for every feature