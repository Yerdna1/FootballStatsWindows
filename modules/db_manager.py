"""
Database manager for the Football Stats application.
This file is a compatibility layer that imports from the modular db package.
"""

# Import the DatabaseManager class from the new modular structure
from modules.db import DatabaseManager

# This ensures backward compatibility with the rest of the application
# Any imports of DatabaseManager from modules.db_manager will still work
