#!/bin/bash
set -e

echo "🚀 Starting Telegram Bot API Server..."
mkdir -p /var/lib/telegram-bot-api

telegram-bot-api \
  --api-id=${API_ID} \
  --api-hash=${API_HASH} \
  --local \
  --dir=/var/lib/telegram-bot-api \
  --http-port=8081 &

API_PID=$!
echo "✅ API Server started (PID: $API_PID)"

# انتظر السيرفر يقوم
echo "⏳ Waiting for API server to be ready..."
sleep 5

echo "🤖 Starting Bot..."
python bot.py &
BOT_PID=$!
echo "✅ Bot started (PID: $BOT_PID)"

# لو أي واحد فيهم وقف، وقّف الكل
wait -n
echo "❌ A process exited. Shutting down..."
kill $API_PID $BOT_PID 2>/dev/null
exit 1
