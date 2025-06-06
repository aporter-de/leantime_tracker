#!/bin/bash

# Quick Login Script for Leantime
PORT=9000
HOST="localhost"
URL="http://$HOST:$PORT"
COOKIE_FILE=".leantime-cookies.txt"

echo "🔐 Logging in with default credentials..."

# Save login cookies automatically
curl -s -c "$COOKIE_FILE" \
    -d "username=admin" \
    -d "password=admin123" \
    -d "submit=Login" \
    "$URL/auth/login" > /dev/null

echo "✅ Login attempt complete!"
echo "🌐 Opening dashboard..."

# Open dashboard
if command -v open > /dev/null; then
    open "$URL/dashboard"
fi

echo "📋 Credentials used:"
echo "  • Username: admin"
echo "  • Password: admin123" 