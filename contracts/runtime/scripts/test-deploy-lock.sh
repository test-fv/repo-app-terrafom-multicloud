#!/usr/bin/env bash

set -Eeuo pipefail

LOCK_FILE="/opt/runtime/deploy.lock"

#
# Guardar estado original
#

LOCK_EXISTED=false

if [[ -f "${LOCK_FILE}" ]]; then

    LOCK_EXISTED=true

    cp "${LOCK_FILE}" "${LOCK_FILE}.bak"

fi

cleanup() {

    rm -f "${LOCK_FILE}"

    if [[ "${LOCK_EXISTED}" == "true" ]]; then

        mv "${LOCK_FILE}.bak" "${LOCK_FILE}"

    fi

}

trap cleanup EXIT

#
# Simular despliegue en ejecución
#

touch "${LOCK_FILE}"

#
# Intentar lanzar otro deployment
#

if /opt/runtime/deploy.sh >/tmp/runtime-lock-test.log 2>&1; then

    exit 1

fi

grep -q "already running" /tmp/runtime-lock-test.log