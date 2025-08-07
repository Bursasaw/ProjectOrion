#!/usr/bin/env python3
"""
Enhanced Multi-Agent Task Distribution System for Project Orion
Specifically designed to handle complex data folder tasks with sophisticated AI capabilities
"""

import json
import time
import threading
import logging
import os
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Optional
import re

class EnhancedTaskAgent:
    """Enhanced AI agent with sophisticated capabilities for complex tasks"""
    
    def __init__(self, agent_id: str, task_list: List[Dict], project_path: str):
        self.agent_id = agent_id
        self.task_list = task_list
        self.project_path = project_path
        self.current_task_index = 0
        self.is_running = False
        self.completed_tasks = []
        self.failed_tasks = []
        self.logger = self.setup_logging()
        self.analysis_cache = {}
        
    def setup_logging(self):
        """Setup logging for this agent"""
        logging.basicConfig(
            level=logging.INFO,
            format=f'%(asctime)s - EnhancedAgent_{self.agent_id} - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler(f'enhanced_agent_{self.agent_id}_log.txt'),
                logging.StreamHandler()
            ]
        )
        return logging.getLogger(f'EnhancedAgent_{self.agent_id}')
    
    def start_work(self):
        """Start autonomous work on complex task list"""
        self.is_running = True
        self.logger.info(f"Enhanced Agent {self.agent_id} starting work on {len(self.task_list)} complex tasks")
        
        while self.is_running and self.current_task_index < len(self.task_list):
            task = self.task_list[self.current_task_index]
            self.logger.info(f"Working on complex task: {task.get('title', 'Unknown')}")
            
            try:
                success = self.execute_enhanced_task(task)
                if success:
                    self.completed_tasks.append(task)
                    self.logger.info(f"Completed complex task: {task.get('title', 'Unknown')}")
                else:
                    self.failed_tasks.append(task)
                    self.logger.warning(f"Failed complex task: {task.get('title', 'Unknown')}")
            except Exception as e:
                self.logger.error(f"Error executing complex task: {e}")
                self.failed_tasks.append(task)
            
            self.current_task_index += 1
            
            if self.check_stop_signal():
                break
                
        self.logger.info(f"Enhanced Agent {self.agent_id} finished work. Completed: {len(self.completed_tasks)}, Failed: {len(self.failed_tasks)}")
    
    def execute_enhanced_task(self, task: Dict) -> bool:
        """Execute complex tasks with sophisticated AI capabilities"""
        task_type = task.get('type', 'unknown')
        
        if task_type == 'enemy_database_creation':
            return self.create_enemy_database(task)
        elif task_type == 'combat_abilities_creation':
            return self.create_combat_abilities(task)
        elif task_type == 'status_effects_creation':
            return self.create_status_effects(task)
        elif task_type == 'armor_sets_creation':
            return self.create_armor_sets(task)
        elif task_type == 'mod_sets_creation':
            return self.create_mod_sets(task)
        elif task_type == 'boss_encounters_creation':
            return self.create_boss_encounters(task)
        elif task_type == 'world_content_creation':
            return self.create_world_content(task)
        elif task_type == 'data_analysis':
            return self.analyze_existing_data(task)
        elif task_type == 'content_optimization':
            return self.optimize_content(task)
        elif task_type == 'comprehensive_testing':
            return self.run_comprehensive_tests(task)
        else:
            self.logger.warning(f"Unknown enhanced task type: {task_type}")
            return False
    
    def create_enemy_database(self, task: Dict) -> bool:
        """Create comprehensive enemy database based on world themes"""
        try:
            world_theme = task.get('world_theme', 'terra')
            enemy_count = task.get('enemy_count', 15)
            
            self.logger.info(f"Creating {enemy_count} enemies for {world_theme}")
            
            # Load existing enemy data if it exists
            enemies_file = os.path.join(self.project_path, 'data/enemies/enemies.json')
            existing_enemies = []
            
            if os.path.exists(enemies_file):
                with open(enemies_file, 'r') as f:
                    existing_enemies = json.load(f)
            
            # Create world-specific enemies
            new_enemies = self.generate_world_enemies(world_theme, enemy_count)
            
            # Add to existing enemies
            all_enemies = existing_enemies + new_enemies
            
            # Ensure directory exists
            os.makedirs(os.path.dirname(enemies_file), exist_ok=True)
            
            # Save enhanced enemy database
            with open(enemies_file, 'w') as f:
                json.dump(all_enemies, f, indent=2)
            
            self.logger.info(f"Created {len(new_enemies)} enemies for {world_theme}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error creating enemy database: {e}")
            return False
    
    def generate_world_enemies(self, world_theme: str, count: int) -> List[Dict]:
        """Generate sophisticated enemies based on world theme"""
        enemies = []
        
        # World-specific enemy templates
        templates = {
            'terra': {
                'names': ['Ancient Treant', 'Crystal Guardian', 'Forest Spirit', 'Life Force Manifestation', 'Primal Beast'],
                'abilities': ['Nature Regeneration', 'Crystal Refraction', 'Life Force Absorption', 'Primal Rage'],
                'themes': ['nature', 'life', 'primal', 'crystal', 'forest']
            },
            'nokturn': {
                'names': ['Shadow Stalker', 'Void Wraith', 'Dark Mage', 'Nightmare Creature', 'Void Horror'],
                'abilities': ['Shadow Phase', 'Void Distortion', 'Fear Aura', 'Void Absorption'],
                'themes': ['shadow', 'void', 'darkness', 'fear', 'nightmare']
            },
            'elysion': {
                'names': ['Light Guardian', 'Divine Sentinel', 'Celestial Being', 'Ancient Sage', 'Holy Warrior'],
                'abilities': ['Divine Protection', 'Holy Smite', 'Wisdom Drain', 'Light Purification'],
                'themes': ['light', 'divine', 'holy', 'celestial', 'wisdom']
            }
        }
        
        template = templates.get(world_theme, templates['terra'])
        
        for i in range(count):
            enemy = {
                'id': f"{world_theme}_enemy_{i+1}",
                'name': f"{template['names'][i % len(template['names'])]} {i+1}",
                'world': world_theme,
                'level': 5 + (i * 2),
                'health': 50 + (i * 10),
                'damage': 15 + (i * 3),
                'defense': 10 + (i * 2),
                'abilities': template['abilities'][:2 + (i % 3)],
                'theme': template['themes'][i % len(template['themes'])],
                'loot_table': self.generate_loot_table(world_theme, i),
                'ai_pattern': self.generate_ai_pattern(world_theme, i),
                'lore': self.generate_enemy_lore(world_theme, i)
            }
            enemies.append(enemy)
        
        return enemies
    
    def generate_loot_table(self, world_theme: str, enemy_index: int) -> Dict:
        """Generate sophisticated loot tables"""
        return {
            'common_items': [f"{world_theme}_material_{i}" for i in range(3)],
            'rare_items': [f"{world_theme}_essence_{enemy_index}"],
            'drop_rates': {
                'common': 0.8,
                'rare': 0.2,
                'epic': 0.05
            }
        }
    
    def generate_ai_pattern(self, world_theme: str, enemy_index: int) -> Dict:
        """Generate AI behavior patterns"""
        patterns = {
            'terra': ['defensive', 'regenerative', 'primal'],
            'nokturn': ['stealth', 'aggressive', 'fearful'],
            'elysion': ['tactical', 'protective', 'divine']
        }
        
        return {
            'primary_behavior': patterns.get(world_theme, ['aggressive'])[enemy_index % 3],
            'secondary_behavior': 'adaptive',
            'special_abilities': ['world_specific_power'],
            'difficulty_curve': 1.0 + (enemy_index * 0.1)
        }
    
    def generate_enemy_lore(self, world_theme: str, enemy_index: int) -> str:
        """Generate lore for enemies"""
        lore_templates = {
            'terra': f"A manifestation of {world_theme}'s primal forces, this entity represents the ancient power of nature itself.",
            'nokturn': f"Born from the shadows of {world_theme}, this creature embodies the darkness that lurks in the void.",
            'elysion': f"A divine being from {world_theme}, this entity carries the light and wisdom of the heavens."
        }
        
        return lore_templates.get(world_theme, "A mysterious entity from an unknown realm.")
    
    def create_combat_abilities(self, task: Dict) -> bool:
        """Create sophisticated combat abilities"""
        try:
            world_theme = task.get('world_theme', 'terra')
            ability_count = task.get('ability_count', 20)
            
            self.logger.info(f"Creating {ability_count} combat abilities for {world_theme}")
            
            abilities_file = os.path.join(self.project_path, 'data/combat/abilities.json')
            existing_abilities = []
            
            if os.path.exists(abilities_file):
                with open(abilities_file, 'r') as f:
                    existing_abilities = json.load(f)
            
            new_abilities = self.generate_combat_abilities(world_theme, ability_count)
            all_abilities = existing_abilities + new_abilities
            
            os.makedirs(os.path.dirname(abilities_file), exist_ok=True)
            
            with open(abilities_file, 'w') as f:
                json.dump(all_abilities, f, indent=2)
            
            self.logger.info(f"Created {len(new_abilities)} combat abilities for {world_theme}")
            return True
            
        except Exception as e:
            self.logger.error(f"Error creating combat abilities: {e}")
            return False
    
    def generate_combat_abilities(self, world_theme: str, count: int) -> List[Dict]:
        """Generate sophisticated combat abilities"""
        abilities = []
        
        ability_templates = {
            'terra': {
                'names': ['Nature\'s Wrath', 'Crystal Storm', 'Life Drain', 'Primal Strike', 'Forest\'s Embrace'],
                'types': ['damage', 'healing', 'buff', 'debuff', 'area'],
                'elements': ['nature', 'crystal', 'life', 'earth']
            },
            'nokturn': {
                'names': ['Shadow Strike', 'Void Blast', 'Fear Wave', 'Dark Embrace', 'Nightmare Touch'],
                'types': ['damage', 'debuff', 'control', 'stealth', 'area'],
                'elements': ['shadow', 'void', 'darkness', 'fear']
            },
            'elysion': {
                'names': ['Divine Light', 'Holy Smite', 'Celestial Blessing', 'Wisdom\'s Touch', 'Sacred Shield'],
                'types': ['damage', 'healing', 'buff', 'protection', 'area'],
                'elements': ['light', 'holy', 'divine', 'celestial']
            }
        }
        
        template = ability_templates.get(world_theme, ability_templates['terra'])
        
        for i in range(count):
            ability = {
                'id': f"{world_theme}_ability_{i+1}",
                'name': template['names'][i % len(template['names'])],
                'type': template['types'][i % len(template['types'])],
                'element': template['elements'][i % len(template['elements'])],
                'damage': 20 + (i * 5),
                'cooldown': 3 + (i % 5),
                'mana_cost': 15 + (i * 3),
                'effects': self.generate_ability_effects(world_theme, i),
                'description': self.generate_ability_description(world_theme, i)
            }
            abilities.append(ability)
        
        return abilities
    
    def generate_ability_effects(self, world_theme: str, ability_index: int) -> List[Dict]:
        """Generate sophisticated ability effects"""
        effects = []
        
        if world_theme == 'terra':
            effects = [
                {'type': 'damage', 'value': 25 + ability_index * 5},
                {'type': 'healing', 'value': 10 + ability_index * 2},
                {'type': 'buff', 'stat': 'defense', 'value': 5 + ability_index}
            ]
        elif world_theme == 'nokturn':
            effects = [
                {'type': 'damage', 'value': 30 + ability_index * 6},
                {'type': 'debuff', 'stat': 'defense', 'value': -3 - ability_index},
                {'type': 'fear', 'duration': 2 + ability_index}
            ]
        elif world_theme == 'elysion':
            effects = [
                {'type': 'damage', 'value': 20 + ability_index * 4},
                {'type': 'healing', 'value': 15 + ability_index * 3},
                {'type': 'buff', 'stat': 'all', 'value': 3 + ability_index}
            ]
        
        return effects[:2 + (ability_index % 3)]
    
    def generate_ability_description(self, world_theme: str, ability_index: int) -> str:
        """Generate descriptions for abilities"""
        descriptions = {
            'terra': f"Channels the primal forces of {world_theme} to unleash devastating natural power.",
            'nokturn': f"Harnesses the dark energy of {world_theme} to strike fear into enemies.",
            'elysion': f"Calls upon the divine light of {world_theme} to smite foes and heal allies."
        }
        
        return descriptions.get(world_theme, "A mysterious ability from an unknown source.")
    
    def analyze_existing_data(self, task: Dict) -> bool:
        """Analyze existing data files for optimization opportunities"""
        try:
            data_path = task.get('data_path', 'data')
            analysis_file = os.path.join(self.project_path, f'analysis_{self.agent_id}.json')
            
            self.logger.info(f"Analyzing data in {data_path}")
            
            analysis_results = {
                'files_analyzed': 0,
                'total_items': 0,
                'worlds_covered': 0,
                'optimization_opportunities': [],
                'missing_content': [],
                'recommendations': []
            }
            
            # Analyze JSON files
            for root, dirs, files in os.walk(os.path.join(self.project_path, data_path)):
                for file in files:
                    if file.endswith('.json'):
                        file_path = os.path.join(root, file)
                        analysis_results['files_analyzed'] += 1
                        
                        with open(file_path, 'r') as f:
                            data = json.load(f)
                        
                        # Analyze content
                        if isinstance(data, list):
                            analysis_results['total_items'] += len(data)
                            
                            # Check for missing content
                            if len(data) < 10:
                                analysis_results['missing_content'].append({
                                    'file': file,
                                    'current_count': len(data),
                                    'recommended_count': 20
                                })
                        
                        # Check for optimization opportunities
                        if len(str(data)) > 10000:
                            analysis_results['optimization_opportunities'].append({
                                'file': file,
                                'size': len(str(data)),
                                'recommendation': 'Consider splitting into smaller files'
                            })
            
            # Save analysis results
            with open(analysis_file, 'w') as f:
                json.dump(analysis_results, f, indent=2)
            
            self.logger.info(f"Analysis complete: {analysis_results['files_analyzed']} files, {analysis_results['total_items']} items")
            return True
            
        except Exception as e:
            self.logger.error(f"Error analyzing data: {e}")
            return False
    
    def check_stop_signal(self) -> bool:
        """Check if agent should stop working"""
        stop_file = os.path.join(self.project_path, f'enhanced_agent_{self.agent_id}_stop.txt')
        if os.path.exists(stop_file):
            self.logger.info(f"Stop signal received for enhanced agent {self.agent_id}")
            os.remove(stop_file)
            return True
        return False
    
    def stop_work(self):
        """Stop the agent's work"""
        self.is_running = False
        self.logger.info(f"Enhanced Agent {self.agent_id} stopping work")
    
    def get_status(self) -> Dict:
        """Get current status of the agent"""
        return {
            'agent_id': self.agent_id,
            'is_running': self.is_running,
            'current_task_index': self.current_task_index,
            'total_tasks': len(self.task_list),
            'completed_tasks': len(self.completed_tasks),
            'failed_tasks': len(self.failed_tasks),
            'progress_percentage': (self.current_task_index / len(self.task_list)) * 100 if self.task_list else 0
        }

