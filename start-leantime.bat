@echo off
setlocal enabledelayedexpansion

:: Leantime Development Server Startup Script for Windows
:: Port to use (distinct from 8XXX range)
set PORT=9000
set HOST=localhost
set URL=http://!HOST!:!PORT!

echo.
echo ====================================
echo 🎯 Project Tracker (Leantime)
echo 🌐 Port: !PORT!
echo 📁 Directory: %CD%
echo ====================================
echo.

echo 🚀 Starting Leantime Development Server...

:: Check if we're in the right directory
if not exist "public\index.php" (
    echo ❌ Error: Not in Leantime directory. Please run this script from the Leantime root directory.
    pause
    exit /b 1
)

:: Function to check if port is in use and kill it
echo 🔍 Checking if port !PORT! is in use...
for /f "tokens=5" %%i in ('netstat -aon ^| findstr :!PORT!') do (
    set PID=%%i
    if defined PID (
        echo ⚠️  Port !PORT! is in use by process !PID!. Killing it...
        taskkill /PID !PID! /F >nul 2>&1
        timeout /t 2 >nul
        echo ✅ Process killed successfully
    )
)

:: Start PHP server
echo 🔧 Starting PHP development server on port !PORT!...
start "Leantime Server" /min php -S !HOST!:!PORT! -t public

:: Wait for server to start
echo ⏳ Waiting for server to be ready...
timeout /t 5 >nul

:: Check if server is ready
:check_server
set attempts=0
:check_loop
set /a attempts+=1
curl -s -o nul -w "%%{http_code}" !URL! | findstr "200 303 302" >nul
if !errorlevel! equ 0 (
    echo ✅ Server is ready!
    goto server_ready
)

if !attempts! lss 10 (
    echo ⏳ Attempt !attempts!/10 - Server not ready yet...
    timeout /t 2 >nul
    goto check_loop
) else (
    echo ❌ Server failed to become ready after 10 attempts
    pause
    exit /b 1
)

:server_ready
:: Check for saved cookies
set COOKIE_FILE=.leantime-cookies.txt
if exist "!COOKIE_FILE!" (
    echo 🍪 Using saved cookies for auto-login
    curl -s -b "!COOKIE_FILE!" "!URL!" >nul
)

:: Open browser
echo 🔗 Opening browser...
start "" "!URL!"

echo.
echo ✅ Leantime is running successfully!
echo.
echo 📋 Controls:
echo   • Access: !URL!
echo   • Stop server: Close this window or Ctrl+C
echo   • Server is running in background
echo.
echo 💾 To enable auto-login, complete the setup and then run:
echo curl -c "!COOKIE_FILE!" -d "username=YOUR_USERNAME&password=YOUR_PASSWORD" !URL!/auth/login
echo.
echo 📊 Server is running in background. Press any key to exit...
pause >nul

:: Cleanup - Kill PHP server processes on port
echo 🛑 Shutting down server...
for /f "tokens=5" %%i in ('netstat -aon ^| findstr :!PORT!') do (
    taskkill /PID %%i /F >nul 2>&1
)
echo ✅ Server stopped

endlocal 