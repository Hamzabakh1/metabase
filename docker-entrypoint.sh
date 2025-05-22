#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting Metabase..."

# Required for Heroku port binding
export MB_JETTY_PORT="${PORT:-3000}"

# If DATABASE_URL is set by Heroku, use it
if [[ -n "${DATABASE_URL:-}" ]]; then
  export MB_DB_CONNECTION_URI="$DATABASE_URL"
fi

exec java -jar /app/metabase.jar
