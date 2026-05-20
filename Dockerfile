FROM eclipse-temurin:21-jre-jammy

WORKDIR /minecraft

# Non-root runtime user + the data directory. eula.txt and server.properties
# are baked onto the image layer (NOT a volume) so a rebuilt image always
# ships the committed config. The world dirs are pre-created here so the
# VOLUME mountpoints below inherit minecraft:minecraft ownership.
RUN groupadd --system minecraft \
    && useradd --system --gid minecraft --home-dir /minecraft minecraft \
    && mkdir -p /minecraft/data/world \
                /minecraft/data/world_nether \
                /minecraft/data/world_the_end \
    && echo "eula=true" > /minecraft/data/eula.txt \
    && chown -R minecraft:minecraft /minecraft

# Server binaries are baked into the image (rebuilt per CalVer release) and
# kept OUT of the data volume so new releases actually take effect.
COPY --chown=minecraft:minecraft paper.jar /minecraft/paper.jar
COPY --chown=minecraft:minecraft plugins/ /minecraft/plugins/
COPY --chown=minecraft:minecraft server.properties /minecraft/data/server.properties

USER minecraft

# Persist ONLY the world data. server.properties, eula.txt, logs and the
# ops/whitelist/ban JSONs stay on the image layer and reset to the committed
# copy on every container recreation. Do NOT mount /minecraft/data as a whole
# or it would shadow the baked server.properties.
WORKDIR /minecraft/data
VOLUME ["/minecraft/data/world", "/minecraft/data/world_nether", "/minecraft/data/world_the_end"]

EXPOSE 25565/tcp
EXPOSE 19132/udp

HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD bash -c 'echo >/dev/tcp/localhost/25565' || exit 1

CMD ["java", \
     "-Xms1G", "-Xmx2G", \
     "-XX:+UseG1GC", \
     "-XX:+ParallelRefProcEnabled", \
     "-XX:MaxGCPauseMillis=200", \
     "-XX:+UnlockExperimentalVMOptions", \
     "-XX:+DisableExplicitGC", \
     "-XX:+AlwaysPreTouch", \
     "-XX:G1NewSizePercent=30", \
     "-XX:G1MaxNewSizePercent=40", \
     "-XX:G1HeapRegionSize=8M", \
     "-XX:G1ReservePercent=20", \
     "-XX:G1HeapWastePercent=5", \
     "-XX:G1MixedGCCountTarget=4", \
     "-XX:InitiatingHeapOccupancyPercent=15", \
     "-XX:G1MixedGCLiveThresholdPercent=90", \
     "-XX:G1RSetUpdatingPauseTimePercent=5", \
     "-XX:SurvivorRatio=32", \
     "-XX:+PerfDisableSharedMem", \
     "-XX:MaxTenuringThreshold=1", \
     "-Dusing.aikars.flags=https://mcflags.emc.gs", \
     "-Daikars.new.flags=true", \
     "-jar", "/minecraft/paper.jar", "--nogui", \
     "--plugins", "/minecraft/plugins"]