def create_enhanced_task_lists() -> Dict[str, List[Dict]]:
    """Create enhanced task lists for complex data folder work"""
    
    # Enhanced Agent 1: Enemy Database Creation
    enemy_database_tasks = [
        {
            "type": "enemy_database_creation",
            "title": "Create Terra Enemies",
            "world_theme": "terra",
            "enemy_count": 15,
            "description": "Create comprehensive enemy database for Terra world"
        },
        {
            "type": "enemy_database_creation",
            "title": "Create Nokturn Enemies", 
            "world_theme": "nokturn",
            "enemy_count": 15,
            "description": "Create comprehensive enemy database for Nokturn world"
        },
        {
            "type": "enemy_database_creation",
            "title": "Create Elysion Enemies",
            "world_theme": "elysion", 
            "enemy_count": 15,
            "description": "Create comprehensive enemy database for Elysion world"
        },
        {
            "type": "data_analysis",
            "title": "Analyze Enemy Data",
            "data_path": "data/enemies",
            "description": "Analyze existing enemy data for optimization"
        }
    ]
    
    # Enhanced Agent 2: Combat Abilities Creation
    combat_abilities_tasks = [
        {
            "type": "combat_abilities_creation",
            "title": "Create Terra Combat Abilities",
            "world_theme": "terra",
            "ability_count": 20,
            "description": "Create sophisticated combat abilities for Terra"
        },
        {
            "type": "combat_abilities_creation", 
            "title": "Create Nokturn Combat Abilities",
            "world_theme": "nokturn",
            "ability_count": 20,
            "description": "Create sophisticated combat abilities for Nokturn"
        },
        {
            "type": "combat_abilities_creation",
            "title": "Create Elysion Combat Abilities", 
            "world_theme": "elysion",
            "ability_count": 20,
            "description": "Create sophisticated combat abilities for Elysion"
        },
        {
            "type": "data_analysis",
            "title": "Analyze Combat Data",
            "data_path": "data/combat",
            "description": "Analyze existing combat data for optimization"
        }
    ]
    
    # Enhanced Agent 3: Content Analysis and Optimization
    content_analysis_tasks = [
        {
            "type": "data_analysis",
            "title": "Analyze All Data Files",
            "data_path": "data",
            "description": "Comprehensive analysis of all data files"
        },
        {
            "type": "content_optimization",
            "title": "Optimize Item Data",
            "data_path": "data/items",
            "description": "Optimize and enhance item data"
        },
        {
            "type": "content_optimization",
            "title": "Optimize World Data",
            "data_path": "data/worlds", 
            "description": "Optimize and enhance world data"
        },
        {
            "type": "comprehensive_testing",
            "title": "Test Data Integrity",
            "test_target": "all_data_files",
            "description": "Comprehensive testing of all data files"
        }
    ]
    
    return {
        "enemy_database": enemy_database_tasks,
        "combat_abilities": combat_abilities_tasks,
        "content_analysis": content_analysis_tasks
    }

