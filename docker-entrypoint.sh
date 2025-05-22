#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting Metabase..."

# Set Heroku port binding
export MB_JETTY_PORT="${PORT:-3000}"

# If Heroku provides DATABASE_URL, configure Metabase DB connection
if [[ -n "${DATABASE_URL:-}" ]]; then
  export MB_DB_CONNECTION_URI="$DATABASE_URL"
fi

# Optional URL check (verify MB_SITE_URL is set and reachable)
if [[ -n "${MB_SITE_URL:-}" ]]; then
  echo "🔍 Verifying MB_SITE_URL: $MB_SITE_URL"

  # Using curl to check URL reachability
  if curl --max-time 5 --silent --head --fail "$MB_SITE_URL" > /dev/null; then
    echo "✅ MB_SITE_URL is reachable."
  else
    echo "⚠️ WARNING: MB_SITE_URL is not reachable or invalid: $MB_SITE_URL"
    # Optionally fail here if strict:
    # echo "❌ Exiting due to invalid MB_SITE_URL."
    # exit 1
  fi
else
  echo "⚠️ MB_SITE_URL is not set. Proceeding without site URL verification."
fi

exec java -jar /app/metabase.jar
