#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting Metabase entrypoint..."

# --- CONFIGURABLE VARIABLES ---
MB_PLUGINS_DIR="${MB_PLUGINS_DIR:-/plugins}"
SNOWFLAKE_PLUGIN_JAR="$MB_PLUGINS_DIR/snowflake.metabase-driver.jar"
SNOWFLAKE_PLUGIN_URL="https://downloads.metabase.com/driver/snowflake.metabase-driver.jar"
MB_JETTY_PORT="${PORT:-3000}"

# --- CREATE PLUGINS DIRECTORY IF NEEDED ---
mkdir -p "$MB_PLUGINS_DIR"

# --- ENSURE SNOWFLAKE DRIVER PLUGIN IS PRESENT ---
if [ ! -f "$SNOWFLAKE_PLUGIN_JAR" ]; then
  echo "🧩 Snowflake plugin not found. Downloading..."
  if curl --location --fail --output "$SNOWFLAKE_PLUGIN_JAR" "$SNOWFLAKE_PLUGIN_URL"; then
    echo "✅ Snowflake plugin downloaded to $SNOWFLAKE_PLUGIN_JAR"
  else
    echo "❌ ERROR: Failed to download the Snowflake plugin from $SNOWFLAKE_PLUGIN_URL" >&2
    exit 1
  fi
else
  echo "🧩 Snowflake plugin already present in $SNOWFLAKE_PLUGIN_JAR"
fi

# --- OPTIONAL: VERIFY MB_SITE_URL REACHABILITY ---
if [[ -n "${MB_SITE_URL:-}" ]]; then
  echo "🔍 Verifying MB_SITE_URL: $MB_SITE_URL"
  if curl --max-time 5 --silent --head --fail "$MB_SITE_URL" > /dev/null; then
    echo "✅ MB_SITE_URL is reachable."
  else
    echo "⚠️ WARNING: MB_SITE_URL is not reachable or invalid: $MB_SITE_URL"
    # Uncomment to enforce strict check
    # exit 1
  fi
else
  echo "⚠️ MB_SITE_URL is not set. Proceeding without site URL verification."
fi

# --- SET HEROKU PORT BINDING ---
export MB_JETTY_PORT

# --- IF HEROKU PROVIDES DATABASE_URL, CONFI_
