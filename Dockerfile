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

FROM kylemanna/openvpn:latest

ENV APP=o-container
ENV APP_TZ=Europe/Moscow
ENV SERVICE="TrustVPN"

RUN apk upgrade -U
RUN apk add --no-cache tzdata
RUN ln -s /usr/share/zoneinfo/${APP_TZ} /etc/localtime

RUN mkdir -p /opt/o-container
RUN mkdir -p /etc/openvpn

COPY app /opt/o-container
RUN ln -s /opt/o-container/o-container-config /usr/local/bin/o-container-config
RUN ln -s /opt/o-container/o-client-create /usr/local/bin/o-client-create
RUN ln -s /opt/o-container/o-client-remove /usr/local/bin/o-client-remove
RUN ln -s /opt/o-container/o-client-modify /usr/local/bin/o-client-modify
RUN ln -s /opt/o-container/o-client-get /usr/local/bin/o-client-get
RUN ln -s /opt/o-container/profiles /etc/openvpn

RUN o-container-config -u kreel0.samsonov.net
