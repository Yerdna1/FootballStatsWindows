"""
Script to add demo data to the football_stats database.
This will create sample predictions, fixtures, teams, and leagues.
"""

import sqlite3
import random
from datetime import datetime, timedelta
import os
from modules.db_manager import DatabaseManager

def add_demo_data():
    """Add demo data to the database"""
    print("Adding demo data to the database...")
    
    # Create database manager
    db_manager = DatabaseManager("football_stats.db")
    
    # Sample leagues
    leagues = [
        {"id": 39, "name": "Premier League", "country": "England"},
        {"id": 140, "name": "La Liga", "country": "Spain"},
        {"id": 78, "name": "Bundesliga", "country": "Germany"},
        {"id": 135, "name": "Serie A", "country": "Italy"},
        {"id": 61, "name": "Ligue 1", "country": "France"},
        {"id": 88, "name": "Eredivisie", "country": "Netherlands"},
        {"id": 94, "name": "Primeira Liga", "country": "Portugal"},
        {"id": 332, "name": "Slovakian Super Liga", "country": "Slovakia"}
    ]
    
    # Sample teams
    teams = [
        # Premier League
        {"id": 33, "name": "Manchester United", "league_id": 39, "country": "England"},
        {"id": 40, "name": "Liverpool", "league_id": 39, "country": "England"},
        {"id": 50, "name": "Manchester City", "league_id": 39, "country": "England"},
        {"id": 47, "name": "Tottenham", "league_id": 39, "country": "England"},
        {"id": 42, "name": "Arsenal", "league_id": 39, "country": "England"},
        {"id": 49, "name": "Chelsea", "league_id": 39, "country": "England"},
        
        # La Liga
        {"id": 541, "name": "Real Madrid", "league_id": 140, "country": "Spain"},
        {"id": 529, "name": "Barcelona", "league_id": 140, "country": "Spain"},
        {"id": 530, "name": "Atletico Madrid", "league_id": 140, "country": "Spain"},
        {"id": 532, "name": "Valencia", "league_id": 140, "country": "Spain"},
        {"id": 536, "name": "Sevilla", "league_id": 140, "country": "Spain"},
        
        # Bundesliga
        {"id": 157, "name": "Bayern Munich", "league_id": 78, "country": "Germany"},
        {"id": 165, "name": "Borussia Dortmund", "league_id": 78, "country": "Germany"},
        {"id": 159, "name": "Hertha Berlin", "league_id": 78, "country": "Germany"},
        {"id": 169, "name": "Eintracht Frankfurt", "league_id": 78, "country": "Germany"},
        {"id": 168, "name": "Bayer Leverkusen", "league_id": 78, "country": "Germany"},
        
        # Serie A
        {"id": 489, "name": "AC Milan", "league_id": 135, "country": "Italy"},
        {"id": 505, "name": "Inter", "league_id": 135, "country": "Italy"},
        {"id": 496, "name": "Juventus", "league_id": 135, "country": "Italy"},
        {"id": 497, "name": "AS Roma", "league_id": 135, "country": "Italy"},
        {"id": 492, "name": "Napoli", "league_id": 135, "country": "Italy"},
        
        # Ligue 1
        {"id": 85, "name": "Paris Saint Germain", "league_id": 61, "country": "France"},
        {"id": 91, "name": "Monaco", "league_id": 61, "country": "France"},
        {"id": 80, "name": "Marseille", "league_id": 61, "country": "France"},
        {"id": 93, "name": "Nice", "league_id": 61, "country": "France"},
        {"id": 79, "name": "Lille", "league_id": 61, "country": "France"},
        
        # Eredivisie
        {"id": 194, "name": "Ajax", "league_id": 88, "country": "Netherlands"},
        {"id": 197, "name": "PSV Eindhoven", "league_id": 88, "country": "Netherlands"},
        {"id": 193, "name": "Feyenoord", "league_id": 88, "country": "Netherlands"},
        
        # Primeira Liga
        {"id": 211, "name": "Benfica", "league_id": 94, "country": "Portugal"},
        {"id": 212, "name": "FC Porto", "league_id": 94, "country": "Portugal"},
        {"id": 228, "name": "Sporting CP", "league_id": 94, "country": "Portugal"},
        
        # Slovakian Super Liga
        {"id": 651, "name": "Slovan Bratislava", "league_id": 332, "country": "Slovakia"},
        {"id": 652, "name": "Spartak Trnava", "league_id": 332, "country": "Slovakia"},
        {"id": 653, "name": "MŠK Žilina", "league_id": 332, "country": "Slovakia"},
        {"id": 654, "name": "DAC Dunajská Streda", "league_id": 332, "country": "Slovakia"}
    ]
    
    # Save leagues to database
    conn = sqlite3.connect("football_stats.db")
    cursor = conn.cursor()
    
    # Create leagues table if it doesn't exist
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS leagues (
            id INTEGER PRIMARY KEY,
            name TEXT NOT NULL,
            country TEXT NOT NULL,
            logo TEXT,
            season TEXT,
            created_at TEXT NOT NULL
        )
    ''')
    
    # Insert leagues
    for league in leagues:
        cursor.execute('''
            INSERT OR REPLACE INTO leagues (
                id, name, country, logo, season, created_at
            ) VALUES (?, ?, ?, ?, ?, ?)
        ''', (
            league["id"],
            league["name"],
            league["country"],
            "",
            "2024",
            datetime.now().isoformat()
        ))
    
    # Insert teams
    for team in teams:
        cursor.execute('''
            INSERT OR REPLACE INTO teams (
                id, name, league_id, country, founded, stadium, capacity, created_at
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            team["id"],
            team["name"],
            team["league_id"],
            team["country"],
            None,
            None,
            None,
            datetime.now().isoformat()
        ))
    
    conn.commit()
    
    # Generate fixtures
    fixtures = []
    fixture_id = 1000
    
    # Generate past fixtures (completed)
    for i in range(50):
        # Select random teams from the same league
        league = random.choice(leagues)
        league_teams = [t for t in teams if t["league_id"] == league["id"]]
        
        if len(league_teams) < 2:
            continue
            
        home_team = random.choice(league_teams)
        away_team = random.choice([t for t in league_teams if t["id"] != home_team["id"]])
        
        # Generate random date in the past
        match_date = (datetime.now() - timedelta(days=random.randint(1, 30))).strftime("%Y-%m-%d")
        
        # Generate random score
        home_score = random.randint(0, 4)
        away_score = random.randint(0, 4)
        
        fixtures.append({
            "fixture": {
                "id": fixture_id,
                "date": f"{match_date}T20:00:00+00:00",
                "venue": {"name": f"{home_team['name']} Stadium"},
                "status": {"long": "Match Finished"}
            },
            "league": {
                "id": league["id"],
                "name": league["name"],
                "country": league["country"]
            },
            "teams": {
                "home": {"id": home_team["id"], "name": home_team["name"]},
                "away": {"id": away_team["id"], "name": away_team["name"]}
            },
            "goals": {
                "home": home_score,
                "away": away_score
            }
        })
        
        fixture_id += 1
    
    # Generate upcoming fixtures
    for i in range(50):
        # Select random teams from the same league
        league = random.choice(leagues)
        league_teams = [t for t in teams if t["league_id"] == league["id"]]
        
        if len(league_teams) < 2:
            continue
            
        home_team = random.choice(league_teams)
        away_team = random.choice([t for t in league_teams if t["id"] != home_team["id"]])
        
        # Generate random date in the future
        match_date = (datetime.now() + timedelta(days=random.randint(1, 14))).strftime("%Y-%m-%d")
        
        fixtures.append({
            "fixture": {
                "id": fixture_id,
                "date": f"{match_date}T20:00:00+00:00",
                "venue": {"name": f"{home_team['name']} Stadium"},
                "status": {"long": "Not Started"}
            },
            "league": {
                "id": league["id"],
                "name": league["name"],
                "country": league["country"]
            },
            "teams": {
                "home": {"id": home_team["id"], "name": home_team["name"]},
                "away": {"id": away_team["id"], "name": away_team["name"]}
            },
            "goals": {
                "home": None,
                "away": None
            }
        })
        
        fixture_id += 1
    
    # Save fixtures to database
    db_manager.save_fixtures(fixtures)
    
    # Generate predictions
    for fixture in fixtures:
        # Only create predictions for some fixtures
        if random.random() < 0.7:
            # Randomly choose home or away team for prediction
            is_home = random.choice([True, False])
            
            if is_home:
                team_id = fixture["teams"]["home"]["id"]
                team_name = fixture["teams"]["home"]["name"]
                opponent_id = fixture["teams"]["away"]["id"]
                opponent_name = fixture["teams"]["away"]["name"]
            else:
                team_id = fixture["teams"]["away"]["id"]
                team_name = fixture["teams"]["away"]["name"]
                opponent_id = fixture["teams"]["home"]["id"]
                opponent_name = fixture["teams"]["home"]["name"]
                
            # Generate random performance difference
            performance_diff = round(random.uniform(0.1, 2.0), 2)
            
            # Determine prediction level and prediction
            prediction_level = 1 if performance_diff < 1.05 else 2
            
            if performance_diff > 0.75:
                prediction = "LOSS" if is_home else "WIN"
                if performance_diff > 1.05:
                    prediction = "BIG " + prediction
            else:
                prediction = "WIN" if is_home else "LOSS"
                if performance_diff > 1.05:
                    prediction = "BIG " + prediction
                    
            # Create prediction data
            prediction_data = {
                "team_id": team_id,
                "team_name": team_name,
                "league_id": fixture["league"]["id"],
                "league_name": fixture["league"]["name"],
                "fixture_id": fixture["fixture"]["id"],
                "opponent_id": opponent_id,
                "opponent_name": opponent_name,
                "match_date": fixture["fixture"]["date"].split("T")[0],
                "venue": fixture["fixture"]["venue"]["name"],
                "performance_diff": performance_diff,
                "prediction": prediction,
                "prediction_level": prediction_level
            }
            
            # Save prediction
            prediction_id = db_manager.save_prediction(prediction_data)
            
            # If fixture is completed, update prediction result
            if fixture["fixture"]["status"]["long"] == "Match Finished":
                # Determine if prediction was correct
                home_score = fixture["goals"]["home"]
                away_score = fixture["goals"]["away"]
                
                if is_home:
                    actual_result = "WIN" if home_score > away_score else "LOSS" if home_score < away_score else "DRAW"
                else:
                    actual_result = "WIN" if away_score > home_score else "LOSS" if away_score < home_score else "DRAW"
                
                # Simplify prediction for comparison (remove "BIG ")
                simple_prediction = prediction.replace("BIG ", "")
                
                # Check if prediction was correct
                correct = 1 if simple_prediction == actual_result else 0
                
                # Update prediction result
                result = f"{home_score}-{away_score}"
                db_manager.update_prediction_result(prediction_id, result, correct)
    
    print("Demo data added successfully!")
    print(f"Added {len(leagues)} leagues, {len(teams)} teams, {len(fixtures)} fixtures, and approximately {int(len(fixtures) * 0.7)} predictions.")

if __name__ == "__main__":
    add_demo_data()
