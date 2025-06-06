#!/bin/bash

# Leantime Auto-Login Cookie Saver
PORT=9000
HOST="localhost"
URL="http://$HOST:$PORT"
COOKIE_FILE=".leantime-cookies.txt"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🍪 Leantime Auto-Login Setup${NC}"
echo -e "${BLUE}============================${NC}"

# Check if server is running
if ! curl -s -o /dev/null -w "%{http_code}" $URL | grep -q "200\|303\|302"; then
    echo -e "${RED}❌ Server is not running on $URL${NC}"
    echo -e "${YELLOW}💡 Start the server first using: ./start-leantime.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Server is running on $URL${NC}"

# Get username
echo -e "\n${BLUE}👤 Enter your username:${NC}"
read -r username

# Get password (hidden input)
echo -e "${BLUE}🔐 Enter your password:${NC}"
read -s password
echo

# Attempt to login and save cookies
echo -e "${BLUE}🔄 Attempting to save login cookies...${NC}"

# First get any session cookies from the login page
curl -s -c "$COOKIE_FILE" "$URL/auth/login" > /dev/null

# Then attempt login
login_result=$(curl -s -b "$COOKIE_FILE" -c "$COOKIE_FILE" \
    -d "username=$username" \
    -d "password=$password" \
    -d "submit=Login" \
    -w "%{http_code}" \
    -o /dev/null \
    "$URL/auth/login")

if [ "$login_result" = "302" ] || [ "$login_result" = "200" ]; then
    echo -e "${GREEN}✅ Login successful! Cookies saved to $COOKIE_FILE${NC}"
    echo -e "${GREEN}🎉 Auto-login is now enabled for future startups${NC}"
    
    # Verify cookies work
    echo -e "${BLUE}🔍 Verifying auto-login...${NC}"
    test_result=$(curl -s -b "$COOKIE_FILE" -w "%{http_code}" -o /dev/null "$URL/dashboard")
    
    if [ "$test_result" = "200" ]; then
        echo -e "${GREEN}✅ Auto-login verification successful!${NC}"
    else
        echo -e "${YELLOW}⚠️  Auto-login verification failed, but cookies are saved${NC}"
    fi
else
    echo -e "${RED}❌ Login failed (HTTP $login_result)${NC}"
    echo -e "${YELLOW}💡 Please check your username and password${NC}"
    rm -f "$COOKIE_FILE"
    exit 1
fi

echo -e "\n${BLUE}📋 Next steps:${NC}"
echo -e "  • Run ${YELLOW}./start-leantime.sh${NC} to start with auto-login"
echo -e "  • Your session will be automatically restored"
echo -e "  • To disable auto-login, delete: ${YELLOW}$COOKIE_FILE${NC}" 