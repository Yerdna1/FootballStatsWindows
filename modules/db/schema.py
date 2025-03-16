"""
Database schema initialization for the Football Stats application.
"""

import sqlite3
import logging

logger = logging.getLogger(__name__)

def initialize_database(db_path: str) -> bool:
    """Initialize the database with required tables"""
    try:
        conn = sqlite3.connect(db_path)
        cursor = conn.cursor()
        
        # Create predictions table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS predictions (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                team_id INTEGER NOT NULL,
                team_name TEXT NOT NULL,
                league_id INTEGER NOT NULL,
                league_name TEXT NOT NULL,
                fixture_id INTEGER NOT NULL,
                opponent_id INTEGER NOT NULL,
                opponent_name TEXT NOT NULL,
                match_date TEXT NOT NULL,
                venue TEXT,
                performance_diff REAL NOT NULL,
                prediction TEXT NOT NULL,
                prediction_level INTEGER NOT NULL,
                result TEXT,
                correct INTEGER,
                created_at TEXT NOT NULL,
                UNIQUE(fixture_id, team_id)
            )
        ''')
        
        # Create settings table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS settings (
                key TEXT PRIMARY KEY,
                value TEXT NOT NULL
            )
        ''')
        
        # Create fixtures table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS fixtures (
                id INTEGER PRIMARY KEY,
                league_id INTEGER NOT NULL,
                home_team_id INTEGER NOT NULL,
                home_team_name TEXT NOT NULL,
                away_team_id INTEGER NOT NULL,
                away_team_name TEXT NOT NULL,
                match_date TEXT NOT NULL,
                match_time TEXT,
                venue TEXT,
                status TEXT,
                home_score INTEGER,
                away_score INTEGER,
                created_at TEXT NOT NULL,
                UNIQUE(id)
            )
        ''')
        
        # Create teams table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS teams (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                league_id INTEGER NOT NULL,
                country TEXT,
                founded INTEGER,
                stadium TEXT,
                capacity INTEGER,
                created_at TEXT NOT NULL,
                UNIQUE(id)
            )
        ''')
        
        # Create players table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS players (
                id INTEGER PRIMARY KEY,
                name TEXT NOT NULL,
                team_id INTEGER NOT NULL,
                position TEXT,
                age INTEGER,
                nationality TEXT,
                created_at TEXT NOT NULL,
                UNIQUE(id)
            )
        ''')
        
        # Create standings table
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS standings (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                league_id INTEGER NOT NULL,
                team_id INTEGER NOT NULL,
                team_name TEXT NOT NULL,
                position INTEGER NOT NULL,
                played INTEGER NOT NULL,
                won INTEGER NOT NULL,
                drawn INTEGER NOT NULL,
                lost INTEGER NOT NULL,
                goals_for INTEGER NOT NULL,
                goals_against INTEGER NOT NULL,
                goal_diff INTEGER NOT NULL,
                points INTEGER NOT NULL,
                form TEXT,
                created_at TEXT NOT NULL,
                UNIQUE(league_id, team_id)
            )
        ''')
        
        conn.commit()
        conn.close()
        
        logger.info("Database initialized successfully")
        return True
        
    except Exception as e:
        logger.error(f"Error initializing database: {str(e)}")
        return False
