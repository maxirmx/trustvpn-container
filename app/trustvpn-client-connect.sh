#!/bin/bash
# Copyright (c) 2024 Maxim [maxirmx] Samsonov (https://sw.consulting)
# This file is a part of TrustVPN application
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
# TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
# PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS
# BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

set -o errexit -o pipefail -o noclobber -o nounset

# shellcheck disable=SC2154
CLIENT_IP="$ifconfig_pool_remote_ip"  # IP assigned to client by DHCP
# shellcheck disable=SC2154
CCD_FILE="/etc/openvpn/ccd/$common_name"

echo "$(date) trustvpn-client-connect: $common_name IP=$CLIENT_IP"

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

echo "$(date) trustvpn-client-connect: $common_name PROFILE=$PROFILE"

# Apply traffic shaping based on the profile
if [ "$PROFILE" = "limited" ]; then
    echo "$(date) trustvpn-client-connect: @iptables -t mangle -A OUTPUT -d $CLIENT_IP -j MARK --set-mark 10"
    sudo /sbin/iptables -t mangle -A OUTPUT -d "$CLIENT_IP" -j MARK --set-mark 10

    echo "$(date) trustvpn-client-connect: @iptables -t mangle -A PREROUTING -s $CLIENT_IP -j MARK --set-mark 10"
    sudo /sbin/iptables -t mangle -A PREROUTING -s "$CLIENT_IP" -j MARK --set-mark 10
elif [ "$PROFILE" = "unlimited" ]; then
    echo "$(date) trustvpn-client-connect: @iptables -t mangle -A OUTPUT -d $CLIENT_IP -j MARK --set-mark 20"
    sudo /sbin/iptables -t mangle -A OUTPUT -d "$CLIENT_IP" -j MARK --set-mark 20

    echo "$(date) trustvpn-client-connect: @iptables -t mangle -A PREROUTING -s $CLIENT_IP -j MARK --set-mark 20"
    sudo /sbin/iptables -t mangle -A PREROUTING -s "$CLIENT_IP" -j MARK --set-mark 20
fi
