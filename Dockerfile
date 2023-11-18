# Copyright (c) 2023 Maxim [maxirmx] Samsonov (https://sw.consulting)
# This file is a part of O!Service

FROM kylemanna/openvpn:latest

ENV APP=o-container
ENV APP_TZ=Europe/Moscow
ENV SERVICE="O!Service"

ARG HOST

RUN apk upgrade -U
RUN apk add --no-cache tzdata
RUN ln -s /usr/share/zoneinfo/${APP_TZ} /etc/localtime

RUN mkdir -p /opt/o-container
RUN mkdir -p /etc/openvpn

COPY app /opt/o-container
RUN ln -s /opt/o-container/o-container-config /usr/local/bin/o-container-config
RUN ln -s /opt/o-container/o-client-create /usr/local/bin/o-client-create
RUN ln -s /opt/o-container/o-client-remove /usr/local/bin/o-client-remove
RUN ln -s /opt/o-container/profiles /etc/openvpn
