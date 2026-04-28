# VPS setup

```bash
# Run from the compose directory so .env and relative bind mounts work.
cd core

# Start the main node.
docker compose -f docker-compose.yaml up -d --force-recreate

# Start a core-only node.
docker compose -f docker-compose-core.yml up -d --force-recreate
```

![alt text](image.png)
![alt text](image-1.png)
![alt text](image-2.png)
![alt text](image-3.png)
