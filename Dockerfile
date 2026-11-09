
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates wget unzip && \
    rm -rf /var/lib/apt/lists/*

ARG GODOT_VERSION=4.7.1

RUN wget -q \
    "https://github.com/godotengine/godot-builds/releases/download/${GODOT_VERSION}-stable/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip" \
    -O /tmp/godot.zip && \
    unzip -q /tmp/godot.zip -d /tmp && \
    mv "/tmp/Godot_v${GODOT_VERSION}-stable_linux.x86_64" /usr/local/bin/godot && \
    chmod +x /usr/local/bin/godot && \
    rm /tmp/godot.zip

WORKDIR /app

COPY . .

RUN godot --headless --path /app --editor --import --quit

ENV PORT=10000

EXPOSE 10000

CMD ["godot", "--headless", "--path", "/app", "--", "--server"]
