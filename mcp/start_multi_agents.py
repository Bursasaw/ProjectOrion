#!/usr/bin/env python3
"""
Startup script for Multi-Agent Task Distribution System
Easy way to launch multiple AI agents working on Project Orion
"""

import json
import sys
import argparse
from pathlib import Path
from multi_agent_task_system import MultiAgentCoordinator, create_task_lists

def load_config(config_path: str = "multi_agent_config.json"):
    """Load configuration from file"""
    try:
        with open(config_path, 'r') as f:
            return json.load(f)
    except FileNotFoundError:
        print(f"Configuration file {config_path} not found!")
        return None

def display_agent_status(coordinator: MultiAgentCoordinator):
    """Display current status of all agents"""
    status = coordinator.get_all_status()
    
    print("\n" + "="*60)
    print("MULTI-AGENT STATUS REPORT")
    print("="*60)
    
    for agent_id, agent_status in status.items():
        status_icon = "🟢" if agent_status['is_running'] else "🔴"
        progress_bar = "█" * int(agent_status['progress_percentage'] / 5) + "░" * (20 - int(agent_status['progress_percentage'] / 5))
        
        print(f"\n{status_icon} Agent: {agent_id}")
        print(f"   Progress: [{progress_bar}] {agent_status['progress_percentage']:.1f}%")
        print(f"   Tasks: {agent_status['completed_tasks']}/{agent_status['total_tasks']} completed")
        print(f"   Failed: {agent_status['failed_tasks']} tasks")
        
        if agent_status['is_running']:
            current_task = agent_status['current_task_index'] + 1
            print(f"   Current: Task {current_task} of {agent_status['total_tasks']}")

def main():
    parser = argparse.ArgumentParser(description="Multi-Agent Task Distribution System")
    parser.add_argument("--config", default="multi_agent_config.json", help="Configuration file path")
    parser.add_argument("--agents", nargs="+", help="Specific agents to run (default: all)")
    parser.add_argument("--monitor", action="store_true", help="Monitor progress continuously")
    parser.add_argument("--status", action="store_true", help="Show current status and exit")
    parser.add_argument("--stop", action="store_true", help="Stop all agents")
    
    args = parser.parse_args()
    
    # Load configuration
    config = load_config(args.config)
    if not config:
        return
    
    project_path = config["project_path"]
    coordinator = MultiAgentCoordinator(project_path)
    
    # Handle stop command
    if args.stop:
        print("Stopping all agents...")
        coordinator.stop_all_agents()
        print("All agents stopped.")
        return
    
    # Handle status command
    if args.status:
        display_agent_status(coordinator)
        return
    
    # Create task lists
    task_lists = create_task_lists()
    
    # Determine which agents to run
    agents_to_run = args.agents if args.agents else list(task_lists.keys())
    
    # Validate agent names
    valid_agents = list(task_lists.keys())
    invalid_agents = [agent for agent in agents_to_run if agent not in valid_agents]
    if invalid_agents:
        print(f"Invalid agents: {invalid_agents}")
        print(f"Valid agents: {valid_agents}")
        return
    
    # Create and start agents
    print(f"Starting Multi-Agent System for Project Orion...")
    print(f"Project Path: {project_path}")
    print(f"Agents to run: {agents_to_run}")
    print(f"Total estimated time: {sum(config['agents'][agent]['estimated_duration_hours'] for agent in agents_to_run if agent in config['agents'])} hours")
    
    # Create agents
    for agent_id in agents_to_run:
        if agent_id in task_lists:
            coordinator.create_agent(agent_id, task_lists[agent_id])
            print(f"✅ Created agent: {agent_id}")
    
    # Start agents
    print("\n🚀 Starting agents...")
    for agent_id in agents_to_run:
        if agent_id in coordinator.agents:
            coordinator.start_agent(agent_id)
            print(f"🚀 Started agent: {agent_id}")
    
    print(f"\n🎯 {len(agents_to_run)} agents are now working autonomously!")
    print("Press Ctrl+C to stop all agents")
    
    # Monitor progress if requested
    if args.monitor:
        try:
            while True:
                display_agent_status(coordinator)
                
                # Check if all agents are done
                status = coordinator.get_all_status()
                all_done = all(not status[agent_id]['is_running'] for agent_id in status)
                if all_done:
                    print("\n🎉 All agents completed their work!")
                    break
                
                # Wait before next status check
                import time
                time.sleep(config["coordination"]["status_check_interval"])
                
        except KeyboardInterrupt:
            print("\n⏹️ Stopping all agents...")
            coordinator.stop_all_agents()
            print("All agents stopped.")
    
    else:
        # Just start and let them run in background
        print("\n📊 Agents are running in the background.")
        print("Use --monitor to watch progress, --status to check current status, or --stop to stop all agents.")
        print("Log files are being created for each agent in the current directory.")

if __name__ == "__main__":
    main() 