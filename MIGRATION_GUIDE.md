# Migration Guide: Simplified Cross-Platform Setup

This project has been simplified to use **only Supabase CLI** with npm scripts. No more Makefiles, bash scripts, or Docker Compose files needed!

## What Changed

### ✅ Before (Complex)
- Required Make (not available on Windows by default)
- Used bash scripts (`scripts/migrate.sh`, `scripts/seed.sh`)
- Manual Docker Compose management
- Different commands for different platforms

### ✅ After (Simple)
- **Supabase CLI only** - works on Windows, Mac, Linux
- **npm scripts** - familiar to all developers
- **No bash scripts** - pure cross-platform
- **Same commands everywhere**

## Quick Start (New Way)

```bash
# 1. Install Supabase CLI globally
npm install -g supabase

# 2. Start everything
npm run dev

# 3. Check status
npm run status
```

That's it! No environment files, no Docker commands, no Make needed.

## Command Comparison

| Old Command | New Command | Description |
|-------------|-------------|-------------|
| `make up` | `npm run dev` | Start Supabase |
| `make down` | `npm run stop` | Stop Supabase |
| `make reset` | `npm run reset` | Reset database |
| `make migrate` | `npm run migrate` | Run migrations |
| `make logs` | `npm run logs` | View logs |
| `make shell-db` | `npm run shell` | Database shell |
| N/A | `npm run status` | Check status |
| N/A | `npm run types` | Generate types |

## What Was Removed

- ❌ `Makefile` - Replaced with `package.json` scripts
- ❌ `scripts/migrate.sh` - Supabase CLI handles this
- ❌ `scripts/seed.sh` - Use Supabase CLI directly
- ❌ `docker/compose.yml` - Supabase CLI manages Docker
- ❌ `docker/.env` - Configuration in `supabase/config.toml`

## What Stays

- ✅ `supabase/migrations/` - Your migrations
- ✅ `supabase/config.toml` - All configuration
- ✅ `.github/workflows/` - CI/CD (updated to use npm scripts)
- ✅ Cross-platform compatibility (better than before!)

## Port Changes

| Service | Old Port | New Port |
|---------|----------|----------|
| API Gateway | 8000 | 54321 |
| Database | 5432 | 54322 |
| Email UI | 8025 | 54324 |

## Benefits

1. **True Cross-Platform** - Works identically on Windows, Mac, Linux
2. **Simpler Setup** - Just install Supabase CLI and run
3. **No Dependencies** - No Make, no bash, no manual Docker
4. **Better DX** - Familiar npm commands for all developers
5. **Maintained by Supabase** - CLI is officially supported

## For Template Users

This project is now a perfect template! Users can:

```bash
# Clone and start in 3 commands
git clone <your-repo>
cd <your-repo>
npm run dev
```

No platform-specific instructions needed!
