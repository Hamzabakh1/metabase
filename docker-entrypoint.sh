#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting Metabase with custom JDBC setup..."

export MB_JETTY_PORT="${PORT:-3000}"

MB_PLUGINS_DIR="/app/plugins"
mkdir -p "$MB_PLUGINS_DIR"

# Download JDBC driver if missing
if [ ! -f "$MB_PLUGINS_DIR/snowflake-jdbc-3.14.3.jar" ]; then
  echo "⬇️  Downloading Snowflake JDBC driver..."
  curl -L -o "$MB_PLUGINS_DIR/snowflake-jdbc-3.14.3.jar" "https://repo1.maven.org/maven2/net/snowflake/snowflake-jdbc/3.14.3/snowflake-jdbc-3.14.3.jar"
fi

if [ ! -f "$MB_PLUGINS_DIR/arrow-memory-8.0.0.jar" ]; then
  echo "⬇️  Downloading Apache Arrow dependency..."
  curl -L -o "$MB_PLUGINS_DIR/arrow-memory-8.0.0.jar" "https://repo1.maven.org/maven2/org/apache/arrow/arrow-memory/8.0.0/arrow-memory-8.0.0.jar"
fi

if [[ -n "${MB_SITE_URL:-}" ]]; then
  echo "🔍 Verifying MB_SITE_URL: $MB_SITE_URL"
  if curl --max-time 5 --silent --head --fail "$MB_SITE_URL" > /dev/null; then
    echo "✅ MB_SITE_URL is reachable."
  else
    echo "⚠️ WARNING: MB_SITE_URL is not reachable or invalid."
  fi
fi

exec java -cp "/app/plugins/*:/app/metabase.jar" metabase.core
