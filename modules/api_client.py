from datetime import datetime, timedelta
import time
import requests
import logging
import json
from typing import Dict, Any, Optional, List

from modules.config import ALL_LEAGUES, PERF_DIFF_THRESHOLD
from modules.league_names import LEAGUE_NAMES
from modules.form_analyzer import FormAnalyzer

logger = logging.getLogger(__name__)

class FootballAPI:
    def __init__(self, api_key, base_url, disable_auto_fetch=False):
        self.api_key = api_key
        self.base_url = base_url
        self.headers = {'x-apisports-key': api_key}
        self.logger = logging.getLogger(__name__)
        self.disable_auto_fetch = disable_auto_fetch
        self._initialize_cache()
        
    def _initialize_cache(self):
        """Initialize different cache stores with different durations"""
        self.cache = {
            'short': {'data': {}, 'duration': timedelta(minutes=15)},  # 15 minutes for volatile data
            'medium': {'data': {}, 'duration': timedelta(hours=6)},    # 6 hours for semi-stable data
            'long': {'data': {}, 'duration': timedelta(hours=24)},     # 24 hours for stable data
        }
        
    def _get_from_cache(self, key: str, cache_type: str = 'short') -> Optional[Any]:
        """Get data from cache with specified duration type"""
        cache_store = self.cache[cache_type]['data']
        if key in cache_store:
            data, timestamp = cache_store[key]
            if datetime.now() - timestamp < self.cache[cache_type]['duration']:
                return data
            del cache_store[key]
        return None

    def _set_cache(self, key: str, data: Any, cache_type: str = 'short'):
        """Set data in cache with specified duration type"""
        self.cache[cache_type]['data'][key] = (data, datetime.now())

    def _batch_request(self, url: str, params_list: list) -> Dict:
        """Make batch requests and handle rate limiting and interruptions"""
        results = {}
        for params in params_list:
            cache_key = f"{url}_{json.dumps(params, sort_keys=True)}"
            cached_data = self._get_from_cache(cache_key)
            
            if cached_data:
                results[json.dumps(params)] = cached_data
                continue

            try:
                # Set a timeout for the request to prevent hanging
                response = requests.get(url, headers=self.headers, params=params, timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    self._set_cache(cache_key, data)
                    results[json.dumps(params)] = data
                elif response.status_code == 429:  # Rate limit
                    logger.warning(f"Rate limit hit for {url} with params {params}")
                    time.sleep(2)  # Reduced wait time to avoid long pauses
                    try:
                        response = requests.get(url, headers=self.headers, params=params, timeout=10)
                        if response.status_code == 200:
                            data = response.json()
                            self._set_cache(cache_key, data)
                            results[json.dumps(params)] = data
                    except Exception as retry_e:
                        logger.error(f"Error in retry request: {str(retry_e)}")
                else:
                    logger.warning(f"Request failed with status {response.status_code} for {url} with params {params}")
                
                time.sleep(0.2)  # Small delay between requests
            except requests.exceptions.Timeout:
                logger.warning(f"Request timeout for {url} with params {params}")
                continue
            except requests.exceptions.ConnectionError:
                logger.warning(f"Connection error for {url} with params {params}")
                continue
            except KeyboardInterrupt:
                logger.warning("Request interrupted by user")
                # Return whatever results we have so far
                return results
            except Exception as e:
                logger.error(f"Error in batch request: {str(e)}")
                continue
                
        return results
    
    def fetch_all_teams(self, league_names, matches_count=5):
        """
        Fetch all teams across all leagues with form analysis
        
        Args:
            league_names: Dictionary of league IDs and names
            matches_count: Number of recent matches to analyze for form
            
        Returns:
            list: List of teams with their form analysis
        """
        logger.debug(f"Fetching all teams for {len(league_names)} leagues")
        all_teams = []

        try:
            # Process each league individually
            for league_id, league_info in league_names.items():
                # Skip ALL_LEAGUES value if somehow passed directly
                if league_id == ALL_LEAGUES:
                    logger.warning("ALL_LEAGUES value passed directly, skipping")
                    continue
                    
                # Make sure we're working with a valid integer ID
                if not isinstance(league_id, int):
                    logger.warning(f"Invalid league ID type: {type(league_id)}")
                    continue
                    
                logger.info(f"Processing league: {league_id} ({league_info.get('name', 'Unknown')})")
                
                # Fetch standings for this specific league
                standings = self.fetch_standings(league_id)
                
                if not standings:
                    logger.warning(f"No standings available for league {league_id}")
                    continue
                    
                # Check if we got a response
                if not standings.get('response') or len(standings['response']) == 0:
                    logger.warning(f"No response data for league {league_id}")
                    continue
                    
                # Get league data
                league_data = standings['response'][0].get('league', {})
                if not league_data:
                    logger.warning(f"No league data for league {league_id}")
                    continue
                    
                # Get standings data
                all_standings = league_data.get('standings', [])
                if not all_standings:
                    logger.warning(f"No standings data for league {league_id}")
                    continue
                    
                # Use the first standings group (usually the main one)
                standings_data = all_standings[0] if all_standings else []
                
                if not standings_data:
                    logger.warning(f"Empty standings data for league {league_id}")
                    continue
                
                # Get fixtures with caching
                fixtures = self.fetch_fixtures(league_id)
                logger.info(f"Fetched {len(fixtures)} fixtures for league {league_id}")

                # Process each team
                league_teams = []
                for team in standings_data:
                    try:
                        team_data = team.get('team', {})
                        team_id = team_data.get('id')
                        if not team_id:
                            continue

                        team_name = team_data.get('name', 'Unknown')
                        matches_played = team.get('all', {}).get('played', 0)
                        
                        if matches_played == 0:
                            continue

                        actual_points = team.get('points', 0)
                        current_ppg = actual_points / matches_played if matches_played > 0 else 0

                        # Analyze team form
                        form_data = FormAnalyzer.analyze_team_form(fixtures, team_id, matches_count)
                        
                        form_points = form_data['points']
                        form_matches = form_data['matches_analyzed']
                        form_ppg = form_points / matches_count if form_matches > 0 else 0
                        form_vs_actual_diff = form_ppg - current_ppg
                        
                        # Include team info
                        performance_diff = round(form_vs_actual_diff, 2)
                        if abs(performance_diff) > PERF_DIFF_THRESHOLD:  # Filter teams here
                            team_info = {
                                'team_id': team_id,
                                'team': team_name,
                                'league': f"{league_info.get('flag', '')} {league_info.get('name', '')}",
                                'league_id': league_id,  # Add league_id explicitly
                                'current_position': team.get('rank', 0),
                                'matches_played': matches_played,
                                'current_points': actual_points,
                                'current_ppg': round(current_ppg, 2),
                                'form': ' '.join(form_data['form']),
                                'form_points': form_points,
                                'form_ppg': round(form_ppg, 2),
                                'performance_diff': round(form_vs_actual_diff, 2),
                                'goals_for': form_data['goals_for'],
                                'goals_against': form_data['goals_against']
                            }
                            
                            league_teams.append(team_info)

                    except Exception as e:
                        logger.error(f"Error processing team {team_data.get('name', 'Unknown')}: {str(e)}")
                        continue
                        
                logger.info(f"Found {len(league_teams)} teams with significant performance difference in league {league_id}")
                all_teams.extend(league_teams)

        except Exception as e:
            logger.error(f"Error in fetch_all_teams: {str(e)}")
            return []

        # Sort by absolute performance difference
        return sorted(all_teams, key=lambda x: abs(x.get('performance_diff', 0)), reverse=True)

    def fetch_standings(self, league_id):
        """Optimized standings fetch with better caching"""
        # Special handling for ALL_LEAGUES
        if league_id == ALL_LEAGUES:
            logger.warning("ALL_LEAGUES value received in fetch_standings, this should not be passed directly")
            logger.info("Use individual league IDs instead of ALL_LEAGUES constant")
            # Return empty result for ALL_LEAGUES
            return {}
            
        # Normal case - handle a specific league ID
        cache_key = f'standings_{league_id}'
        cached_data = self._get_from_cache(cache_key, 'medium')  # Standings change less frequently
        if cached_data:
            return cached_data
            
        # If auto-fetch is disabled and no cache, return empty result
        if self.disable_auto_fetch:
            return None

        url = f"{self.base_url}/standings"
        params = {"league": league_id, "season": 2024}
        results = self._batch_request(url, [params])
        data = results.get(json.dumps(params))
        if data:
            self._set_cache(cache_key, data, 'medium')
            return data
        return None

    def fetch_fixtures(self, league_id, season='2024', team_id=None, fixture_id=None):
        """Optimized fixtures fetch with smarter caching"""
        cache_key = f'fixtures_{league_id}_{team_id}_{fixture_id}'
        
        # Use longer cache duration for historical fixtures
        cache_type = 'long' if not fixture_id else 'short'
        cached_data = self._get_from_cache(cache_key, cache_type)
        if cached_data:
            return cached_data
            
        # If auto-fetch is disabled and no cache, return empty result
        if self.disable_auto_fetch:
            return []

        url = f"{self.base_url}/fixtures"
        
        if fixture_id:
            params = {'id': fixture_id}
            results = self._batch_request(url, [params])
            data = results.get(json.dumps(params), {}).get('response', [])
            self._set_cache(cache_key, data, cache_type)
            return data

        if league_id == ALL_LEAGUES:
            # Get all league IDs except ALL_LEAGUES
            league_ids = [lid for lid in LEAGUE_NAMES.keys() 
                         if isinstance(lid, int) and lid != ALL_LEAGUES]
            
            # Log the leagues being requested
            logger.info(f"Fetching fixtures for {len(league_ids)} leagues")
            
            params_list = [
                {'league': lid, 'season': season, **({"team": team_id} if team_id else {})}
                for lid in league_ids
            ]
            results = self._batch_request(url, params_list)
            
            all_fixtures = []
            for params_str, result in results.items():
                if result and result.get('response'):
                    fixtures = result['response']
                    all_fixtures.extend(fixtures)
                    params = json.loads(params_str)
                    logger.info(f"Received {len(fixtures)} fixtures for league {params['league']}")
                    
            self._set_cache(cache_key, all_fixtures, cache_type)
            return all_fixtures
        
        params = {
            'league': league_id,
            'season': season,
            **({"team": team_id} if team_id else {})
        }
        results = self._batch_request(url, [params])
        data = results.get(json.dumps(params), {}).get('response', [])
        self._set_cache(cache_key, data, cache_type)
        return data

    def fetch_teams(self, league_id, season='2024'):
        """Fetch teams for a specific league with caching"""
        cache_key = f'teams_{league_id}_{season}'
        cached_data = self._get_from_cache(cache_key, 'medium')  # Teams don't change often
        if cached_data:
            return cached_data
            
        # If auto-fetch is disabled and no cache, return empty result
        if self.disable_auto_fetch:
            return []

        url = f"{self.base_url}/teams"
        
        if league_id == ALL_LEAGUES:
            # Get all league IDs except ALL_LEAGUES
            league_ids = [lid for lid in LEAGUE_NAMES.keys() 
                         if isinstance(lid, int) and lid != ALL_LEAGUES]
            
            # Log the leagues being requested
            logger.info(f"Fetching teams for {len(league_ids)} leagues")
            
            params_list = [
                {'league': lid, 'season': season}
                for lid in league_ids
            ]
            results = self._batch_request(url, params_list)
            
            all_teams = []
            for params_str, result in results.items():
                if result and result.get('response'):
                    teams = result['response']
                    all_teams.extend(teams)
                    params = json.loads(params_str)
                    logger.info(f"Received {len(teams)} teams for league {params['league']}")
                    
            self._set_cache(cache_key, all_teams, 'medium')
            return all_teams
        
        params = {
            'league': league_id,
            'season': season
        }
        results = self._batch_request(url, [params])
        data = results.get(json.dumps(params), {}).get('response', [])
        self._set_cache(cache_key, data, 'medium')
        return data

    def fetch_players(self, league_id, season='2024', team_id=None, page=1):
        """Fetch players for a specific league or team with caching"""
        cache_key = f'players_{league_id}_{team_id}_{season}_{page}'
        cached_data = self._get_from_cache(cache_key, 'medium')  # Players don't change often
        if cached_data:
            return cached_data
            
        # If auto-fetch is disabled and no cache, return empty result
        if self.disable_auto_fetch:
            return []

        url = f"{self.base_url}/players"
        
        params = {
            'league': league_id,
            'season': season,
            'page': page
        }
        
        if team_id:
            params['team'] = team_id
            
        results = self._batch_request(url, [params])
        data = results.get(json.dumps(params), {}).get('response', [])
        self._set_cache(cache_key, data, 'medium')
        return data

    def fetch_team_statistics(self, league_id, team_id, season='2024'):
        """Optimized team statistics fetch with null safety"""
        cache_key = f'team_stats_{league_id}_{team_id}'
        cached_data = self._get_from_cache(cache_key, 'medium')
        if cached_data:
            return cached_data
            
        # If auto-fetch is disabled and no cache, return empty result
        if self.disable_auto_fetch:
            return {}
            
        url = f"{self.base_url}/teams/statistics"
        params = {
            'league': league_id,
            'team': team_id,
            'season': season
        }
        
        try:
            results = self._batch_request(url, [params])
            data = results.get(json.dumps(params), {}).get('response', {})
            
            # Ensure we have valid data structure
            if not data:
                self.logger.warning(f"No team statistics found for team {team_id} in league {league_id}")
                return {}
                
            # Ensure all required fields have default values
            stats = {
                'form': data.get('form', ''),
                'fixtures': data.get('fixtures', {}),
                'goals': data.get('goals', {}),
                'biggest': data.get('biggest', {}),
                'clean_sheet': data.get('clean_sheet', {}),
                'failed_to_score': data.get('failed_to_score', {}),
                'penalty': data.get('penalty', {}),
                'lineups': data.get('lineups', []),
                'cards': data.get('cards', {})
            }
            
            self._set_cache(cache_key, stats, 'medium')
            return stats
            
        except Exception as e:
            self.logger.error(f"Error fetching team statistics for {team_id}: {str(e)}")
            return {}

    def fetch_next_fixtures(self, league_id, season='2024'):
        """Fetch next round of fixtures for a league with short-term caching"""
        cache_key = f'next_fixtures_{league_id}_{season}'
        cached_data = self._get_from_cache(cache_key, 'short')  # Short cache for upcoming fixtures
        if cached_data:
            return cached_data
            
        # If auto-fetch is disabled and no cache, return empty result
        if self.disable_auto_fetch:
            return []
            
        url = f"{self.base_url}/fixtures"
        params = {
            'league': league_id,
            'season': season,
            'next': 10  # Fetch next 10 matches to ensure we get the full round
        }
        
        try:
            results = self._batch_request(url, [params])
            data = results.get(json.dumps(params), {}).get('response', [])
            
            if data:
                # Group by round and get the next round
                rounds = {}
                for fix in data:
                    round_num = fix['league']['round']
                    if round_num not in rounds:
                        rounds[round_num] = []
                    rounds[round_num].append(fix)
                
                # Get the earliest round
                next_round = next(iter(rounds.values())) if rounds else []
                self._set_cache(cache_key, next_round, 'short')  # Short cache duration for upcoming fixtures
                return next_round
                
        except Exception as e:
            self.logger.error(f"Error fetching next fixtures: {str(e)}")
            
        return []
        
    def fetch_squad(self, team_id, season='2024'):
        """Fetch squad data for a team with caching"""
        cache_key = f'squad_{team_id}_{season}'
        cached_data = self._get_from_cache(cache_key, 'medium')  # Squad doesn't change often
        if cached_data:
            return cached_data
            
        # If auto-fetch is disabled and no cache, return empty result
        if self.disable_auto_fetch:
            return None

        url = f"{self.base_url}/players/squads"
        params = {
            'team': team_id
        }
        
        try:
            results = self._batch_request(url, [params])
            data = results.get(json.dumps(params))
            
            if data:
                self._set_cache(cache_key, data, 'medium')
                return data
                
        except Exception as e:
            self.logger.error(f"Error fetching squad for team {team_id}: {str(e)}")
            
        return None
    
    def fetch_fixture(self, fixture_id):
        """
        Fetch details for a specific fixture by its ID.
        
        Args:
            fixture_id (int or str): The unique identifier of the fixture
        
        Returns:
            Dict: Detailed information about the fixture, or None if not found
        """
        # Use existing fetch_fixtures method with specific fixture_id
        try:
            url = f"{self.base_url}/fixtures"
            params = {'id': fixture_id}
            
            results = self._batch_request(url, [params])
            data = results.get(json.dumps(params), {}).get('response', [])
            
            # Return the first (and typically only) fixture in the response
            return data[0] if data else None
        
        except Exception as e:
            logger.error(f"Error fetching fixture {fixture_id}: {str(e)}")
            return None
