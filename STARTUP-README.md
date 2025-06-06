# 🚀 Leantime Startup Scripts

Quick and easy scripts to start your Leantime development server with all the bells and whistles!

## 📂 Files Created

- **`start-leantime.sh`** - macOS/Linux startup script
- **`start-leantime.bat`** - Windows startup script  
- **`save-login.sh`** - Auto-login setup helper (macOS/Linux)

## 🎯 Features

✅ **Smart Port Management** - Uses port 9000 (distinct from 8XXX range)  
✅ **Port Conflict Resolution** - Automatically kills processes using the port  
✅ **Auto-Start Server** - Starts PHP development server  
✅ **Browser Auto-Open** - Opens your default browser to the login page  
✅ **Cookie-Based Auto-Login** - Skip login after initial setup  
✅ **Graceful Shutdown** - Clean server shutdown with Ctrl+C  
✅ **Colorful Output** - Beautiful terminal output with status indicators  

## 🖥 Usage

### macOS/Linux
```bash
# Start the server
./start-leantime.sh

# After completing initial setup, enable auto-login
./save-login.sh
```

### Windows
```cmd
# Start the server
start-leantime.bat
```

## 🔧 How It Works

1. **Port Check**: Scans for processes using port 9000
2. **Process Kill**: Terminates any existing processes on the port
3. **Server Start**: Launches PHP development server in background
4. **Health Check**: Waits for server to become ready
5. **Browser Launch**: Opens http://localhost:9000 in your default browser
6. **Auto-Login**: Uses saved cookies if available

## 🍪 Auto-Login Setup

After completing your initial Leantime setup:

1. **macOS/Linux**: Run `./save-login.sh`
2. **Windows**: Use the curl command shown in the script output

The script will:
- Prompt for your username and password
- Save authentication cookies to `.leantime-cookies.txt`
- Verify the auto-login works
- Enable automatic login for future startups

## 🛑 Stopping the Server

### macOS/Linux
- Press `Ctrl+C` in the terminal running the script
- Or run: `pkill -f "php -S"`

### Windows  
- Close the command window
- Or press `Ctrl+C` in the window

## 🌐 Accessing Your Site

Once started, your Leantime installation will be available at:
**http://localhost:9000**

## 🔍 Troubleshooting

### Port Already in Use
The script automatically handles this by killing existing processes.

### Server Won't Start
- Check that PHP is installed and in your PATH
- Ensure you're in the Leantime root directory
- Check that port 9000 is available

### Auto-Login Not Working
- Complete the initial Leantime setup first
- Run the `save-login.sh` script after setup
- Check that `.leantime-cookies.txt` exists

### Browser Doesn't Open
- The script will show the URL to open manually
- Copy and paste: `http://localhost:9000`

## 📁 File Structure

```
leantime/
├── start-leantime.sh       # Main startup script (macOS/Linux)
├── start-leantime.bat      # Main startup script (Windows)
├── save-login.sh           # Auto-login helper (macOS/Linux)
├── .leantime-cookies.txt   # Saved login cookies (auto-generated)
└── STARTUP-README.md       # This file
```

## 🎨 Customization

### Change Port
Edit the `PORT=9000` line in the script to use a different port.

### Disable Auto-Login
Delete the `.leantime-cookies.txt` file.

### Modify Startup Behavior
Edit the script files to customize the startup process.

---

Happy coding! 🎉 Your Leantime development environment is ready to go! 