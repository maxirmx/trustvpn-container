#!/bin/bash
# Copyright (c) 2023 Maxim [maxirmx] Samsonov (https://sw.consulting)
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


# ......................................................................
test_container_config() {
    echo "==> Test trustvpm-container-config"
    if [ -e "$DIR_CONFIG" ]; then
        sudo rm -rf "$DIR_CONFIG"
    fi
    mkdir -p "$DIR_CONFIG"

    result=$(docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-container-config -u localhost")
    assertEquals 0 "${PIPESTATUS[0]}"
}

# ......................................................................
test_client_create() {
    echo "==> Test trustvpm-client-create"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-create test invalid-profile" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Profile 'invalid-profile' is not defined!"
    assertTrue "[ ! -h $DIR_CONFIG/ccd/test ]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-create test limited" )
    assertEquals 0 "${PIPESTATUS[0]}"
    assertContains "$result" " == OK == "
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-create test unlimited" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Client with id 'test' already exists!"
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"
}

# ......................................................................
test_client_get() {
    echo "==> Check trustvpm-client-get"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-get test" )
    assertEquals 0 "${PIPESTATUS[0]}"
}

# ......................................................................
test_client_modify() {
    echo "==> Test trustvpm-client-modify"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-modify test invalid-profile" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Profile 'invalid-profile' is not defined!"
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-modify test unlimited" )
    assertEquals 0 "${PIPESTATUS[0]}"
    assertContains "$result" " == OK == "
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-modify invalid-client unlimited" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Client with id 'invalid-client' does not exist!"
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"
}

# ......................................................................
test_client_block() {
    echo "==> Test trustvpm-client-block"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-block invalid-client" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Client with id 'invalid-client' does not exist!"
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-block test" )
    assertEquals 0 "${PIPESTATUS[0]}"
    assertContains "$result" " == OK == "
}

# ......................................................................
test_client_modify_after_block() {
    echo "==> Test trustvpm-client-modify after block"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-modify test invalid-profile" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Profile 'invalid-profile' is not defined!"
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-modify test unlimited" )
    assertEquals 0 "${PIPESTATUS[0]}"
    assertContains "$result" " == OK == "
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-modify invalid-client unlimited" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Client with id 'invalid-client' does not exist!"
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"
}

# ......................................................................
test_client_remove() {
    echo "==> Test trustvpm-client-remove"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-remove test" )
    assertEquals 0 "${PIPESTATUS[0]}"
    assertContains "$result" " == OK == "
    assertTrue "[ ! -e $DIR_CONFIG/ccd/test ]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-remove invalid-client" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Client with id 'invalid-client' does not exist!"
}

# ......................................................................
test_client_create_blocked() {
    echo "==> Test trustvpm-client-create [blocked]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-create test blocked" )
    assertEquals 0 "${PIPESTATUS[0]}"
    assertContains "$result" " == OK == "
    assertTrue "[ -h $DIR_CONFIG/ccd/test ]"
}

# ......................................................................
test_client_remove_blocked() {
    echo "==> Test trustvpm-client-remove [blocked]"

    result=$( docker run --rm -v "$DIR_CONFIG":/etc/openvpn "$CONTAINER" bash -c "trustvpn-client-remove test" )
    assertEquals 0 "${PIPESTATUS[0]}"
    assertContains "$result" " == OK == "
    assertTrue "[ ! -e $DIR_CONFIG/ccd/test ]"
}


DIR0=$( dirname "$0" )
DIR_ROOT=$( cd "$DIR0"/.. && pwd )
DIR_TESTS=$( cd "$DIR_ROOT"/tests && pwd )
DIR_CONFIG="$DIR_TESTS"/config

CONTAINER="${CONTAINER:-trustvpn-container}"

echo "Running '$CONTAINER' API tests"
# shellcheck source=/dev/null
. "$DIR_TESTS/shunit2/shunit2"
