# Use the official Metabase Enterprise image
FROM metabase/metabase-enterprise:v1.53.14

# Set workdir for clarity
WORKDIR /app

# Copy custom entrypoint script
COPY docker-entrypoint.sh /app/docker-entrypoint.sh

# Ensure entrypoint has correct permissions
RUN chmod +x /app/docker-entrypoint.sh

# Use the custom entrypoint
ENTRYPOINT ["/app/docker-entrypoint.sh"]
