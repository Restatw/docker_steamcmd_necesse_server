# Necesse Dedicated Server Docker

A simple Docker setup for running a Necesse dedicated server using SteamCMD.

## What it does

This project creates a containerized Necesse dedicated server that:
- Downloads and installs Necesse server files via SteamCMD
- Runs the server with persistent world saves
- Uses official Debian base image following Necesse wiki recommendations

## Quick Start

1. **Clone and build**
   ```bash
   git clone <your-repo>
   cd docker_steamcmd_necesse_server
   docker-compose build
   ```

2. **Start the server**
   ```bash
   docker-compose up -d
   ```

3. **Check logs**
   ```bash
   docker-compose logs -f
   ```

## Configuration

Edit `docker-compose.yml` to change settings:
- `WORLD_NAME`: Your world name (default: MyWorld)
- Port: Default is 14159/udp

## File Structure

```
docker_steamcmd_necesse_server/
├── docker-compose.yml    # Main configuration
├── Dockerfile           # Custom image build
├── data/               # Server data (auto-created)
│   ├── saves/          # World saves
│   ├── cfg/            # Server config
│   └── logs/           # Server logs
└── README.md
```

## Server Management

- **Stop server**: `docker-compose down`
- **Restart server**: `docker-compose restart`
- **View status**: `docker-compose ps`

## Notes

- Server runs on port 14159/udp
- World saves are persistent in `./data/saves/`
- First run may take time to download server files
- Based on official Necesse Linux server setup guide

## Troubleshooting

If the server doesn't start:
1. Check logs: `docker-compose logs`
2. Ensure port 14159 is not in use
3. Try rebuilding: `docker-compose build --no-cache`