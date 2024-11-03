#!/bin/bash

# shellcheck disable=SC2154
CLIENT_IP="$ifconfig_pool_remote_ip"  # IP assigned to client by DHCP
CCD_FILE="/etc/openvpn/ccd/$common_name"

# Default to "limited" profile
PROFILE="limited"

# Check if the ccd file exists and contains a PROFILE definition
if [ -f "$CCD_FILE" ]; then
    # Read the PROFILE line from the ccd file
    PROFILE_LINE=$(grep -E "^# PROFILE=" "$CCD_FILE" | head -n 1)
    if [ -n "$PROFILE_LINE" ]; then
        PROFILE=$(echo "$PROFILE_LINE" | cut -d'=' -f2)
    fi
fi

# Apply traffic shaping based on the profile
if [ "$PROFILE" = "limited" ]; then
    iptables -t mangle -A OUTPUT -d "$CLIENT_IP" -j MARK --set-mark 10
elif [ "$PROFILE" = "unlimited" ]; then
    iptables -t mangle -A OUTPUT -d "$CLIENT_IP" -j MARK --set-mark 20
fi
