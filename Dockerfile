FROM paperinik/rpi-java8:latest
MAINTAINER Bruno Cardoso Cantisano <bruno.cantisano@gmail.com>

LABEL version latest
LABEL description Sonatype Nexus Repository Container

ENV NEXUS_VERSION 3.18.1-01

RUN cd /tmp \
    && rm -f /etc/apt/sources.list \
    && apt-get update

RUN apt-get install -y wget \
    && wget -O /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz https://download.sonatype.com/nexus/3/nexus-${NEXUS_VERSION}-unix.tar.gz \
    && tar -zxf /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz -C /usr/local \
    && mv /usr/local/nexus-${NEXUS_VERSION}* /usr/local/nexus \
    && rm -f /tmp/nexus-${NEXUS_VERSION}-unix.tar.gz \
    && useradd -m nexus \
    && chown -R nexus /usr/local/nexus \
    && apt-get purge --auto-remove wget \
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
