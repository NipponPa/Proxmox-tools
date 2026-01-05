#!/bin/bash

#Cloudflare Token
CF_TOKEN="token_here"

# Log location
LOG_DIR="/cloudflare"
LOG_FILE="$LOG_DIR/cloudflare.log"
mkdir -p "$LOG_DIR"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

WAN_IP=$(curl -s https://api.ipify.org)
if [[ -z "$WAN_IP" ]]; then
    log "ERROR: Failed to fetch WAN IP"
    exit 1
fi

# Domains to update
# Format: "full.domain.com proxied"
# proxied=true  -> Cloudflare proxy enabled
# proxied=false -> DNS only
DOMAINS=(
    "domain.here true"
    "domain.here false"
)

for ENTRY in "${DOMAINS[@]}"; do
    FULL_DOMAIN=$(echo "$ENTRY" | awk '{print $1}')
    PROXIED=$(echo "$ENTRY" | awk '{print $2}')

    DOMAIN=$(echo "$FULL_DOMAIN" | sed 's/.*\.\(.*\..*\)/\1/') # extract zone (example.com)

    # Get ZONE ID
    ZONE_ID=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones?name=$DOMAIN" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" | \
        grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

    if [[ -z "$ZONE_ID" ]]; then
        log "ERROR: Cannot find zone for $FULL_DOMAIN"
        continue
    fi

    RECORD_ID=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?type=A&name=$FULL_DOMAIN" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" | \
        grep -o '"id":"[^"]*' | head -1 | cut -d'"' -f4)

    if [[ -z "$RECORD_ID" ]]; then
        log "ERROR: Cannot find DNS record for $FULL_DOMAIN"
        continue
    fi

    CF_IP=$(curl -s -X GET \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" | \
        grep -o '"content":"[^"]*' | cut -d'"' -f4)

    if [[ "$WAN_IP" == "$CF_IP" ]]; then
        log "$FULL_DOMAIN unchanged ($WAN_IP)"
        continue
    fi

    RESPONSE=$(curl -s -X PUT \
        "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records/$RECORD_ID" \
        -H "Authorization: Bearer $CF_TOKEN" \
        -H "Content-Type: application/json" \
        --data "{\"type\":\"A\",\"name\":\"$FULL_DOMAIN\",\"content\":\"$WAN_IP\",\"ttl\":120,\"proxied\":$PROXIED}")

    if echo "$RESPONSE" | grep -q '"success":true'; then
        log "UPDATED $FULL_DOMAIN to $WAN_IP (proxied=$PROXIED)"
    else
        log "ERROR updating $FULL_DOMAIN: $RESPONSE"
    fi
done

