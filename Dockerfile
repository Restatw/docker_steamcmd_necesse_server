# Use Debian base image (as officially recommended)
FROM debian:bullseye-slim

# Set maintainer information
LABEL maintainer="necesse-server"

# Create necesse user (don't run as root)
ARG user=necesse
ARG group=necesse
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group}
RUN useradd -u ${uid} -g ${group} -s /bin/bash -m ${user}

# Add 32-bit architecture support and install dependencies
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    ca-certificates-java \
    lib32gcc-s1 \
    curl \
    openjdk-17-jre-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download and extract SteamCMD
RUN mkdir -p /steamcmd
WORKDIR /steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# Create SteamCMD configuration file (using correct App ID 1169370)
RUN echo '@ShutdownOnFailedCommand 1' > update_necesse.txt && \
    echo '@NoPromptForPassword 1' >> update_necesse.txt && \
    echo 'force_install_dir /app/' >> update_necesse.txt && \
    echo 'login anonymous' >> update_necesse.txt && \
    echo 'app_update 1169370 validate' >> update_necesse.txt && \
    echo 'quit' >> update_necesse.txt

# Run SteamCMD to install Necesse dedicated server
RUN ./steamcmd.sh +runscript update_necesse.txt

# Create Necesse configuration directory
RUN mkdir -p /home/necesse/.config/Necesse
RUN chown -R ${uid}:${gid} /app /home/necesse

# Set working directory
WORKDIR /app

# Create permission management script
RUN echo '#!/bin/sh' > /docker-entrypoint.sh && \
    echo '# Ensure mounted directories have correct permissions' >> /docker-entrypoint.sh && \
    echo 'if [ "$(id -u)" = "0" ]; then' >> /docker-entrypoint.sh && \
    echo '    # If root, change permissions then switch to necesse user' >> /docker-entrypoint.sh && \
    echo '    chown -R necesse:necesse /home/necesse/.config/Necesse' >> /docker-entrypoint.sh && \
    echo '    chmod -R 755 /home/necesse/.config/Necesse' >> /docker-entrypoint.sh && \
    echo '    exec runuser -u necesse -- "$@"' >> /docker-entrypoint.sh && \
    echo 'else' >> /docker-entrypoint.sh && \
    echo '    # If already correct user, execute directly' >> /docker-entrypoint.sh && \
    echo '    exec "$@"' >> /docker-entrypoint.sh && \
    echo 'fi' >> /docker-entrypoint.sh && \
    chmod +x /docker-entrypoint.sh

# Set user (not set here, let entrypoint script handle it)
# USER ${uid}:${gid}

# Expose Necesse default port
EXPOSE 14159

# Create startup script
RUN echo '#!/bin/sh' > entrypoint.sh && \
    echo 'java -jar Server.jar -nogui -world "${WORLD_NAME:-DefaultWorld}"' >> entrypoint.sh && \
    chmod +x entrypoint.sh

# Set entrypoint and default command
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["./entrypoint.sh"]