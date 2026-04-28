### Environments ###

See this [environments](environments.md).

### Volumes ###

The default configuration and data files are located in /srv/config and /srv/data. You can attach volumes to either folder.

Example:

```
-v /srv/zoneminder/data:/srv/data
-v /srv/zoneminder/config:/srv/config
```

### Build with docker command ###

```bash
docker build -t zoneminder .
```

### Running with docker command ###

```bash
docker run -d --rm --name="zoneminder" \
--device="/dev/video0:/dev/video0":rw \
--shm-size="2G" \
-v "/srv/zoneminder/config":"/srv/config":rw \
-v "/srv/zoneminder/data":"/srv/data":rw \
-e TZ="Asia/Jakarta" \
-e DB_USER="bits_user" \
-e DB_PASS="bits_pass" \
-e INSTALL_ZMES="true" \
-e INSTALL_HOOK="yes" \
-e INSTALL_MODEL=1 \
-p 80:80 \
-p 9000:9000 \
zoneminder
```

### Build and Run with docker-compose ###

Create docker-compose.yaml.

```yaml
services:
  zm:
    image: zoneminder
    build: .
    ports:
      - "80:80"
      - "9000:9000"
    environment:
      - TZ=Asia/Jakarta
      - DB_USER=zmuser
      - DB_PASS=zmpass
      - INSTALL_ZMES="true"
      - INSTALL_HOOK="yes"
      - INSTALL-MODEL=1
    shm_size: "2GB"
    volumes:
      - /srv/zoneminder/config:/srv/config
      - /srv/zoneminder/data:/srv/data
```

Run this docker-compose with command:

```bash
docker compose up
```

