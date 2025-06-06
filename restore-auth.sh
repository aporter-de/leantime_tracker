#!/bin/bash

# Restore Authentication (Remove Development Bypass)

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔒 Restoring Leantime Authentication${NC}"
echo -e "${BLUE}===================================${NC}"

# Backup the current file
cp app/Core/Middleware/AuthCheck.php app/Core/Middleware/AuthCheck.php.dev-backup

echo -e "${YELLOW}📂 Backed up current AuthCheck.php to AuthCheck.php.dev-backup${NC}"

# Remove the development routes from publicActions
sed -i.tmp '/\/\/ TEMPORARY: Development bypass/,/help/d' app/Core/Middleware/AuthCheck.php

# Remove the setupDevelopmentUserSession method
sed -i.tmp '/\/\*\*/,/private function setupDevelopmentUserSession/d' app/Core/Middleware/AuthCheck.php
sed -i.tmp '/private function setupDevelopmentUserSession/,/^    }$/d' app/Core/Middleware/AuthCheck.php

# Remove the development session setup call from handle method
sed -i.tmp '/\/\/ TEMPORARY: Set up fake user session/,/}/d' app/Core/Middleware/AuthCheck.php

# Clean up temporary files
rm -f app/Core/Middleware/AuthCheck.php.tmp

echo -e "${GREEN}✅ Authentication restored!${NC}"
echo -e "${BLUE}📋 Changes made:${NC}"
echo -e "  • Removed development routes from publicActions"
echo -e "  • Removed fake user session setup"
echo -e "  • Normal login requirement restored"

echo -e "\n${YELLOW}💡 To use the application now:${NC}"
echo -e "  1. Run: ${YELLOW}./start-leantime.sh${NC}"
echo -e "  2. Complete login with:"
echo -e "     • Username: admin"
echo -e "     • Password: admin123"
echo -e "  3. Or run: ${YELLOW}./save-login.sh${NC} for auto-login"

echo -e "\n${BLUE}🔄 To restore development bypass later:${NC}"
echo -e "  • Copy back: ${YELLOW}cp app/Core/Middleware/AuthCheck.php.dev-backup app/Core/Middleware/AuthCheck.php${NC}" 