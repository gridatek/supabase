#!/bin/bash

set -e

echo "🚀 Running Supabase migrations..."

# Load environment variables
if [ -f .env.local ]; then
    export $(cat .env.local | xargs)
fi

# Check if running locally or in production
if [ "$ENVIRONMENT" = "production" ]; then
    echo "Running migrations in production..."
    supabase db push --project-ref $PROJECT_ID
else
    echo "Running migrations locally..."

    # Start Supabase if not running
    if ! supabase status 2>/dev/null | grep -q "RUNNING"; then
        echo "Starting Supabase..."
        supabase start
    fi

    # Run all migrations
    echo "Applying all migrations..."
    supabase db push --local
fi

echo "✅ Migrations completed successfully!"