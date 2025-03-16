"""
Team-related database operations for the Football Stats application.
"""

import sqlite3
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime

logger = logging.getLogger(__name__)

class TeamsManager:
    """Manager for team-related database operations."""
    
    def __init__(self, db_path: str):
        """Initialize the teams manager with the database path."""
        self.db_path = db_path
    
    def save_teams(self, teams: List[Dict[str, Any]]) -> int:
        """Save teams to the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            saved_count = 0
            
            for team in teams:
                try:
                    # Extract data
                    team_id = team['team']['id']
                    name = team['team']['name']
                    league_id = team.get('league', {}).get('id', 0)
                    
                    # Insert or update team
                    cursor.execute('''
                        INSERT OR REPLACE INTO teams (
                            id, name, league_id, created_at
                        ) VALUES (?, ?, ?, ?)
                    ''', (
                        team_id, name, league_id, datetime.now().isoformat()
                    ))
                    
                    saved_count += 1
                    
                except Exception as e:
                    logger.error(f"Error saving team {team.get('team', {}).get('id', 'unknown')}: {str(e)}")
                    continue
            
            conn.commit()
            conn.close()
            
            return saved_count
            
        except Exception as e:
            logger.error(f"Error saving teams: {str(e)}")
            return 0
    
    def save_players(self, players: List[Dict[str, Any]]) -> int:
        """Save players to the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            saved_count = 0
            
            for player in players:
                try:
                    # Extract data
                    player_id = player['player']['id']
                    name = player['player']['name']
                    team_id = player.get('statistics', [{}])[0].get('team', {}).get('id', 0)
                    
                    # Insert or update player
                    cursor.execute('''
                        INSERT OR REPLACE INTO players (
                            id, name, team_id, created_at
                        ) VALUES (?, ?, ?, ?)
                    ''', (
                        player_id, name, team_id, datetime.now().isoformat()
                    ))
                    
                    saved_count += 1
                    
                except Exception as e:
                    logger.error(f"Error saving player {player.get('player', {}).get('id', 'unknown')}: {str(e)}")
                    continue
            
            conn.commit()
            conn.close()
            
            return saved_count
            
        except Exception as e:
            logger.error(f"Error saving players: {str(e)}")
            return 0
    
    def save_standings(self, standings: List[Dict[str, Any]]) -> int:
        """Save standings to the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            saved_count = 0
            
            for team in standings:
                try:
                    # Extract data
                    league_id = team.get('league', {}).get('id', 0)
                    team_id = team['team']['id']
                    team_name = team['team']['name']
                    position = team['rank']
                    played = team['all']['played']
                    won = team['all']['win']
                    drawn = team['all']['draw']
                    lost = team['all']['lose']
                    goals_for = team['all']['goals']['for']
                    goals_against = team['all']['goals']['against']
                    goal_diff = team['goalsDiff']
                    points = team['points']
                    form = team.get('form', '')
                    
                    # Insert or update standing
                    cursor.execute('''
                        INSERT OR REPLACE INTO standings (
                            league_id, team_id, team_name, position, played,
                            won, drawn, lost, goals_for, goals_against,
                            goal_diff, points, form, created_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        league_id, team_id, team_name, position, played,
                        won, drawn, lost, goals_for, goals_against,
                        goal_diff, points, form, datetime.now().isoformat()
                    ))
                    
                    saved_count += 1
                    
                except Exception as e:
                    logger.error(f"Error saving standing for team {team.get('team', {}).get('id', 'unknown')}: {str(e)}")
                    continue
            
            conn.commit()
            conn.close()
            
            return saved_count
            
        except Exception as e:
            logger.error(f"Error saving standings: {str(e)}")
            return 0
    
    def get_teams(self) -> List[Dict[str, Any]]:
        """Get all teams from the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT t.*, l.name as league_name
                FROM teams t
                LEFT JOIN (
                    SELECT id, name FROM teams
                ) l ON t.league_id = l.id
                ORDER BY t.name
            ''')
            
            teams = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return teams
            
        except Exception as e:
            logger.error(f"Error getting teams: {str(e)}")
            return []
    
    def get_team_by_id(self, team_id: int) -> Optional[Dict[str, Any]]:
        """Get a team by its ID"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT t.*, l.name as league_name
                FROM teams t
                LEFT JOIN (
                    SELECT id, name FROM teams
                ) l ON t.league_id = l.id
                WHERE t.id = ?
            ''', (team_id,))
            
            team = cursor.fetchone()
            
            conn.close()
            
            return dict(team) if team else None
            
        except Exception as e:
            logger.error(f"Error getting team by ID: {str(e)}")
            return None
    
    def get_teams_by_league(self, league_id: int) -> List[Dict[str, Any]]:
        """Get teams for a specific league"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT t.*, l.name as league_name
                FROM teams t
                LEFT JOIN (
                    SELECT id, name FROM teams
                ) l ON t.league_id = l.id
                WHERE t.league_id = ?
                ORDER BY t.name
            ''', (league_id,))
            
            teams = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return teams
            
        except Exception as e:
            logger.error(f"Error getting teams by league: {str(e)}")
            return []
    
    def get_leagues(self) -> List[Dict[str, Any]]:
        """Get all leagues from the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT DISTINCT league_id as id, league_name as name, '' as country, '' as logo, '' as season
                FROM predictions
                ORDER BY league_name
            ''')
            
            leagues = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return leagues
            
        except Exception as e:
            logger.error(f"Error getting leagues: {str(e)}")
            return []
    
    def get_standings(self, league_id: int) -> List[Dict[str, Any]]:
        """Get standings for a specific league"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT *
                FROM standings
                WHERE league_id = ?
                ORDER BY position
            ''', (league_id,))
            
            standings = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return standings
            
        except Exception as e:
            logger.error(f"Error getting standings: {str(e)}")
            return []
