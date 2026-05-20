FROM eclipse-temurin:21-jre-jammy

WORKDIR /minecraft

# Non-root runtime user + the persistent data directory.
# eula.txt is seeded into the data dir so a fresh named volume inherits it.
RUN groupadd --system minecraft \
    && useradd --system --gid minecraft --home-dir /minecraft minecraft \
    && mkdir -p /minecraft/data \
    && echo "eula=true" > /minecraft/data/eula.txt \
    && chown -R minecraft:minecraft /minecraft

# Server binaries are baked into the image (rebuilt per CalVer release) and
# kept OUT of the data volume so new releases actually take effect.
COPY --chown=minecraft:minecraft paper.jar /minecraft/paper.jar
COPY --chown=minecraft:minecraft plugins/ /minecraft/plugins/

USER minecraft

# Single "server data" volume: worlds (world, world_nether, world_the_end),
# server.properties, logs, ops/whitelist/bans and usercache all live here.
WORKDIR /minecraft/data
VOLUME ["/minecraft/data"]

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
