
from dash import html, dcc  # Instead of just 'import html'
import dash
from dash.dependencies import Input, Output
import api
from config import ALL_LEAGUES
from sport_analyzers import TeamAnalyzer  
import plotly.graph_objs as go
  
def setup_team_analysis_callbacks(app, api):  
    @app.callback(
    [Output('team-dropdown', 'options'),
     Output('team-dropdown', 'value')],
    Input('team-league-dropdown', 'value')
        )
    def update_teams(league_id):
            if not league_id or league_id == ALL_LEAGUES:
                return [], None
            
            standings = api.fetch_standings(league_id)
            if not standings or not standings.get('response'):
                return [], None
                    
            teams = standings['response'][0]['league']['standings'][0]
            options = [{'label': team['team']['name'], 
                        'value': team['team']['id']} 
                    for team in teams]
            
            # Sort teams alphabetically by name
           #  sorted_options = sorted(options, key=lambda x: x['label'])
            
            # Reset the selected value when league changes
            return sorted(options, key=lambda x: x['label']), None

        # Callback to update team analysis results
    @app.callback(
            [Output('team-results-table', 'data'),
             Output('team-results-table', 'style_data_conditional'),
             Output('scoreless-teams-table', 'data')],
            [Input('team-league-dropdown', 'value'),
             Input('team-dropdown', 'value')]
        )
    def update_team_analysis(league_id, team_id):
            if not team_id:
                return [], [], []
                
            fixtures = api.fetch_fixtures(league_id, team_id=team_id)
            results = TeamAnalyzer.analyze_team_results(fixtures, team_id)
            
            # Prepare results table data
            table_data = []
            style_conditions = [{
                'if': {'column_id': 'result_display'},
                'fontWeight': 'bold'
            }]
            
            for res in results:
                result = res['result']
                table_data.append({
                    'date': res['date'],
                    'opponent': res['opponent'],
                    'score': res['score'],
                    'result_display': result['symbol']
                })
                style_conditions.append({
                    'if': {'column_id': 'result_display',
                           'filter_query': f'{{result_display}} = "{result["symbol"]}"'},
                    'color': result['color']
                })
            
            # Get scoreless teams
            scoreless = TeamAnalyzer.find_scoreless_teams(fixtures)
            
            return table_data, style_conditions, scoreless
    
    @app.callback(
        [Output('goals-time-chart', 'figure'),
         Output('cards-time-chart', 'figure')],
         [Input('team-league-dropdown', 'value'),
          Input('team-dropdown', 'value')]
    )
    def update_time_charts(league_id, team_id):
        if not team_id:
            return {}, {}
                
        stats = api.fetch_team_statistics(league_id, team_id)
        
        # Calculate totals
        total_games = stats['fixtures']['played']['total']
        total_wins = stats['fixtures']['wins']['total']
        total_draws = stats['fixtures']['draws']['total']
        total_losses = stats['fixtures']['loses']['total']
        
        # Goals calculations
        goals_for_intervals = [item['total'] for item in list(stats['goals']['for']['minute'].values())[:-2]]
        goals_against_intervals = [item['total'] for item in list(stats['goals']['against']['minute'].values())[:-2]]
        
        # Extra time goals
        extra_time_goals_for = sum(item['total'] for item in list(stats['goals']['for']['minute'].values())[-2:] if item['total'] is not None)
        extra_time_goals_against = sum(item['total'] for item in list(stats['goals']['against']['minute'].values())[-2:] if item['total'] is not None)
        
        # Total goals from stats
        total_goals_for = stats['goals']['for']['total']['total']
        total_goals_against = stats['goals']['against']['total']['total']
        
        # Calculate differences
        goals_for_diff = total_goals_for - (sum(goals_for_intervals) + extra_time_goals_for)
        goals_against_diff = total_goals_against - (sum(goals_against_intervals) + extra_time_goals_against)
        
        # Cards totals
        total_yellow_cards = sum(item['total'] for item in stats['cards']['yellow'].values() if item['total'] is not None)
        total_red_cards = sum(item['total'] for item in stats['cards']['red'].values() if item['total'] is not None)

        # Goals chart
        goals_figure = go.Figure()
        
        goals_figure.add_trace(go.Bar(
            x=list(stats['goals']['for']['minute'].keys())[:-2],
            y=goals_for_intervals,
            name='Goals Scored',
            marker_color='green'
        ))
        
        goals_figure.add_trace(go.Bar(
            x=list(stats['goals']['against']['minute'].keys())[:-2],
            y=goals_against_intervals,
            name='Goals Conceded',
            marker_color='red'
        ))
        
        goals_title = (
            f'Goals per 15 Minutes<br>'
            f'Total Games: {total_games} (W: {total_wins}, D: {total_draws}, L: {total_losses})<br>'
            f'Total Goals: For {total_goals_for} - Against {total_goals_against}<br>'
            f'Regular Time Goals: For {sum(goals_for_intervals)} - Against {sum(goals_against_intervals)}<br>'
            f'Extra Time Goals: For {extra_time_goals_for} - Against {extra_time_goals_against}<br>'
            f'Other Goals (Own Goals/Other): For {goals_for_diff} - Against {goals_against_diff}'
        )
        
        goals_figure.update_layout(
            title=goals_title,
            xaxis_title='Time Interval',
            yaxis_title='Number of Goals',
            barmode='group',
            title_x=0.5,  # Center title
            title_y=0.97, # Move title up
            margin=dict(t=120)  # Add top margin for title
            )
        
        # Cards chart
        cards_figure = go.Figure()
        
        yellow_cards = [item['total'] for item in list(stats['cards']['yellow'].values())[:-2]]
        cards_figure.add_trace(go.Bar(
            x=list(stats['cards']['yellow'].keys())[:-2],
            y=yellow_cards,
            name='Yellow Cards',
            marker_color='yellow'
        ))
        
        if 'red' in stats['cards']:
            red_cards = [item['total'] if item['total'] is not None else 0 
                        for item in list(stats['cards']['red'].values())[:-2]]
            cards_figure.add_trace(go.Bar(
                x=list(stats['cards']['red'].keys())[:-2],
                y=red_cards,
                name='Red Cards',
                marker_color='red'
            ))
        
        cards_figure.update_layout(
            title=f'Cards per 15 Minutes<br>Games: {total_games}<br>Total Yellow Cards: {total_yellow_cards}, Total Red Cards: {total_red_cards}',
            xaxis_title='Time Interval',
            yaxis_title='Number of Cards',
            barmode='group',
            title_x=0.5,  # Center title 
            title_y=0.95, # Move title up
            margin=dict(t=100)  # Add top margin for title
        )
        
        return goals_figure, cards_figure
    
