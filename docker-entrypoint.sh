#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting Metabase entrypoint..."

# --- CONFIGURABLE VARIABLES ---
MB_PLUGINS_DIR="${MB_PLUGINS_DIR:-/plugins}"
MB_JETTY_PORT="${PORT:-3000}"

# --- OPTIONAL: VERIFY MB_SITE_URL REACHABILITY ---
if [[ -n "${MB_SITE_URL:-}" ]]; then
  echo "🔍 Verifying MB_SITE_URL: $MB_SITE_URL"
  if curl --max-time 5 --silent --head --fail "$MB_SITE_URL" > /dev/null; then
    echo "✅ MB_SITE_URL is reachable."
  else
    echo "⚠️ WARNING: MB_SITE_URL is not reachable or invalid: $MB_SITE_URL"
  fi
else
  echo "⚠️ MB_SITE_URL is not set. Proceeding without site URL verification."
fi

# --- SET HEROKU PORT BINDING ---
export MB_JETTY_PORT

# --- IF HEROKU PROVIDES DATABASE_URL, CONFIGURE METABASE DB CONNECTION ---
if [[ -n "${DATABASE_URL:-}" ]]; then
  export MB_DB_CONNECTION_URI="$DATABASE_URL"
fi

# --- VERIFY METABASE IS PRESENT ---
if [ ! -f /app/metabase.jar ]; then
  echo "❌ ERROR: Metabase JAR not found at /app/metabase.jar" >&2
  exit 1
fi

echo "🚀 Launching Metabase..."
exec java -jar /app/metabase.jar
