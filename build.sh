#!/bin/sh

# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -e

apt-get update && apt-get -qq -y --force-yes install --no-install-recommends \
	openjdk-8-jre-headless \
	libjemalloc1 \
	localepurge \
	wget && \
mirror_url=$( wget -q -O - http://www.apache.org/dyn/closer.cgi/cassandra/ \
        | sed -n 's#.*href="\(http://ftp.[^"]*\)".*#\1#p' \
        | head -n 1 \
    ) \
    && wget -q -O - ${mirror_url}/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
        | tar -xzf - -C /usr/local \
    && adduser --disabled-password --no-create-home --gecos '' --disabled-login --uid 1000 docker \
    && adduser --disabled-password --no-create-home --gecos '' --disabled-login cassandra \
    && mv /entrypoint.sh /usr/local/bin/ \
    && chmod +x /usr/local/bin/* \
    && mkdir -p /cassandra_data/data \
    && mkdir -p /etc/cassandra \
    && mv /logback.xml /cassandra.yaml /jvm.options /etc/cassandra/ \
    && rm -rf \
      $CASSANDRA_HOME}/*.txt \
      $CASSANDRA_HOME}/doc \
      $CASSANDRA_HOME}/javadoc \
      $CASSANDRA_HOME}/tools/*.yaml \
      $CASSANDRA_HOME}/tools/bin/*.bat

apt-get -y purge wget localepurge \
  && apt-get autoremove \
  && apt-get clean \
  && rm -rf \
        doc \
        man \
        info \
        locale \
        /var/lib/apt/lists/* \
        /var/log/* \
        /var/cache/debconf/* \
        common-licenses \
        ~/.bashrc \
        /etc/systemd \
        /lib/lsb \
        /lib/udev \
        /usr/share/doc/ \
        /usr/share/doc-base/ \
        /usr/share/man/ \
        /tmp/*

