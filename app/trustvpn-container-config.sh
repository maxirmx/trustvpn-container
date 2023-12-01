#!/bin/bash
# Copyright (c) 2023 Maxim [maxirmx] Samsonov (https://sw.consulting)
# This file is a part of TrustVPN

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?

set -o errexit -o pipefail -o noclobber -o nounset

ovpn_genconfig -e "# Directory where we will store the individual user configuration files" -e "client-config-dir /etc/openvpn/ccd" "$@"
echo "$SERVICE" | ovpn_initpki nopass
