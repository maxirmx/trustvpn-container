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

INTERFACE=eth0

# Setup the root qdisc and two classes (one for each profile)
#  limited profile:
#   - 1 Mbps
#   - classid 1:10 (incoming), 1:11 (outgoing)
#  default ('unlimited') profile:
#   - no limits
#   - classid 1:30

echo "$(date) trustvpn-container-init-tc: @tc qdisc add dev $INTERFACE root handle 1: htb default 30"
tc qdisc add dev "$INTERFACE" root handle 1: htb default 30

echo "$(date) trustvpn-container-init-tc: @tc class add dev $INTERFACE parent 1: classid 1:10 htb rate 1mbit ceil 1mbit"
tc class add dev "$INTERFACE" parent 1: classid 1:10 htb rate 1mbit ceil 1mbit"

echo "$(date) trustvpn-container-init-tc: @tc class add dev $INTERFACE parent 1: classid 1:11 htb rate 1mbit ceil 1mbit"
tc class add dev "$INTERFACE" parent 1: classid 1:11 htb rate 1mbit ceil 1mbit"

echo "$(date) trustvpn-container-init-tc: @tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 handle 10 fw flowid 1:10"
tc filter add dev "$INTERFACE" protocol ip parent 1:0 prio 1 handle 10 fw flowid 1:10

echo "$(date) trustvpn-container-init-tc: @tc filter add dev $INTERFACE protocol ip parent 1:0 prio 1 handle 11 fw flowid 1:11"
tc filter add dev "$INTERFACE" protocol ip parent 1:0 prio 1 handle 11 fw flowid 1:11
