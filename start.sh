#!/bin/bash
set -e

# Export variables explicitly
export API_ID="${API_ID}"
export API_HASH="${API_HASH}"
export BOT_TOKEN="${BOT_TOKEN}"
export ADMIN_IDS="${ADMIN_IDS:-5860401902}"
export LOCAL_API_URL="http://127.0.0.1:8081/bot"

echo "🔍 Checking variables..."
echo "API_ID: ${API_ID}"
echo "ADMIN_IDS: ${ADMIN_IDS}"

if [ -z "$API_ID" ]; then
  echo "❌ API_ID is empty!"
  exit 1
fi

if [ -z "$BOT_TOKEN" ]; then
  echo "❌ BOT_TOKEN is empty!"
  exit 1
fi

echo "🚀 Starting Telegram Bot API Server..."
mkdir -p /var/lib/telegram-bot-api

telegram-bot-api \
  --api-id="${API_ID}" \
  --api-hash="${API_HASH}" \
  --local \
  --dir=/var/lib/telegram-bot-api \
  --http-port=8081 &

API_PID=$!
echo "✅ API Server started (PID: $API_PID)"

echo "⏳ Waiting for API server to be ready..."
for i in $(seq 1 30); do
  if curl -s http://127.0.0.1:8081 > /dev/null 2>&1; then
    echo "✅ API Server is ready!"
    break
  fi
  echo "  ... waiting ($i/30)"
  sleep 2
done

echo "🤖 Starting Bot..."
python bot.py &
BOT_PID=$!
echo "✅ Bot started (PID: $BOT_PID)"

wait -n
echo "❌ A process exited. Shutting down..."
kill $API_PID $BOT_PID 2>/dev/null
exit 1
