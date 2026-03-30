## Environments ##
<<!--@include:./environments-->

## Volumes ##
The default configuration and data files are located in /srv/config and /srv/data. You can attach volumes to either folder.
Example:
```
-v /srv/zoneminder/data:/srv/data
-v /srv/zoneminder/config:/srv/config
```

### Running with docker command ###
```bash
docker run -d --rm --name="zoneminder" \
--device="/dev/video0:/dev/video0":rw \
--shm-size="8G" \
-v "/srv/zoneminder/config":"/srv/config":rw \
-v "/srv/zoneminder/data":"/srv/data":rw \
-e TZ="Asia/Jakarta" \
-e DB_USER="bits_user" \
-e DB_PASS="bits_pass" \
-p 5080:80 \
zoneminder
```

### Running with docker-compose ###
Create docker-compose.yaml.
```yaml
services:
  zm:
    image: zoneminder
    build: .
    ports:
      - "5080:80"
    environment:
      - TZ=Asia/Jakarta
      - DB_USER=bits_user
      - DB_PASS=bits_pass
    shm_size: "8GB"
    volumes:
      - /srv/zoneminder/config:/srv/config
      - /srv/zoneminder/data:/srv/data
```
Run this docker-compose with command:
```bash
docker compose up
```
