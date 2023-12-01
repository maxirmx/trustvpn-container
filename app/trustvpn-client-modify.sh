#!/bin/bash
# Copyright (c) 2023 Maxim [maxirmx] Samsonov (https://sw.consulting)
# This file is a part of TrustVPN

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?

set -o errexit -o pipefail -o noclobber -o nounset

#   $1 - client id
#   $2 - profile

if [ ! -e "/etc/openvpn/ccd/$1" ]; then
    echo "Client with id $1 does not exist!"
    exit 1
fi

if [ ! -e "/etc/openvpn/profiles/$2" ]; then
    echo "Profile $2 is not defined!"
    exit 1
fi

rm -f "/etc/openvpn/ccd/$1"
ln -s "/etc/openvpn/profiles/$2" "/etc/openvpn/ccd/$1"
echo " == OK =="
