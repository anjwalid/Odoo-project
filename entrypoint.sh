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

check_config "db_host" "cb5ajfjosdpmil.cluster-czrs8kj4isg7.us-east-1.rds.amazonaws.com"
check_config "db_port" "5432"
check_config "db_user" "u6898p6uci08ut"
check_config "db_password" "pb7b7e6c8208469e4ae55db44c2d291a641a9a7b7ac15dd5cd293c8de50872fa1"

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