class EnhancedMultiAgentCoordinator:
    """Enhanced coordinator for complex multi-agent tasks"""
    
    def __init__(self, project_path: str):
        self.project_path = project_path
        self.agents: Dict[str, EnhancedTaskAgent] = {}
        self.agent_threads: Dict[str, threading.Thread] = {}
        self.logger = self.setup_logging()
        
    def setup_logging(self):
        """Setup logging for coordinator"""
        logging.basicConfig(
            level=logging.INFO,
            format='%(asctime)s - EnhancedCoordinator - %(levelname)s - %(message)s',
            handlers=[
                logging.FileHandler('enhanced_coordinator_log.txt'),
                logging.StreamHandler()
            ]
        )
        return logging.getLogger('EnhancedCoordinator')
    
    def create_agent(self, agent_id: str, task_list: List[Dict]) -> EnhancedTaskAgent:
        """Create a new enhanced agent"""
        agent = EnhancedTaskAgent(agent_id, task_list, self.project_path)
        self.agents[agent_id] = agent
        self.logger.info(f"Created enhanced agent {agent_id} with {len(task_list)} complex tasks")
        return agent
    
    def start_agent(self, agent_id: str):
        """Start an enhanced agent in a separate thread"""
        if agent_id not in self.agents:
            self.logger.error(f"Enhanced agent {agent_id} not found")
            return
        
        agent = self.agents[agent_id]
        thread = threading.Thread(target=agent.start_work, name=f"EnhancedAgent_{agent_id}")
        thread.daemon = True
        thread.start()
        
        self.agent_threads[agent_id] = thread
        self.logger.info(f"Started enhanced agent {agent_id} in thread")
    
    def start_all_agents(self):
        """Start all enhanced agents simultaneously"""
        self.logger.info(f"Starting all {len(self.agents)} enhanced agents")
        for agent_id in self.agents:
            self.start_agent(agent_id)
    
    def stop_all_agents(self):
        """Stop all enhanced agents"""
        self.logger.info("Stopping all enhanced agents")
        for agent_id in self.agents:
            self.agents[agent_id].stop_work()
    
    def get_all_status(self) -> Dict:
        """Get status of all enhanced agents"""
        status = {}
        for agent_id, agent in self.agents.items():
            status[agent_id] = agent.get_status()
        return status

