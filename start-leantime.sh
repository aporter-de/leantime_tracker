#!/bin/bash

# Leantime Development Server Startup Script
# Port to use (distinct from 8XXX range)
PORT=9000
HOST="localhost"
URL="http://$HOST:$PORT"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Leantime Development Server...${NC}"

# Function to check if port is in use
check_port() {
    lsof -ti:$PORT
}

# Function to kill process on port
kill_port() {
    local pid=$(check_port)
    if [ ! -z "$pid" ]; then
        echo -e "${YELLOW}⚠️  Port $PORT is in use by process $pid. Killing it...${NC}"
        kill -9 $pid
        sleep 2
        
        # Double check if process is killed
        if [ ! -z "$(check_port)" ]; then
            echo -e "${RED}❌ Failed to kill process on port $PORT${NC}"
            exit 1
        else
            echo -e "${GREEN}✅ Process killed successfully${NC}"
        fi
    fi
}

# Function to start PHP server
start_server() {
    echo -e "${BLUE}🔧 Starting PHP development server on port $PORT...${NC}"
    php -S $HOST:$PORT -t public &
    PHP_PID=$!
    
    # Wait a moment for server to start
    sleep 3
    
    # Check if server started successfully
    if ps -p $PHP_PID > /dev/null; then
        echo -e "${GREEN}✅ Server started successfully (PID: $PHP_PID)${NC}"
        echo -e "${GREEN}🌐 Access your site at: $URL${NC}"
    else
        echo -e "${RED}❌ Failed to start server${NC}"
        exit 1
    fi
}

# Function to wait for server to be ready
wait_for_server() {
    echo -e "${BLUE}⏳ Waiting for server to be ready...${NC}"
    local attempts=0
    local max_attempts=10
    
    while [ $attempts -lt $max_attempts ]; do
        if curl -s -o /dev/null -w "%{http_code}" $URL | grep -q "200\|303\|302"; then
            echo -e "${GREEN}✅ Server is ready!${NC}"
            return 0
        fi
        
        attempts=$((attempts + 1))
        echo -e "${YELLOW}⏳ Attempt $attempts/$max_attempts - Server not ready yet...${NC}"
        sleep 2
    done
    
    echo -e "${RED}❌ Server failed to become ready after $max_attempts attempts${NC}"
    return 1
}

# Function to open browser
open_browser() {
    echo -e "${BLUE}🔗 Opening browser...${NC}"
    
    # Check if we have saved cookies for auto-login
    COOKIE_FILE=".leantime-cookies.txt"
    
    if [ -f "$COOKIE_FILE" ]; then
        echo -e "${GREEN}🍪 Using saved cookies for auto-login${NC}"
        # Open with curl first to use cookies, then open browser
        curl -s -b "$COOKIE_FILE" "$URL" > /dev/null
    fi
    
    # Open browser (works on macOS)
    if command -v open > /dev/null; then
        open "$URL"
    elif command -v xdg-open > /dev/null; then
        xdg-open "$URL"
    else
        echo -e "${YELLOW}⚠️  Could not open browser automatically. Please open: $URL${NC}"
    fi
}

# Function to save cookies (for future auto-login)
save_cookies() {
    local cookie_file=".leantime-cookies.txt"
    echo -e "${BLUE}💾 To enable auto-login, complete the setup and then run:${NC}"
    echo -e "${YELLOW}curl -c '$cookie_file' -d 'username=YOUR_USERNAME&password=YOUR_PASSWORD' $URL/auth/login${NC}"
}

# Function to cleanup on exit
cleanup() {
    if [ ! -z "$PHP_PID" ] && ps -p $PHP_PID > /dev/null; then
        echo -e "\n${YELLOW}🛑 Shutting down server...${NC}"
        kill $PHP_PID
        echo -e "${GREEN}✅ Server stopped${NC}"
    fi
    exit 0
}

# Set up signal handlers for graceful shutdown
trap cleanup SIGINT SIGTERM

# Main execution
echo -e "${BLUE}=====================================
🎯 Project Tracker (Leantime)
🌐 Port: $PORT
📁 Directory: $(pwd)
=====================================${NC}"

# Check if we're in the right directory
if [ ! -f "public/index.php" ]; then
    echo -e "${RED}❌ Error: Not in Leantime directory. Please run this script from the Leantime root directory.${NC}"
    exit 1
fi

# Execute steps
kill_port
start_server

if wait_for_server; then
    open_browser
    save_cookies
    
    echo -e "\n${GREEN}✅ Leantime is running successfully!${NC}"
    echo -e "${BLUE}📋 Controls:${NC}"
    echo -e "  • Access: $URL"
    echo -e "  • Stop server: Press Ctrl+C"
    echo -e "  • Logs: Check this terminal"
    
    # Keep script running and show server logs
    echo -e "\n${BLUE}📊 Server logs:${NC}"
    wait $PHP_PID
else
    echo -e "${RED}❌ Failed to start Leantime${NC}"
    exit 1
fi 