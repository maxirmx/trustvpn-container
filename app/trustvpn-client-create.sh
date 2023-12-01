#!/bin/bash
# Copyright (c) 2023 Maxim [maxirmx] Samsonov (https://sw.consulting)
# This file is a part of TrustVPN

# More safety, by turning some bugs into errors.
# Without `errexit` you don’t need ! and can replace
# PIPESTATUS with a simple $?

set -o errexit -o pipefail -o noclobber -o nounset

#   $1 - client id
#   $2 - profile

easyrsa build-client-full "$1" nopass
if [ -e "/etc/openvpn/profiles/$2" ]; then
    ln -s "/etc/openvpn/profiles/$2" "/etc/openvpn/ccd/$1"
else
    echo "Profile "$2" is not defined!"
    exit 1
fi
ln -s "/etc/openvpn/profiles/$2" "/etc/openvpn/ccd/$1"
echo " == OK =="
