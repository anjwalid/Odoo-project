#!/bin/bash

set -e

# Paramètres de base de données
DB_ARGS=()
function check_config() {
    param="$1"
    value="$2"
    if grep -q -E "^\s*\b${param}\b\s*=" "$ODOO_RC" ; then
        value=$(grep -E "^\s*\b${param}\b\s*=" "$ODOO_RC" | cut -d " " -f3 | sed 's/["\n\r]//g')
    fi
    DB_ARGS+=("--${param}")
    DB_ARGS+=("${value}")
}

check_config "db_host" "c9mq4861d16jlm.cluster-czrs8kj4isg7.us-east-1.rds.amazonaws.com"
check_config "db_port" "5432"
check_config "db_user" "uem41k4fff5jm7"
check_config "db_password" "p4e88aa0c057d2b552198db015ef39d1678187af361a3f8fd748041544fe23c0c"

case "$1" in
    -- | odoo)
        shift
        if [[ "$1" == "scaffold" ]] ; then
            exec odoo "$@"
        else
            wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
            exec odoo "$@" "${DB_ARGS[@]}"
        fi
        ;;
    -*)
        wait-for-psql.py "${DB_ARGS[@]}" --timeout=30
        exec odoo "$@" "${DB_ARGS[@]}"
        ;;
    *)
        exec "$@"
esac

exit 1