def main():
    """Main function for enhanced multi-agent system"""
    project_path = "/Users/bursasaw/Documents/Morph Studios/ProjectOrion-0.12.12"
    
    # Create enhanced coordinator
    coordinator = EnhancedMultiAgentCoordinator(project_path)
    
    # Create enhanced task lists
    task_lists = create_enhanced_task_lists()
    
    # Create enhanced agents
    for agent_id, tasks in task_lists.items():
        coordinator.create_agent(agent_id, tasks)
    
    # Start all enhanced agents
    print("Starting Enhanced Multi-Agent System...")
    coordinator.start_all_agents()
    
    # Monitor progress
    try:
        while True:
            status = coordinator.get_all_status()
            print("\n" + "="*60)
            print("ENHANCED MULTI-AGENT STATUS REPORT")
            print("="*60)
            
            for agent_id, agent_status in status.items():
                print(f"\nEnhanced Agent {agent_id}:")
                print(f"  Status: {'Running' if agent_status['is_running'] else 'Stopped'}")
                print(f"  Progress: {agent_status['progress_percentage']:.1f}%")
                print(f"  Completed: {agent_status['completed_tasks']}")
                print(f"  Failed: {agent_status['failed_tasks']}")
            
            # Check if all agents are done
            all_done = all(not status[agent_id]['is_running'] for agent_id in status)
            if all_done:
                print("\nAll enhanced agents completed their work!")
                break
            
            time.sleep(30)  # Check status every 30 seconds
            
    except KeyboardInterrupt:
        print("\nStopping all enhanced agents...")
        coordinator.stop_all_agents()
    
    print("\nEnhanced multi-agent system finished!")

if __name__ == "__main__":
    main() 