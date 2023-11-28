#!/bin/bash
# Copyright (c) 2023 Maxim [maxirmx] Samsonov (https://sw.consulting)
# This file is a part of TrustVPN

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?
set -o errexit -o pipefail -o noclobber -o nounset

#   $1 - client id

echo yes | ovpn_revokeclient "$1"
rm -f "/etc/openvpn/ccd/$1"
echo " == OK =="
