# 🚀 Steam Integration Setup Guide

## **Overview**
This guide explains how to properly configure Steam integration for your game using the official GodotSteam API methods.

## **🎯 Proper Steam App ID Configuration (GodotSteam Way)**

### **Why NOT to Hardcode App IDs:**
- **Multi-player conflicts**: Different players need different App IDs
- **Development vs Production**: Different environments need different IDs
- **Security**: App IDs should not be in version control
- **Flexibility**: Easy to change without code modifications

### **✅ Recommended Approach (Using GodotSteam API):**

## **1. Project Settings Method (Recommended)**

### **In Godot Editor:**
1. Go to **Project Settings > Steam > Initialization**
2. Set your **App ID** in the project settings
3. Check **Embed Callbacks** for automatic callback handling
4. The game will automatically use these settings

### **For Development:**
- Use App ID **480** (Spacewar - Steam's test app)
- This allows testing without a real Steam app

### **For Production:**
- Use your actual **Steam App ID** from Steam Partner
- This will be your real game's App ID

## **2. Runtime Configuration Method**

### **In-Game Configuration:**
You can set the App ID programmatically using GodotSteam's API:
```gdscript
# Get the SteamManager
var steam_manager = get_node("/root/SteamManager")

# Set your App ID using GodotSteam's set_current_app_id
steam_manager.set_steam_app_id(1234567890)
```

## **3. Environment Variable Method**

### **For Development:**
```bash
# Set environment variable before running the game
export STEAM_APP_ID=480  # Spacewar (Steam's test app)
godot --path /path/to/your/game
```

### **For Production:**
```bash
# Set your actual Steam App ID
export STEAM_APP_ID=1234567890  # Your actual Steam App ID
```

## **🔧 Steam App ID Setup Process**

### **Step 1: Register Your Game on Steam**
1. Go to [Steam Partner](https://partner.steamgames.com/)
2. Create a new app
3. Get your **App ID** (it's a number like 1234567890)

### **Step 2: Configure Your Project**
1. **In Godot Editor**: Project Settings > Steam > Initialization
2. **Set App ID**: Enter your Steam App ID
3. **Check Embed Callbacks**: For automatic callback handling
4. **Save Project Settings**

### **Step 3: Test Steam Integration**
1. Run the game
2. Check console output for Steam initialization
3. Complete quests to test achievements
4. Save/load to test cloud saves

## **🎮 Steam Features Available**

### **Achievements:**
- **First Quest** - Complete your first quest
- **Combat Master** - Win 10 battles
- **Explorer** - Visit 5 locations
- **Collector** - Collect 20 unique items
- **Experienced** - Reach level 10
- **Story Teller** - Complete the main story

### **Cloud Saves:**
- Automatic cloud save/load
- Local fallback if cloud unavailable
- Cross-device save synchronization

### **Steam Integration:**
- User name and ID detection
- Steam status checking
- Achievement progress tracking

## **🚨 Important Notes**

### **Development vs Production:**
- **Development**: Use App ID 480 (Spacewar) for testing
- **Production**: Use your actual Steam App ID
- **Never commit App IDs** to version control

### **Testing:**
- Steam features work even without Steam running (graceful fallback)
- Achievements are tracked locally if Steam unavailable
- Cloud saves fall back to local saves

### **Distribution:**
- Each player should set their own App ID
- Include this guide with your game
- Consider adding an in-game Steam configuration menu

## **🔍 Troubleshooting**

### **Steam Not Initializing:**
1. Check if Steam is running
2. Verify App ID is set correctly in Project Settings
3. Check console for error messages from `steamInitEx()`

### **Achievements Not Working:**
1. Ensure Steam is running
2. Check if user is logged into Steam
3. Verify App ID matches your Steam app

### **Cloud Saves Not Working:**
1. Check Steam Cloud is enabled
2. Verify internet connection
3. Check Steam Cloud storage space

## **📝 Example Usage**

### **Setting App ID via Project Settings:**
1. Open **Project Settings**
2. Go to **Steam > Initialization**
3. Set **App ID** to your Steam App ID
4. Check **Embed Callbacks**
5. Save project settings

### **Setting App ID in Code:**
```gdscript
# In your game initialization
var steam_manager = get_node("/root/SteamManager")
steam_manager.set_steam_app_id(1234567890)
```

### **Getting Current App ID:**
```gdscript
# Get the current App ID that GodotSteam is using
var steam_manager = get_node("/root/SteamManager")
var current_app_id = steam_manager.get_steam_app_id()
print("Current App ID: ", current_app_id)
```

## **🎯 Best Practices**

1. **Use Project Settings** for App ID configuration
2. **Use GodotSteam's API methods** (`steamInitEx`, `set_current_app_id`)
3. **Provide clear documentation** for players
4. **Include fallback behavior** for non-Steam users
5. **Test thoroughly** in both Steam and non-Steam environments
6. **Use proper GodotSteam initialization** with `steamInitEx()`

## **🔧 Technical Details**

### **GodotSteam API Methods Used:**
- `Steam.steamInitEx(app_id, embed_callbacks)` - Proper initialization
- `Steam.get_current_app_id()` - Get current App ID
- `Steam.set_current_app_id(app_id)` - Set App ID at runtime
- `Steam.setAchievement(achievement_id)` - Unlock achievements
- `Steam.fileWrite()` / `Steam.fileRead()` - Cloud saves

### **Initialization Flow:**
1. Call `Steam.steamInitEx(0, true)` for auto-detection
2. Check return status for `STEAM_API_INIT_RESULT_OK`
3. Get current App ID with `Steam.get_current_app_id()`
4. Set up callbacks and features

---

**This approach uses the official GodotSteam API methods and ensures your game works for all players while maintaining proper Steam integration!** 🚀 