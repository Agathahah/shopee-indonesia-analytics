"""Shared PostgreSQL connection settings, read from the environment.

Set PGHOST, PGPORT, PGDATABASE, PGUSER, PGPASSWORD (see .env.example).
No password is stored in the repository.
"""

import os

DB_CONFIG = {
    "dbname": os.getenv("PGDATABASE", "nusacommerce"),
    "user": os.getenv("PGUSER", "nusacommerce_user"),
    "password": os.getenv("PGPASSWORD"),
    "host": os.getenv("PGHOST", "localhost"),
    "port": os.getenv("PGPORT", "5432"),
}
