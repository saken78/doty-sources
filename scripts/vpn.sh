#!/bin/bash

LOG_FILE="/tmp/vpn-toggle.log"
ACTION="${1:-disable}"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

log() {
    echo "[$TIMESTAMP] $1" | tee -a "$LOG_FILE"
}

log "=== Script started ==="
log "Action: $ACTION"

if [[ "$ACTION" == "disable" ]]; then
    log "Connecting VPN (wg-quick down)..."
    kitty --title "VPN Toggle" sh -c "sudo wg-quick up wgcf-profile 2>&1 | tee -a '$LOG_FILE' && echo 'VPN CONNECTED' && echo 'Done! Press Enter to close...' && read"
    log "VPN DISABLED"
else
    log "Disconnecting VPN (wg-quick up)..."
    kitty --title "VPN Toggle" sh -c "sudo wg-quick down wgcf-profile 2>&1 | tee -a '$LOG_FILE' && echo 'VPN DISCONNECTED' && echo 'Done! Press Enter to close...' && read"
    log "VPN ENABLED"
fi

log "=== Script finished ==="
