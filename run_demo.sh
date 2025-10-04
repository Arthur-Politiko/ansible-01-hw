#!/usr/bin/env bash
set -euo pipefail # fail on error, undefined var, or pipe error

# Simple helper to: bring up docker-compose, run ansible-playbook and tear down containers.
# Usage:
#   ./run_demo.sh                 # brings up containers, runs playbook, brings them down
#   KEEP_ON_EXIT=1 ./run_demo.sh  # brings up containers, runs playbook, leaves containers running

initial() {
  ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  DOCKER_DIR="$ROOT_DIR/docker"
  PLAYBOOK_DIR="$ROOT_DIR/playbook"
  COMPOSE_FILE="$DOCKER_DIR/docker-compose.yml"
  INVENTORY_FILE="$PLAYBOOK_DIR/inventory/prod.yml"
  PLAYBOOK_FILE="$PLAYBOOK_DIR/site.yml"
  echo "project root: $ROOT_DIR"
}

check() {
  docker -v >/dev/null 2>&1 || { echo >&2 "docker is required but not found in PATH"; exit 1; }
  docker compose -v >/dev/null 2>&1 || { echo >&2 "docker compose is required but not found in PATH"; exit 1; }
  ansible-playbook --version >/dev/null 2>&1 || { echo >&2 "ansible-playbook is required but not found in PATH"; exit 1; }
}

provision() {
  #echo "Provisioning..."
  echo "Starting docker compose (up --build -d) from $DOCKER_DIR"
  docker compose -f "$COMPOSE_FILE" up --build -d
  echo "Waiting a few seconds for services to initialize..."
  sleep 5
}

# HOSTS=$( tr -d ' ' < playbook/inventory/prod.yml | grep -E "(ansible_host|ansible_port)" | sed 'N;s/\n/ /' )
# for i in {1..3}; do
#   echo "Attempt $i: Checking SSH connectivity to ansible@localhost:2222..."
#   RET=$( ssh ansible@localhost -p 2222 -o StrictHostKeyChecking=false 2>/dev/null exit || echo $? )
#   if [ "$RET" = "0" ]; then
#     echo "SSH connection successful."
#     break
#   else
#     echo "SSH connection failed with exit code $RET. Retrying in 5 seconds..."
#     sleep 5
#   fi
# done

deploy() {
  echo "Running Ansible playbook from $PLAYBOOK_DIR"
  pushd "$PLAYBOOK_DIR" >/dev/null
  set +e
  #ansible-playbook -i "$INVENTORY_FILE" "$PLAYBOOK_FILE --ask-vault-pass " 
  #pwd
#   [ -f $PLAYBOOK_FILE ] || { echo >&2 "Playbook file $PLAYBOOK_FILE not found"; exit 1; }
#   [ -f $INVENTORY_FILE ] || { echo >&2 "Inventory file $INVENTORY_FILE not found"; exit 1; }
#   [ -f ./key/vault.key ] || { echo >&2 "Vault key file ./key/vault.key not found"; exit 1; }

  cat ./key/vault.key | setsid ansible-playbook -i $INVENTORY_FILE $PLAYBOOK_FILE --ask-vault-pass 
  
  RET=$?
  set -e
  popd >/dev/null
  if [ $RET -ne 0 ]; then
    echo "Ansible playbook failed with exit code $RET" >&2
    exit $RET
  fi
  echo "Ansible playbook finished successfully"
}

cleanup() {
  if [ "${KEEP_ON_EXIT:-}" = "1" ]; then
    echo "KEEP_ON_EXIT=1 set — leaving containers running"
    return
  fi
  echo "Stopping containers (docker-compose down)..."
  docker compose -f "$COMPOSE_FILE" down || true
}

finish() {
  #echo "Demo finished successfully."
  # If user requested to keep containers running, disable trap and exit
  if [ "${KEEP_ON_EXIT:-}" = "1" ]; then
    trap - EXIT    # disable trap (set default action on EXIT)
    echo "Containers left running. Use 'docker compose -f "$COMPOSE_FILE" down' to stop them." 
    exit 0
  fi
}

trap cleanup EXIT       # ensure cleanup on script exit

# ---- main ----
initial
check
provision
deploy
finish
# Explicit cleanup (trap will also run on normal exit)
cleanup

exit 0
