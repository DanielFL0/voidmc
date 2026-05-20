# voidmc
> *voidmc* simple minecraft container image, perfect for small minecraft servers that need cross-play, old version support and more.

Server Software
------------
| Type | Technology |
|------|------------|
| Server | [papermc](https://papermc.io/downloads/) |
| Plugin | [geysermc](https://geysermc.org/download?project=geyser) |
| Plugin | [floodgate](https://geysermc.org/download?project=floodgate) |
| Plugin | [viaversion](https://hangar.papermc.io/ViaVersion/ViaVersion/versions) |

Usage
------------
The container runs as a non-root `minecraft` user, so the world volumes must be
owned by it. Fix ownership once before the first run:

```bash
docker run --rm -u 0 \
    -v world:/minecraft/data/world \
    -v world_nether:/minecraft/data/world_nether \
    -v world_the_end:/minecraft/data/world_the_end \
    ghcr.io/danielfl0/voidmc:26.05.3 \
    chown -R minecraft:minecraft /minecraft/data/world /minecraft/data/world_nether /minecraft/data/world_the_end
```

Then run the server:

```bash
docker run -d --name voidmc --restart unless-stopped -it \
    -p 25565:25565/tcp \
    -p 19132:19132/udp \
    -v world:/minecraft/data/world \
    -v world_nether:/minecraft/data/world_nether \
    -v world_the_end:/minecraft/data/world_the_end \
    ghcr.io/danielfl0/voidmc:26.05.3
```

Versioning Scheme
------------
I use `YY.0M.MICRO`, take a look at [CalVer](https://calver.org/).

License
------------
See [LICENSE.md](https://github.com/DanielFL0/voidmc/LICENSE.md).