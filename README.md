# My Docker compose + configs for my server
This is a collection of up-to-date docker compose files I use for my home server.
- Any .env files have not been provided and will need to be created for use
- Most services point to an external drive and will need to be updated for use

# Info
All public-facing containers use an external docker network named "proxy" that is sent through caddy, and then through the cloudflare tunnel. It needs to be created before running anything.

```bash
docker network create proxy
```
