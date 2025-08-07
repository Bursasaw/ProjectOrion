#!/usr/bin/env python3
"""
Demonstration of Multi-Agent Task Distribution System
Shows how multiple AI agents can work autonomously on different tasks
"""

import time
import threading
from multi_agent_task_system import MultiAgentCoordinator

def create_demo_tasks():
    """Create simple demo tasks for demonstration"""
    return {
        "demo_agent_1": [
            {
                "type": "code_implementation",
                "title": "Create Demo File 1",
                "file_path": "demo_file_1.txt",
                "code_content": "This is demo file 1 created by agent 1",
                "description": "Simple demo file creation"
            },
            {
                "type": "documentation",
                "title": "Update Demo Log",
                "doc_path": "demo_log.txt",
                "content": "Agent 1 completed demo file creation",
                "description": "Update demo log"
            }
        ],
        "demo_agent_2": [
            {
                "type": "code_implementation",
                "title": "Create Demo File 2",
                "file_path": "demo_file_2.txt",
                "code_content": "This is demo file 2 created by agent 2",
                "description": "Simple demo file creation"
            },
            {
                "type": "content_creation",
                "title": "Create Demo Content",
                "content_type": "items",
                "content_data": {
                    "items": [
                        {
                            "id": "demo_sword",
                            "name": "Demo Sword",
                            "type": "weapon",
                            "damage": 10
                        }
                    ]
                },
                "description": "Create demo item"
            }
        ]
    }

def main():
    """Run a demonstration of the multi-agent system"""
    print("🤖 MULTI-AGENT TASK DISTRIBUTION SYSTEM DEMO")
    print("=" * 50)
    print("This demo shows how multiple AI agents can work autonomously")
    print("on different tasks simultaneously within the same project.\n")
    
    # Create coordinator
    coordinator = MultiAgentCoordinator(".")
    
    # Create demo task lists
    demo_tasks = create_demo_tasks()
    
    print("📋 Creating demo agents...")
    for agent_id, tasks in demo_tasks.items():
        coordinator.create_agent(agent_id, tasks)
        print(f"✅ Created {agent_id} with {len(tasks)} tasks")
    
    print("\n🚀 Starting agents...")
    for agent_id in demo_tasks.keys():
        coordinator.start_agent(agent_id)
        print(f"🚀 Started {agent_id}")
    
    print("\n⏱️  Agents are now working autonomously...")
    print("Monitoring progress (press Ctrl+C to stop):\n")
    
    try:
        # Monitor progress for 30 seconds
        start_time = time.time()
        while time.time() - start_time < 30:
            status = coordinator.get_all_status()
            
            # Clear screen (simple approach)
            print("\033[2J\033[H")  # Clear screen and move cursor to top
            
            print("🤖 MULTI-AGENT STATUS REPORT")
            print("=" * 50)
            print(f"Time elapsed: {int(time.time() - start_time)}s\n")
            
            for agent_id, agent_status in status.items():
                status_icon = "🟢" if agent_status['is_running'] else "🔴"
                progress_bar = "█" * int(agent_status['progress_percentage'] / 5) + "░" * (20 - int(agent_status['progress_percentage'] / 5))
                
                print(f"{status_icon} {agent_id}")
                print(f"   Progress: [{progress_bar}] {agent_status['progress_percentage']:.1f}%")
                print(f"   Completed: {agent_status['completed_tasks']}/{agent_status['total_tasks']}")
                print(f"   Failed: {agent_status['failed_tasks']}")
                
                if agent_status['is_running']:
                    current_task = agent_status['current_task_index'] + 1
                    print(f"   Current: Task {current_task} of {agent_status['total_tasks']}")
                print()
            
            # Check if all agents are done
            all_done = all(not status[agent_id]['is_running'] for agent_id in status)
            if all_done:
                print("🎉 All agents completed their work!")
                break
            
            time.sleep(2)  # Update every 2 seconds
            
    except KeyboardInterrupt:
        print("\n⏹️  Stopping all agents...")
        coordinator.stop_all_agents()
        print("All agents stopped.")
    
    # Show final results
    print("\n📊 FINAL RESULTS")
    print("=" * 50)
    
    status = coordinator.get_all_status()
    for agent_id, agent_status in status.items():
        print(f"\n{agent_id}:")
        print(f"  ✅ Completed: {agent_status['completed_tasks']} tasks")
        print(f"  ❌ Failed: {agent_status['failed_tasks']} tasks")
        print(f"  📈 Success Rate: {(agent_status['completed_tasks'] / agent_status['total_tasks'] * 100):.1f}%")
    
    print("\n🎯 DEMO COMPLETE!")
    print("This demonstrates how multiple AI agents can work autonomously")
    print("on different tasks simultaneously, achieving parallel development.")
    print("\nIn a real scenario, you would have:")
    print("- 6 specialized agents working for hours")
    print("- Complex code implementation and testing")
    print("- Content creation and documentation")
    print("- Performance optimization and bug fixing")
    print("- All working simultaneously on your game project!")

if __name__ == "__main__":
    main() 