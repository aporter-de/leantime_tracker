#!/bin/bash

# Open Leantime Dashboard (Development Mode - No Auth)
PORT=9000
HOST="localhost"
URL="http://$HOST:$PORT"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Opening Leantime Dashboard (Development Mode)${NC}"

# Check if server is running
if ! curl -s -o /dev/null -w "%{http_code}" $URL | grep -q "200\|302\|303"; then
    echo -e "${RED}❌ Server is not running on $URL${NC}"
    echo -e "${BLUE}🔧 Starting server...${NC}"
    ./start-leantime.sh &
    sleep 5
fi

echo -e "${GREEN}✅ Server is running${NC}"
echo -e "${BLUE}🌐 Opening dashboard in browser...${NC}"

# Open browser directly to root (which will show dashboard without auth)
if command -v open > /dev/null; then
    open "$URL"
elif command -v xdg-open > /dev/null; then
    xdg-open "$URL"
else
    echo -e "${BLUE}📋 Manual access: $URL${NC}"
fi

echo -e "${GREEN}🎉 Dashboard opened! Authentication is bypassed for development.${NC}"
echo -e "${BLUE}📋 Available routes:${NC}"
echo -e "  • Dashboard: $URL"
echo -e "  • Projects: $URL/projects"  
echo -e "  • Tickets: $URL/tickets"
echo -e "  • Users: $URL/users"
echo -e "  • Settings: $URL/setting" 