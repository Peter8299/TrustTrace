#!/bin/sh
# Container entrypoint.
#
#   web (default)  -> serve the web UI on 0.0.0.0:8000
#   <anything else> -> run that `trusttrace` CLI subcommand
#
# The UI must bind 0.0.0.0 so the mapped port is reachable from the host, and
# TrustTrace refuses a non-loopback bind without an auth token. So if the
# operator did not supply TRUSTTRACE_WEB_TOKEN, generate one for this run and
# print how to reach the UI - secure by default, still one-command to start.
set -e

if [ "$1" = "web" ]; then
    shift
    if [ -z "${TRUSTTRACE_WEB_TOKEN}" ]; then
        TRUSTTRACE_WEB_TOKEN="$(python -c 'import secrets; print(secrets.token_urlsafe(24))')"
        export TRUSTTRACE_WEB_TOKEN
        echo "============================================================"
        echo " TrustTrace web UI"
        echo " No TRUSTTRACE_WEB_TOKEN was set - generated one for this run:"
        echo
        echo "     ${TRUSTTRACE_WEB_TOKEN}"
        echo
        echo " Open (through your mapped port, e.g. -p 8000:8000):"
        echo "     http://localhost:8000/?token=${TRUSTTRACE_WEB_TOKEN}"
        echo
        echo " Set TRUSTTRACE_WEB_TOKEN yourself to pin a stable token."
        echo "============================================================"
    fi
    exec trusttrace web --host 0.0.0.0 --port 8000 "$@"
fi

exec trusttrace "$@"
