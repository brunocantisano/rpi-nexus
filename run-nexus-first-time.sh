docker run -it \
-u 0 \
--name nexus \
--restart=always \
-p 9011:8081 \
-p 9012:8082 \
-p 9013:8083 \
-v ~/projetos/dados/nexus-data:/usr/local/nexus/data \
paperinik/rpi-nexus:latest
