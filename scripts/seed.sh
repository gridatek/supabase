#!/bin/bash

set -e

echo "🌱 Seeding database..."

# Only run in development
if [ "$ENVIRONMENT" = "production" ]; then
    echo "❌ Cannot run seed in production!"
    exit 1
fi

# Load environment variables
if [ -f .env.local ]; then
    export $(cat .env.local | xargs)
fi

# Run seed file
supabase db push --file supabase/seed.sql

echo "✅ Database seeded successfully!"