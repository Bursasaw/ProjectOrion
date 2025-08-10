#!/bin/bash

echo "🚀 Setting up Project Orion MCP Automation System..."

# Install Python dependencies
echo "📦 Installing Python dependencies..."
pip install schedule requests tweepy praw discord.py python-dotenv

# Create environment file for API keys
echo "🔑 Creating environment configuration..."
cat > .env << EOF
# GitHub API Configuration
GITHUB_TOKEN=your_github_token_here
GITHUB_REPO=your_username/project-orion

# Twitter/X API Configuration
TWITTER_API_KEY=your_twitter_api_key
TWITTER_API_SECRET=your_twitter_api_secret
TWITTER_ACCESS_TOKEN=your_twitter_access_token
TWITTER_ACCESS_SECRET=your_twitter_access_secret

# Reddit API Configuration
REDDIT_CLIENT_ID=your_reddit_client_id
REDDIT_CLIENT_SECRET=your_reddit_client_secret
REDDIT_USERNAME=your_reddit_username
REDDIT_PASSWORD=your_reddit_password

# Discord API Configuration
DISCORD_TOKEN=your_discord_token
DISCORD_GUILD_ID=your_discord_guild_id

# Medium API Configuration
MEDIUM_TOKEN=your_medium_token

# YouTube API Configuration
YOUTUBE_API_KEY=your_youtube_api_key
EOF

echo "📝 Creating MCP automation log..."
touch mcp_automation.log

echo "🔧 Setting up automation schedules..."
cat > automation_schedule.json << EOF
{
  "daily_tasks": {
    "morning_update": "09:00",
    "evening_engagement": "17:00"
  },
  "weekly_tasks": {
    "technical_content": "monday 10:00",
    "progress_report": "friday 15:00"
  },
  "monthly_tasks": {
    "achievement_showcase": "first_day 12:00"
  }
}
EOF

echo "✅ MCP Automation System Setup Complete!"
echo ""
echo "📋 Next Steps:"
echo "1. Edit .env file with your API keys"
echo "2. Run: python mcp_master_controller.py"
echo "3. The system will automatically handle your marketing!"
echo ""
echo "🎯 You can now focus 100% on coding while the MCPs handle marketing!" 