FROM debian:bullseye-slim AS builder

RUN apt-get update && apt-get install -y \
    build-essential cmake git wget \
    libssl-dev zlib1g-dev gperf \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --recursive https://github.com/tdlib/telegram-bot-api.git /src
WORKDIR /src
RUN mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    cmake --build . --target telegram-bot-api -j$(nproc)

# ── Final image ──────────────────────────────────────
FROM python:3.11-slim

RUN apt-get update && apt-get install -y \
    libssl1.1 zlib1g \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /src/build/telegram-bot-api /usr/local/bin/telegram-bot-api

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY bot.py .
COPY start.sh .
RUN chmod +x start.sh

EXPOSE 8081

CMD ["./start.sh"]
