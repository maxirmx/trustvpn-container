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
# docker build -t trustvpn-container .
# docker run -p 1194:1194/UDP --cap-add NET_ADMIN --sysctl net.ipv6.conf.all.disable_ipv6=0 --sysctl net.ipv6.conf.all.forwarding=1 trustvpn-container

FROM kylemanna/openvpn:latest

ENV APP=trustvpn-container
ENV APP_TZ=Europe/Moscow
ENV SERVICE="TrustVPN"

RUN apk upgrade -U
RUN apk add --no-cache tzdata
RUN ln -s /usr/share/zoneinfo/${APP_TZ} /etc/localtime

RUN mkdir -p /opt/trustvpn-container
RUN mkdir -p /etc/openvpn

COPY app /opt/trustvpn-container
RUN ln -s /opt/trustvpn-container/trustvpn-container-config.sh /usr/local/bin/trustvpn-container-config
RUN ln -s /opt/trustvpn-container/trustvpn-client-create.sh /usr/local/bin/trustvpn-client-create
RUN ln -s /opt/trustvpn-container/trustvpn-client-remove.sh /usr/local/bin/trustvpn-client-remove
RUN ln -s /opt/trustvpn-container/trustvpn-client-modify.sh /usr/local/bin/trustvpn-client-modify
RUN ln -s /opt/trustvpn-container/trustvpn-client-get.sh /usr/local/bin/trustvpn-client-get
RUN ln -s /opt/trustvpn-container/profiles /etc/openvpn

RUN trustvpn-container-config -u localhost
