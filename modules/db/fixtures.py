"""
Fixture-related database operations for the Football Stats application.
"""

import sqlite3
import logging
from typing import Dict, List, Any, Optional
from datetime import datetime

logger = logging.getLogger(__name__)

class FixturesManager:
    """Manager for fixture-related database operations."""
    
    def __init__(self, db_path: str):
        """Initialize the fixtures manager with the database path."""
        self.db_path = db_path
    
    def save_fixtures(self, fixtures: List[Dict[str, Any]]) -> int:
        """Save fixtures to the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            saved_count = 0
            
            for fixture in fixtures:
                try:
                    # Extract data
                    fixture_id = fixture['fixture']['id']
                    league_id = fixture['league']['id']
                    home_team_id = fixture['teams']['home']['id']
                    home_team_name = fixture['teams']['home']['name']
                    away_team_id = fixture['teams']['away']['id']
                    away_team_name = fixture['teams']['away']['name']
                    match_date = fixture['fixture']['date'].split('T')[0]
                    match_time = fixture['fixture']['date'].split('T')[1].split('+')[0][:-3]
                    venue = fixture['fixture']['venue']['name'] if fixture['fixture']['venue']['name'] else ""
                    status = fixture['fixture']['status']['long']
                    
                    # Get scores if available
                    home_score = fixture['goals']['home'] if fixture['goals']['home'] is not None else None
                    away_score = fixture['goals']['away'] if fixture['goals']['away'] is not None else None
                    
                    # Insert or update fixture
                    cursor.execute('''
                        INSERT OR REPLACE INTO fixtures (
                            id, league_id, home_team_id, home_team_name,
                            away_team_id, away_team_name, match_date, match_time,
                            venue, status, home_score, away_score, created_at
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        fixture_id, league_id, home_team_id, home_team_name,
                        away_team_id, away_team_name, match_date, match_time,
                        venue, status, home_score, away_score, datetime.now().isoformat()
                    ))
                    
                    saved_count += 1
                    
                except Exception as e:
                    logger.error(f"Error saving fixture {fixture.get('fixture', {}).get('id', 'unknown')}: {str(e)}")
                    continue
            
            conn.commit()
            conn.close()
            
            return saved_count
            
        except Exception as e:
            logger.error(f"Error saving fixtures: {str(e)}")
            return 0
    
    def get_fixtures(self) -> List[Dict[str, Any]]:
        """Get all fixtures from the database"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT f.*, l.name as league_name
                FROM fixtures f
                LEFT JOIN (
                    SELECT id, name FROM teams
                ) l ON f.league_id = l.id
                ORDER BY match_date DESC
            ''')
            
            fixtures = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return fixtures
            
        except Exception as e:
            logger.error(f"Error getting fixtures: {str(e)}")
            return []
    
    def get_upcoming_fixtures(self, team_id: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get upcoming fixtures from the database, optionally filtered by team"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            if team_id:
                cursor.execute('''
                    SELECT f.*, l.name as league_name
                    FROM fixtures f
                    LEFT JOIN (
                        SELECT id, name FROM teams
                    ) l ON f.league_id = l.id
                    WHERE (f.home_team_id = ? OR f.away_team_id = ?)
                    AND f.status = 'Not Started'
                    ORDER BY match_date ASC
                ''', (team_id, team_id))
            else:
                cursor.execute('''
                    SELECT f.*, l.name as league_name
                    FROM fixtures f
                    LEFT JOIN (
                        SELECT id, name FROM teams
                    ) l ON f.league_id = l.id
                    WHERE f.status = 'Not Started'
                    ORDER BY match_date ASC
                ''')
            
            fixtures = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return fixtures
            
        except Exception as e:
            logger.error(f"Error getting upcoming fixtures: {str(e)}")
            return []
    
    def get_completed_fixtures(self, team_id: Optional[int] = None) -> List[Dict[str, Any]]:
        """Get completed fixtures from the database, optionally filtered by team"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            if team_id:
                cursor.execute('''
                    SELECT f.*, l.name as league_name
                    FROM fixtures f
                    LEFT JOIN (
                        SELECT id, name FROM teams
                    ) l ON f.league_id = l.id
                    WHERE (f.home_team_id = ? OR f.away_team_id = ?)
                    AND f.status = 'Match Finished'
                    ORDER BY match_date DESC
                ''', (team_id, team_id))
            else:
                cursor.execute('''
                    SELECT f.*, l.name as league_name
                    FROM fixtures f
                    LEFT JOIN (
                        SELECT id, name FROM teams
                    ) l ON f.league_id = l.id
                    WHERE f.status = 'Match Finished'
                    ORDER BY match_date DESC
                ''')
            
            fixtures = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return fixtures
            
        except Exception as e:
            logger.error(f"Error getting completed fixtures: {str(e)}")
            return []
    
    def get_fixture_by_id(self, fixture_id: int) -> Optional[Dict[str, Any]]:
        """Get a fixture by its ID"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT f.*, l.name as league_name
                FROM fixtures f
                LEFT JOIN (
                    SELECT id, name FROM teams
                ) l ON f.league_id = l.id
                WHERE f.id = ?
            ''', (fixture_id,))
            
            fixture = cursor.fetchone()
            
            conn.close()
            
            return dict(fixture) if fixture else None
            
        except Exception as e:
            logger.error(f"Error getting fixture by ID: {str(e)}")
            return None
    
    def get_fixtures_by_league(self, league_id: int) -> List[Dict[str, Any]]:
        """Get fixtures for a specific league"""
        try:
            conn = sqlite3.connect(self.db_path)
            conn.row_factory = sqlite3.Row
            cursor = conn.cursor()
            
            cursor.execute('''
                SELECT f.*, l.name as league_name
                FROM fixtures f
                LEFT JOIN (
                    SELECT id, name FROM teams
                ) l ON f.league_id = l.id
                WHERE f.league_id = ?
                ORDER BY match_date DESC
            ''', (league_id,))
            
            fixtures = [dict(row) for row in cursor.fetchall()]
            
            conn.close()
            
            return fixtures
            
        except Exception as e:
            logger.error(f"Error getting fixtures by league: {str(e)}")
            return []
            
    def update_fixture_scores(self, fixture_id: int, home_score: int, away_score: int, status: str = 'COMPLETED') -> bool:
        """Update fixture scores and status"""
        try:
            conn = sqlite3.connect(self.db_path)
            cursor = conn.cursor()
            
            cursor.execute('''
                UPDATE fixtures
                SET home_score = ?, away_score = ?, status = ?
                WHERE id = ?
            ''', (home_score, away_score, status, fixture_id))
            
            conn.commit()
            conn.close()
            
            return True
            
        except Exception as e:
            logger.error(f"Error updating fixture scores: {str(e)}")
            return False
