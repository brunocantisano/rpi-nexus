docker run -d \
--name nexus \
--restart=always \
-p 9011:8081 \
-p 9012:8082 \
-p 9013:8083 \
-v ~/projetos/dados/nexus-data:/usr/local/sonatype-work/nexus3/db \
paperinik/rpi-nexus:latest
