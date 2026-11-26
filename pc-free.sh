#!/usr/bin/env bash

set -euo pipefail

COMPOSE_FILE="windows11.yml"

case "${1:-status}" in
  start)
    if [ ! -e /dev/kvm ]; then
      echo "Error: /dev/kvm is unavailable. KVM is required to run Windows."
      exit 1
    fi
    docker compose -f "$COMPOSE_FILE" up -d
    echo "Windows is starting. Open port 8006 in the Codespaces Ports tab."
    ;;
  stop)
    docker stop windows
    echo "Windows stopped. The browser will not restart it."
    ;;
  restart)
    docker restart windows
    echo "Windows restarted."
    ;;
  status)
    docker inspect --format 'running={{.State.Running}} restarting={{.State.Restarting}} restarts={{.RestartCount}} health={{if .State.Health}}{{.State.Health.Status}}{{else}}none{{end}}' windows 2>/dev/null \
      || echo "Windows container is not created."
    ;;
  logs)
    docker logs --tail 100 windows
    ;;
  *)
    echo "Usage: bash pc-free.sh {start|stop|restart|status|logs}"
    exit 2
    ;;
esac
