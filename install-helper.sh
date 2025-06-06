#!/bin/bash

# Leantime Installation Helper
PORT=9000
HOST="localhost"
URL="http://$HOST:$PORT"

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🛠  Leantime Installation Helper${NC}"
echo -e "${BLUE}===============================${NC}"

# Check if server is running
if ! curl -s -o /dev/null -w "%{http_code}" $URL | grep -q "200\|303\|302"; then
    echo -e "${RED}❌ Server is not running on $URL${NC}"
    echo -e "${YELLOW}💡 Start the server first using: ./start-leantime.sh${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Server is running on $URL${NC}"

# Check if installation is needed
install_check=$(curl -s -w "%{http_code}" -o /dev/null "$URL/dashboard" 2>/dev/null)
if [ "$install_check" = "200" ]; then
    echo -e "${GREEN}✅ Leantime is already installed!${NC}"
    echo -e "${BLUE}🌐 Access your dashboard at: $URL/dashboard${NC}"
    
    # Open dashboard
    if command -v open > /dev/null; then
        open "$URL/dashboard"
    fi
    exit 0
fi

echo -e "${BLUE}📋 Installation Information:${NC}"
echo -e "${YELLOW}Database Host:${NC} localhost"
echo -e "${YELLOW}Database Name:${NC} projectTrackerDatabase"  
echo -e "${YELLOW}Database User:${NC} admin"
echo -e "${YELLOW}Database Password:${NC} admin"
echo -e "${YELLOW}Database Port:${NC} 3306"
echo ""

echo -e "${BLUE}🔄 Attempting automated installation...${NC}"

# Try to post installation data
install_result=$(curl -s -w "%{http_code}" \
    -d "dbHost=localhost" \
    -d "dbUser=admin" \
    -d "dbPassword=admin" \
    -d "dbDatabase=projectTrackerDatabase" \
    -d "dbPort=3306" \
    -d "lean_db_table_prefix=" \
    -d "firstname=Admin" \
    -d "lastname=User" \
    -d "email=admin@projecttracker.local" \
    -d "username=admin" \
    -d "password=admin123" \
    -d "password2=admin123" \
    -d "company=Project Tracker" \
    -d "install=1" \
    -o /dev/null \
    "$URL/install")

if [ "$install_result" = "302" ] || [ "$install_result" = "200" ]; then
    echo -e "${GREEN}✅ Automated installation successful!${NC}"
    
    # Wait a moment for installation to complete
    sleep 3
    
    echo -e "${GREEN}🎉 Installation Complete!${NC}"
    echo -e "${BLUE}📋 Your Login Credentials:${NC}"
    echo -e "  • URL: $URL"
    echo -e "  • Username: admin"  
    echo -e "  • Password: admin123"
    echo -e "  • Email: admin@projecttracker.local"
    
    # Open login page
    echo -e "${BLUE}🔗 Opening login page...${NC}"
    if command -v open > /dev/null; then
        open "$URL/auth/login"
    fi
    
    echo -e "\n${YELLOW}💡 Next steps:${NC}"
    echo -e "  1. Log in with the credentials above"
    echo -e "  2. Run ${YELLOW}./save-login.sh${NC} to enable auto-login"
    
else
    echo -e "${RED}❌ Automated installation failed (HTTP $install_result)${NC}"
    echo -e "${YELLOW}📋 Manual Installation Required:${NC}"
    echo -e "  1. Open: $URL/install"
    echo -e "  2. Use these database settings:"
    echo -e "     • Host: localhost"
    echo -e "     • Database: projectTrackerDatabase"
    echo -e "     • Username: admin"
    echo -e "     • Password: admin"
    echo -e "     • Port: 3306"
    echo -e "  3. Create your admin account"
    
    # Open install page
    if command -v open > /dev/null; then
        open "$URL/install"
    fi
fi 