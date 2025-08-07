#!/usr/bin/env python3
"""
Enhanced Multi-Agent Startup Script for Project Orion Data Tasks
Specifically designed for complex data folder work with sophisticated AI capabilities
"""

import json
import sys
import argparse
from pathlib import Path
from enhanced_multi_agent_system import EnhancedMultiAgentCoordinator, create_enhanced_task_lists

def load_enhanced_config(config_path: str = "enhanced_multi_agent_config.json"):
    """Load enhanced configuration from file"""
    try:
        with open(config_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        # Create default enhanced config
        default_config = {
            "project_path": "/Users/bursasaw/Documents/Morph Studios/ProjectOrion-0.12.12",
            "enhanced_agents": {
                "enemy_database": {
                    "description": "Creates comprehensive enemy databases for all worlds",
                    "focus_areas": ["enemies", "bosses", "elites", "loot_tables"],
                    "priority": "high",
                    "estimated_duration_hours": 8,
                    "sophistication_level": "expert"
                },
                "combat_abilities": {
                    "description": "Creates sophisticated combat abilities and systems",
                    "focus_areas": ["abilities", "combat", "effects", "balance"],
                    "priority": "high", 
                    "estimated_duration_hours": 6,
                    "sophistication_level": "expert"
                },
                "content_analysis": {
                    "description": "Analyzes and optimizes all data content",
                    "focus_areas": ["analysis", "optimization", "testing", "quality"],
                    "priority": "medium",
                    "estimated_duration_hours": 4,
                    "sophistication_level": "expert"
                },
                "world_content": {
                    "description": "Creates world-specific content and lore",
                    "focus_areas": ["worlds", "lore", "themes", "atmosphere"],
                    "priority": "medium",
                    "estimated_duration_hours": 10,
                    "sophistication_level": "expert"
                },
                "status_effects": {
                    "description": "Creates comprehensive status effect systems",
                    "focus_areas": ["effects", "buffs", "debuffs", "interactions"],
                    "priority": "medium",
                    "estimated_duration_hours": 5,
                    "sophistication_level": "expert"
                },
                "armor_mod_sets": {
                    "description": "Creates armor sets and mod combinations",
                    "focus_areas": ["armor", "mods", "sets", "synergies"],
                    "priority": "low",
                    "estimated_duration_hours": 7,
                    "sophistication_level": "expert"
                }
            },
            "enhanced_coordination": {
                "status_check_interval": 30,
                "log_level": "INFO",
                "auto_restart_failed_agents": True,
                "max_concurrent_agents": 6,
                "sophistication_mode": "expert",
                "data_analysis_depth": "comprehensive"
            },
            "enhanced_task_types": {
                "enemy_database_creation": {
                    "description": "Create sophisticated enemy databases with unique abilities and lore",
                    "estimated_time_minutes": 45,
                    "sophistication_required": "expert"
                },
                "combat_abilities_creation": {
                    "description": "Create complex combat abilities with unique effects and interactions",
                    "estimated_time_minutes": 30,
                    "sophistication_required": "expert"
                },
                "status_effects_creation": {
                    "description": "Create comprehensive status effect systems with interactions",
                    "estimated_time_minutes": 25,
                    "sophistication_required": "expert"
                },
                "armor_sets_creation": {
                    "description": "Create armor sets with set bonuses and synergies",
                    "estimated_time_minutes": 35,
                    "sophistication_required": "expert"
                },
                "mod_sets_creation": {
                    "description": "Create mod combinations with unique synergies",
                    "estimated_time_minutes": 40,
                    "sophistication_required": "expert"
                },
                "boss_encounters_creation": {
                    "description": "Create unique boss encounters with complex mechanics",
                    "estimated_time_minutes": 50,
                    "sophistication_required": "expert"
                },
                "world_content_creation": {
                    "description": "Create world-specific content and atmospheric elements",
                    "estimated_time_minutes": 60,
                    "sophistication_required": "expert"
                },
                "data_analysis": {
                    "description": "Comprehensive analysis of existing data for optimization",
                    "estimated_time_minutes": 20,
                    "sophistication_required": "expert"
                },
                "content_optimization": {
                    "description": "Optimize and enhance existing content",
                    "estimated_time_minutes": 30,
                    "sophistication_required": "expert"
                },
                "comprehensive_testing": {
                    "description": "Comprehensive testing of all data systems",
                    "estimated_time_minutes": 25,
                    "sophistication_required": "expert"
                }
            }
        }
        
        # Save default config
        with open(config_path, 'w') as f:
            json.dump(default_config, f, indent=2)
        
        return default_config

def display_enhanced_agent_status(coordinator: EnhancedMultiAgentCoordinator):
    """Display current status of all enhanced agents"""
    status = coordinator.get_all_status()
    
    print("\n" + "="*70)
    print("ENHANCED MULTI-AGENT STATUS REPORT")
    print("="*70)
    
    for agent_id, agent_status in status.items():
        status_icon = "🟢" if agent_status['is_running'] else "🔴"
        progress_bar = "█" * int(agent_status['progress_percentage'] / 5) + "░" * (20 - int(agent_status['progress_percentage'] / 5))
        
        print(f"\n{status_icon} Enhanced Agent: {agent_id}")
        print(f"   Progress: [{progress_bar}] {agent_status['progress_percentage']:.1f}%")
        print(f"   Tasks: {agent_status['completed_tasks']}/{agent_status['total_tasks']} completed")
        print(f"   Failed: {agent_status['failed_tasks']} tasks")
        
        if agent_status['is_running']:
            current_task = agent_status['current_task_index'] + 1
            print(f"   Current: Task {current_task} of {agent_status['total_tasks']}")

def main():
    parser = argparse.ArgumentParser(description="Enhanced Multi-Agent System for Project Orion Data Tasks")
    parser.add_argument("--config", default="enhanced_multi_agent_config.json", help="Enhanced configuration file path")
    parser.add_argument("--agents", nargs="+", help="Specific enhanced agents to run (default: all)")
    parser.add_argument("--monitor", action="store_true", help="Monitor progress continuously")
    parser.add_argument("--status", action="store_true", help="Show current status and exit")
    parser.add_argument("--stop", action="store_true", help="Stop all enhanced agents")
    parser.add_argument("--expert-mode", action="store_true", help="Enable expert-level sophistication")
    
    args = parser.parse_args()
    
    # Load enhanced configuration
    config = load_enhanced_config(args.config)
    project_path = config["project_path"]
    coordinator = EnhancedMultiAgentCoordinator(project_path)
    
    # Handle stop command
    if args.stop:
        print("Stopping all enhanced agents...")
        coordinator.stop_all_agents()
        print("All enhanced agents stopped.")
        return
    
    # Handle status command
    if args.status:
        display_enhanced_agent_status(coordinator)
        return
    
    # Create enhanced task lists
    task_lists = create_enhanced_task_lists()
    
    # Determine which agents to run
    agents_to_run = args.agents if args.agents else list(task_lists.keys())
    
    # Validate agent names
    valid_agents = list(task_lists.keys())
    invalid_agents = [agent for agent in agents_to_run if agent not in valid_agents]
    if invalid_agents:
        print(f"Invalid enhanced agents: {invalid_agents}")
        print(f"Valid enhanced agents: {valid_agents}")
        return
    
    # Create and start enhanced agents
    print(f"🚀 Starting Enhanced Multi-Agent System for Project Orion Data Tasks...")
    print(f"📁 Project Path: {project_path}")
    print(f"🤖 Enhanced Agents to run: {agents_to_run}")
    
    if args.expert_mode:
        print(f"🧠 Expert Mode: ENABLED - Maximum sophistication and complexity")
    
    total_hours = sum(config['enhanced_agents'][agent]['estimated_duration_hours'] 
                     for agent in agents_to_run if agent in config['enhanced_agents'])
    print(f"⏱️  Total estimated time: {total_hours} hours")
    
    # Create enhanced agents
    for agent_id in agents_to_run:
        if agent_id in task_lists:
            coordinator.create_agent(agent_id, task_lists[agent_id])
            agent_config = config['enhanced_agents'].get(agent_id, {})
            print(f"✅ Created enhanced agent: {agent_id} ({agent_config.get('description', 'Expert AI Agent')})")
    
    # Start enhanced agents
    print("\n🚀 Starting enhanced agents...")
    for agent_id in agents_to_run:
        if agent_id in coordinator.agents:
            coordinator.start_agent(agent_id)
            print(f"🚀 Started enhanced agent: {agent_id}")
    
    print(f"\n🎯 {len(agents_to_run)} enhanced agents are now working on complex data tasks!")
    print("These agents are specifically designed for sophisticated data folder work.")
    print("Press Ctrl+C to stop all enhanced agents")
    
    # Monitor progress if requested
    if args.monitor:
        try:
            while True:
                display_enhanced_agent_status(coordinator)
                
                # Check if all agents are done
                status = coordinator.get_all_status()
                all_done = all(not status[agent_id]['is_running'] for agent_id in status)
                if all_done:
                    print("\n🎉 All enhanced agents completed their complex data tasks!")
                    break
                
                # Wait before next status check
                import time
                time.sleep(config["enhanced_coordination"]["status_check_interval"])
                
        except KeyboardInterrupt:
            print("\n⏹️ Stopping all enhanced agents...")
            coordinator.stop_all_agents()
            print("All enhanced agents stopped.")
    
    else:
        # Just start and let them run in background
        print("\n📊 Enhanced agents are running in the background.")
        print("Use --monitor to watch progress, --status to check current status, or --stop to stop all agents.")
        print("Enhanced log files are being created for each agent in the current directory.")

if __name__ == "__main__":
    main() 