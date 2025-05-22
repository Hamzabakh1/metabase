#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting Metabase entrypoint..."

# --- CONFIGURABLE VARIABLES ---
MB_PLUGINS_DIR="${MB_PLUGINS_DIR:-/plugins}"
MB_JETTY_PORT="${PORT:-3000}"

# --- ENSURE SNOWFLAKE DRIVER AND DEPENDENCIES ARE PRESENT ---
if [ ! -f "$MB_PLUGINS_DIR/snowflake-jdbc-3.14.3.jar" ]; then
  echo "⬇️  Downloading Snowflake JDBC driver..."
  curl -L -o "$MB_PLUGINS_DIR/snowflake-jdbc-3.14.3.jar" \
    "https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.14.3/snowflake-jdbc-3.14.3.jar"
fi

if [ ! -f "$MB_PLUGINS_DIR/arrow-memory-8.0.0.jar" ]; then
  echo "⬇️  Downloading Apache Arrow memory dependency..."
  curl -L -o "$MB_PLUGINS_DIR/arrow-memory-8.0.0.jar" \
    "https://repo1.maven.org/maven2/org/apache/arrow/arrow-memory/8.0.0/arrow-memory-8.0.0.jar"
fi

# Add additional dependencies as needed

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
