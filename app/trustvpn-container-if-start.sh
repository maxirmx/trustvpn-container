#!/bin/bash
# Copyright (c) 2023-2024 Maxim [maxirmx] Samsonov (https://sw.consulting)
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

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?

set -o errexit -o pipefail -o noclobber -o nounset

if [ ! -e /etc/openvpn/openvpn.conf ]; then
  echo "OpenVPN server.conf not found, generating configuration"

  ovpn_genconfig \
    -e "# Allow scripting" \
    -e "script-security 2" \
    -e "# Client connect completion script" \
    -e "client-connect /opt/trustvpn-container/trustvpn-client-connect.sh" \
    -e "# Directory where we will store the individual user configuration files" \
    -e "client-config-dir /etc/openvpn/ccd" "$@"

  echo "$SERVICE" | ovpn_initpki nopass
fi

ovpn_run

INTERFACE=tun0  # VPN interface

# Setup the root qdisc and two classes (one for each profile)
#  limited profile:
#   - 1 Mbps
#   - classid 1:10
#  'unlimited' profile:
#   - 100 Mbps
#   - classid 1:20
#  default profile (just in case):
#   - no limits
#   - classid 1:30

tc qdisc add dev $INTERFACE root handle 1: htb default 30

tc class add dev $INTERFACE parent 1: classid 1:10 htb rate 1mbit
tc class add dev $INTERFACE parent 1: classid 1:20 htb rate 100mbit

tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 handle 10 fw flowid 1:10  # Limited
tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 handle 20 fw flowid 1:20  # Unlimited
