#!/bin/bash
date=$(date '+%Y-%m-%d')
PGPASSWORD="database_password" pg_dump --host 127.0.0.1 --port 5432 -U database_user --blobs --verbose --file "DB_backup_$date.sql" database_name

# this command will backup database "database_name"
# 1) Than make this file executable by:
# $ chmod +x postgres_db_backup_daily.sh

# 2) enter crontab
# $ crontab -e
# 3) create dayli command
# 0 1 * * *   ./postgres_db_backup_daily.sh
