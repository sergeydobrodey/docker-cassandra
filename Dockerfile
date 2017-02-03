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

FROM alpine:3.5

ARG BUILD_DATE
ARG VCS_REF
ARG CASSANDRA_VERSION

LABEL \
    org.label-schema.build-date=$BUILD_DATE \
    org.label-schema.docker.dockerfile="/Dockerfile" \
    org.label-schema.license="Apache License 2.0" \
    org.label-schema.name="chrislovecnm/cassandra" \
    org.label-schema.url="https://github.com/chrislovecnm" \
    org.label-schema.vcs-ref=$VCS_REF \
    org.label-schema.vcs-type="Git" \
    org.label-schema.vcs-url="https://github.com/chrislovecnm/docker-cassandra"

ENV CASSANDRA_HOME=/usr/local/apache-cassandra-${CASSANDRA_VERSION} \
    CASSANDRA_CONF=/etc/cassandra \
    CASSANDRA_DATA=/cassandra_data \
    CASSANDRA_LOGS=/var/log/cassandra \
    JAVA_HOME=/usr/lib/jvm/default-jvm

ENV PATH=${PATH}:${JAVA_HOME}/bin:${CASSANDRA_HOME}/bin

# Alpine jemalloc library path is not expected by C*, so we need to provide it
#ENV CASSANDRA_LIBJEMALLOC=/usr/lib/libjemalloc.so.2

ADD files /

RUN set -x \
    && apk --no-cache add \
        bash \
#        jemalloc \
        openjdk8-jre \
        python \
        dumb-init \
    && mirror_url=$( \
        wget -q -O - http://www.apache.org/dyn/closer.cgi/cassandra/ \
        | sed -n 's#.*href="\(http://ftp.[^"]*\)".*#\1#p' \
        | head -n 1 \
    ) \
    && wget -q -O - ${mirror_url}/${CASSANDRA_VERSION}/apache-cassandra-${CASSANDRA_VERSION}-bin.tar.gz \
        | tar -xzf - -C /usr/local \
    && adduser -D  -g '' -s /sbin/nologin -u 1000 docker \
    && adduser -D  -g '' -s /sbin/nologin cassandra \
    && mv /entrypoint.sh /usr/local/bin/ \
    && chmod +x /usr/local/bin/* \
    && mkdir -p /cassandra_data/data \
    && mkdir -p /etc/cassandra \
    && mv /logback.xml /cassandra.yaml /jvm.options /etc/cassandra/ \
    && rm -rf \
      $CASSANDRA_HOME/*.txt \
      $CASSANDRA_HOME/doc \
      $CASSANDRA_HOME/javadoc \
      $CASSANDRA_HOME/tools/*.yaml \
      $CASSANDRA_HOME/tools/bin/*.bat

VOLUME ["/$CASSANDRA_DATA"]

# 7000: intra-node communication
# 7001: TLS intra-node communication
# 7199: JMX
# 9042: CQL
# 9160: thrift service
EXPOSE 7000 7001 7199 9042 9160

ENTRYPOINT ["entrypoint.sh"]
CMD ["cassandra", "-f"]
