```bash
docker run -d --name="zoneminder" \
--net="bridge" \
--privileged="false" \
--shm-size="8G" \
--device="/dev/video0" \
-p 80:80/tcp \
-p 443:443/tcp \
-p 9000:9000/tcp \
-v "/srv/zoneminder/config":"/srv/config":rw \
-v "/srv/zoneminder/data":"/srv/data":rw \
zoneminder
```
