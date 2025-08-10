# 🔧 MCP Server Setup Guide

## **Overview**
This guide helps you configure the MCP (Model Context Protocol) servers for enhanced AI assistance capabilities including web scraping, search, and file operations.

## **🚀 Quick Start - Essential APIs**

### **1. Web Search APIs (Most Important)**

#### **Brave Search API**
1. Go to [Brave Search API](https://api.search.brave.com/)
2. Sign up for a free account
3. Get your API key
4. Replace `your_brave_api_key_here` in `mcp.json`

#### **DuckDuckGo Search** (No API key needed)
- Already configured and ready to use
- Privacy-focused search engine

### **2. Web Scraping APIs**

#### **Puppeteer** (No API key needed)
- Already configured for web scraping
- Can scrape any website including GodotSteam docs

#### **Curl** (No API key needed)
- Already configured for HTTP requests
- Can download files and access web content

## **🔑 Optional API Keys**

### **GitHub Integration**
1. Go to [GitHub Settings > Developer settings > Personal access tokens](https://github.com/settings/tokens)
2. Generate a new token with `repo` and `read:user` permissions
3. Replace `your_github_token_here` in `mcp.json`

### **YouTube API** (For video research)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Enable YouTube Data API v3
3. Create credentials (API key)
4. Replace `your_youtube_api_key_here` in `mcp.json`

### **Weather API** (For game world weather)
1. Go to [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for free API key
3. Replace `your_openweather_api_key_here` in `mcp.json`

## **📁 File System Configuration**

The filesystem server is already configured to work with your project:
- **Root Path**: `/Users/bursasaw/Documents/Morph Studios`
- **Project Access**: Full access to Project Orion files
- **No API Key Required**: Ready to use immediately

## **🗄️ Database Configuration**

### **SQLite** (Recommended for your game)
- Already configured for your project
- Database path: `Project Orion/data/game.db`
- No API key required

### **PostgreSQL** (Optional)
- Replace connection string with your database details
- Only needed if you want external database integration

## **🎯 Immediate Setup Steps**

### **Step 1: Get Brave Search API Key**
1. Visit [Brave Search API](https://api.search.brave.com/)
2. Sign up and get your free API key
3. Update `mcp.json` with your key

### **Step 2: Test Basic Functionality**
The following servers work immediately without API keys:
- ✅ **Memory** - Persistent conversation memory
- ✅ **Filesystem** - File operations on your project
- ✅ **DuckDuckGo Search** - Web search
- ✅ **Puppeteer** - Web scraping
- ✅ **Curl** - HTTP requests and downloads
- ✅ **Wikipedia** - Wikipedia article access
- ✅ **SQLite** - Database operations

### **Step 3: Restart Cursor**
After updating `mcp.json`, restart Cursor to load the new MCP servers.

## **🔍 What You Can Do Now**

### **Web Research**
- Search for GodotSteam documentation
- Scrape websites for information
- Download files and documentation
- Access Wikipedia articles

### **File Operations**
- Read and write files in your project
- Navigate your file system
- Manage project assets

### **Database Operations**
- Store and retrieve game data
- Create save game databases
- Track player progress

### **Memory Features**
- Remember previous conversations
- Maintain context across sessions
- Track project decisions and changes

## **🎮 Game Development Benefits**

### **Research Capabilities**
- Search for Godot tutorials and documentation
- Find game assets and resources
- Research Steam integration best practices
- Access GitHub repositories and examples

### **Project Management**
- File system access for project organization
- Database integration for save systems
- Memory for tracking development decisions
- Documentation research and creation

### **Steam Integration Research**
- Search for GodotSteam documentation
- Find implementation examples
- Research Steam API best practices
- Access GitHub repositories with Steam integration

## **🚨 Troubleshooting**

### **MCP Servers Not Loading**
1. Check that `mcp.json` is in the correct location
2. Verify JSON syntax is valid
3. Restart Cursor completely
4. Check console for error messages

### **API Key Issues**
1. Verify API keys are correct
2. Check API service status
3. Ensure you have proper permissions
4. Test with a simple search first

### **File System Access**
1. Verify the root path is correct
2. Check file permissions
3. Ensure the directory exists
4. Test with a simple file read operation

## **📝 Example Usage**

### **Search for GodotSteam Documentation**
```
"Search for GodotSteam API documentation and implementation examples"
```

### **Scrape Website Content**
```
"Scrape the content from https://godotsteam.com/classes/main/"
```

### **Download Files**
```
"Download the latest GodotSteam addon from GitHub"
```

### **Research Game Development**
```
"Find tutorials on Steam achievement implementation in Godot"
```

## **🔧 Advanced Configuration**

### **Custom File System Paths**
You can modify the `MCP_FILESYSTEM_ROOT` to point to different directories:
```json
"MCP_FILESYSTEM_ROOT": "/path/to/your/project"
```

### **Database Configuration**
For SQLite, you can change the database path:
```json
"MCP_SQLITE_DB_PATH": "/path/to/your/database.db"
```

### **API Rate Limits**
Most free APIs have rate limits:
- Brave Search: 1000 requests/month (free)
- DuckDuckGo: No rate limit
- Puppeteer: No rate limit
- Wikipedia: No rate limit

---

**With this setup, you'll have powerful research and development capabilities for your Godot game project!** 🚀 