FROM paperinik/rpi-java:8
MAINTAINER Bruno Cardoso Cantisano <bruno.cantisano@gmail.com>

LABEL version latest
LABEL description Sonatype Nexus Repository Container

ENV NEXUS_VERSION 3.29.2-02

RUN apt-get update \
    && apt-get install -y wget

RUN wget --no-check-certificate https://sonatype-download.global.ssl.fastly.net/repository/downloads-prod-group/3/nexus-${NEXUS_VERSION}-unix.tar.gz -P /tmp \
    && tar -zxf /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz -C /usr/local \
    && mv /usr/local/nexus-${NEXUS_VERSION}* /usr/local/nexus \
    && rm -f /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz \
    && useradd -m nexus \
    && chown -R nexus /usr/local/nexus \
    && mkdir -p /opt/sonatype/jna \
    && cd /opt/sonatype/jna \
    && wget https://repo1.maven.org/maven2/net/java/dev/jna/jna/5.5.0/jna-5.5.0.jar \
    && wget https://repo1.maven.org/maven2/net/java/dev/jna/jna-platform/5.5.0/jna-platform-5.5.0.jar \
    && chmod +x /opt/sonatype/jna/* \
    && rm -rf /var/lib/apt/lists/*

COPY files/nexus.vmoptions /usr/local/nexus/bin/nexus.vmoptions

#docker-web: 8081
#docker-group: 8082
#docker-private 8083 
EXPOSE 8081 8082 8083

VOLUME /usr/local/nexus/data

WORKDIR /usr/local/nexus/bin

USER nexus

CMD ["./nexus", "run"]
