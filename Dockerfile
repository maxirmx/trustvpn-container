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

# Hint:
# build docker buildx build -t trustvpn-container .
# initialization: docker run  -v $PWD/cfg:/etc/openvpn trustvpn-container bash -c "trustvpn-container-config -u localhost"
# docker run -p 1194:1194/UDP --cap-add NET_ADMIN --sysctl net.ipv6.conf.all.disable_ipv6=0 --sysctl net.ipv6.conf.all.forwarding=1 trustvpn-container

FROM kylemanna/openvpn:latest

ENV APP=trustvpn-container
ENV APP_TZ=Europe/Moscow
ENV SERVICE="TrustVPN"

VOLUME /etc/openvpn

RUN apk upgrade -U && \
    apk add --no-cache sudo bash tzdata iptables iproute2 && \
    ln -s /usr/share/zoneinfo/${APP_TZ} /etc/localtime && \
    mkdir -p /etc/sudoers.d && \
    echo "nobody ALL=(ALL:ALL) NOPASSWD: ALL" | tee /etc/sudoers.d/nobody

COPY app /opt/trustvpn-container

RUN if [ -e /opt/trustvpn-container/profiles/blocked ]; then echo "Profile 'blocked' should not be used!" && exit 1; fi && \
    ln -s /opt/trustvpn-container/trustvpn-container-config.sh /usr/local/bin/trustvpn-container-config && \
    ln -s /opt/trustvpn-container/trustvpn-client-create.sh /usr/local/bin/trustvpn-client-create && \
    ln -s /opt/trustvpn-container/trustvpn-client-remove.sh /usr/local/bin/trustvpn-client-remove && \
    ln -s /opt/trustvpn-container/trustvpn-client-modify.sh /usr/local/bin/trustvpn-client-modify && \
    ln -s /opt/trustvpn-container/trustvpn-client-block.sh /usr/local/bin/trustvpn-client-block && \
    ln -s /opt/trustvpn-container/trustvpn-client-get.sh /usr/local/bin/trustvpn-client-get && \
    ln -s /opt/trustvpn-container/trustvpn-container-if-start.sh /usr/local/bin/trustvpn-container-if-start && \
    ln -s /opt/trustvpn-container/trustvpn-init-tc.sh /usr/local/bin/trustvpn-init-tc && \
    ln -s /opt/trustvpn-container/openvpn-check.sh /usr/local/bin/openvpn-check
