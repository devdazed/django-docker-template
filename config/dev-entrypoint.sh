#!/usr/bin/env bash
set -e

# run migrations if the RUN_MIGRATIONS environment variable is set
if [ "$RUN_MIGRATIONS" = "1" ]
then
  python manage.py migrate
fi

# Execute Dockerfile CMD
exec "$@"
