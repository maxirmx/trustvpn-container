#!/bin/bash
# Copyright (c) 2023 Maxim [maxirmx] Samsonov (https://sw.consulting)
# This file is a part of TrustVPN

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?
set -o errexit -o pipefail -o noclobber -o nounset

#   $1 - client id
#

if [ ! -e "/etc/openvpn/ccd/$1" ]; then
    echo "Client with id $1 does not exist!"
    exit 1
fi

ovpn_getclient "$1"