def add_stats_callback(app,api):
    @app.callback(
        [Output('streaks-results-stats', 'children'),
         Output('clean-sheets-stats', 'children'),
         Output('formations-pie', 'figure')],
        [Input('team-league-dropdown', 'value'),
         Input('team-dropdown', 'value')]
    )
    def update_additional_stats(league_id, team_id):
        if not team_id:
            return dash.no_update, dash.no_update, dash.no_update
            
        stats = api.fetch_team_statistics(league_id, team_id)
        
        # Streaks and Results stats
        streaks_results = html.Div([
            html.P([
                html.Strong("Winning Streak: "), f"{stats['biggest']['streak']['wins']} games",
                html.Br(),
                html.Strong("Drawing Streak: "), f"{stats['biggest']['streak']['draws']} games",
                html.Br(),
                html.Strong("Losing Streak: "), f"{stats['biggest']['streak']['loses']} games",
            ]),
            html.P([
                html.Strong("Biggest Wins: "), 
                f"Home {stats['biggest']['wins']['home']}, Away {stats['biggest']['wins']['away']}",
                html.Br(),
                html.Strong("Biggest Losses: "),
                f"Home {stats['biggest']['loses']['home']}, Away {stats['biggest']['loses']['away']}"
            ]),
            html.P([
                html.Strong("Most Goals: "),
                f"Home {stats['biggest']['goals']['for']['home']}, Away {stats['biggest']['goals']['for']['away']}"
            ]),
            html.P([
                html.Strong("Penalties: "),
                f"Scored {stats['penalty']['scored']['total']} ({stats['penalty']['scored']['percentage']}), ",
                f"Missed {stats['penalty']['missed']['total']} ({stats['penalty']['missed']['percentage']})"
            ])
        ])
        
        # Clean sheets stats
        clean_sheets = html.Div([
            html.P([
                html.Strong("Clean Sheets: "),
                f"Home {stats['clean_sheet']['home']}, ",
                f"Away {stats['clean_sheet']['away']}, ",
                f"Total {stats['clean_sheet']['total']}"
            ]),
            html.P([
                html.Strong("Failed to Score: "),
                f"Home {stats['failed_to_score']['home']}, ",
                f"Away {stats['failed_to_score']['away']}, ",
                f"Total {stats['failed_to_score']['total']}"
            ])
        ])
        
        # Formations pie chart
        formations_fig = go.Figure(data=[go.Pie(
            labels=[f"{lineup['formation']} ({lineup['played']} games)" 
                   for lineup in stats['lineups']],
            values=[lineup['played'] for lineup in stats['lineups']]
        )])
        formations_fig.update_layout(
            title='Formation Usage',
            title_x=0.5,
            margin=dict(t=50)
        )
        
        return streaks_results, clean_sheets, formations_fig