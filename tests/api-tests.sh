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
# main

# ......................................................................
#  AU. Check that it is possible to extract image content (--tebako-extract option)
test_client_create() {
    echo "==> Check trustvpm-client-create"
    result=$( docker run -it trustvpn-container bash -c "trustvpn-client-create test invalid-profile" )

    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Profile invalid-profile is not defined!"

    result=$( docker run -it trustvpn-container bash -c "trustvpn-client-create test limited" )
    assertEquals 0 "${PIPESTATUS[0]}"
    assertContains "$result" " == OK =="

    result=$( docker run -it trustvpn-container bash -c "trustvpn-client-create test unlimited" )
    assertEquals 1 "${PIPESTATUS[0]}"
    assertContains "$result" "Client with id test already exists!"
}

DIR0=$( dirname "$0" )
DIR_ROOT=$( cd "$DIR0"/.. && pwd )
DIR_TESTS=$( cd "$DIR_ROOT"/tests && pwd )

echo "Running trustvpn-container API tests"
# shellcheck source=/dev/null
. "$DIR_TESTS/shunit2/shunit2"