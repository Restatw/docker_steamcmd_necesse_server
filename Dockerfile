# 使用 Debian 基礎映像（按照官方建議）
FROM debian:bullseye-slim

# 設定維護者資訊
LABEL maintainer="necesse-server"

# 創建 necesse 用戶（不要使用 root 運行）
ARG user=necesse
ARG group=necesse
ARG uid=1000
ARG gid=1000

RUN groupadd -g ${gid} ${group}
RUN useradd -u ${uid} -g ${group} -s /bin/bash -m ${user}

# 添加 32 位架構支援並安裝依賴套件
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    ca-certificates-java \
    lib32gcc-s1 \
    curl \
    openjdk-17-jre-headless \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 下載並解壓縮 SteamCMD
RUN mkdir -p /steamcmd
WORKDIR /steamcmd
RUN curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -

# 創建 SteamCMD 配置檔案（使用正確的 App ID 1169370）
RUN echo '@ShutdownOnFailedCommand 1' > update_necesse.txt && \
    echo '@NoPromptForPassword 1' >> update_necesse.txt && \
    echo 'force_install_dir /app/' >> update_necesse.txt && \
    echo 'login anonymous' >> update_necesse.txt && \
    echo 'app_update 1169370 validate' >> update_necesse.txt && \
    echo 'quit' >> update_necesse.txt

# 運行 SteamCMD 安裝 Necesse 專用伺服器
RUN ./steamcmd.sh +runscript update_necesse.txt

# 創建 Necesse 配置目錄
RUN mkdir -p /home/necesse/.config/Necesse
RUN chown -R ${uid}:${gid} /app /home/necesse

# 設定工作目錄
WORKDIR /app

# 設定用戶
USER ${uid}:${gid}

# 暴露 Necesse 預設連接埠
EXPOSE 14159

# 創建啟動腳本
RUN echo '#!/bin/sh' > entrypoint.sh && \
    echo 'java -jar Server.jar -nogui -world "${WORLD_NAME:-DefaultWorld}"' >> entrypoint.sh && \
    chmod +x entrypoint.sh

# 設定預設命令
CMD ["./entrypoint.sh"]