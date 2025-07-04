#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Your Neon PostgreSQL connection string
# IMPORTANT: For production, use environment variables from your hosting platform
# or CI/CD secrets instead of hardcoding these!
NEON_DB_URL=""

# --- Parse the connection string ---
DB_USERNAME=$(echo "$NEON_DB_URL" | sed -n 's/.*:\/\/\([^:]*\):.*@.*/\1/p')
DB_PASSWORD=$(echo "$NEON_DB_URL" | sed -n 's/.*:\/\/[^:]*:\([^@]*\)@.*/\1/p')
DB_HOST=$(echo "$NEON_DB_URL" | sed -n 's/.*@\([^/]*\)\/.*/\1/p' | sed 's/:.*//')
DB_DATABASE=$(echo "$NEON_DB_URL" | sed -n 's/.*\/\([^?]*\)\?.*/\1/p')

# Your JWT Secret Key
AUTH_JWT_SECRET=""

# Default environment for commands (can be overridden by specific commands)
APP_ENV="development"

# --- Export all environment variables so Dart programs can access them at runtime ---
export DB_HOST
export DB_DATABASE
export DB_USERNAME
export DB_PASSWORD
export SECRET_KEY
export APP_ENV # This will be 'development' by default for dev, 'production' for build

echo "Preparing environment for Dart Frog application:"
echo "  DB_HOST: $DB_HOST"
echo "  DB_DATABASE: $DB_DATABASE"
echo "  DB_USERNAME: $DB_USERNAME"
echo "  DB_PASSWORD: (hidden)"
echo "  SECRET_KEY: (hidden)"
echo "  APP_ENV: $APP_ENV"

# Main command dispatcher
case "$1" in
  dev)
    echo "Starting Dart Frog development server..."
    # All required env vars are now exported, so Dart Frog will pick them up
    dart_frog dev
    ;;
  build)
    echo "Building Dart Frog application for production..."
    # For build, specifically override APP_ENV to 'production' before running
    export APP_ENV="production"
    dart_frog build
    ;;
  migrate)
    echo "Running database migrations..."
    # Custom Dart scripts also read from Platform.environment now
    dart run bin/migrate.dart "${@:2}"
    ;;
  seed)
    echo "Running database seeding..."
    # Custom Dart scripts also read from Platform.environment now
    dart run bin/seed.dart "${@:2}"
    ;;
  *)
    echo "Usage: ./app_cli.sh <command>"
    echo "Commands:"
    echo "  dev       - Starts the Dart Frog development server."
    echo "  build     - Builds the Dart Frog application for production."
    echo "  migrate   - Runs database migrations."
    echo "  seed      - Seeds the database with initial data."
    exit 1
    ;;
esac