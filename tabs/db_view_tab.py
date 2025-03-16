"""
Database View tab for the Football Stats application.
This file is a compatibility layer that imports from the modular db_view package.
"""

# Import the DbViewTab class from the new modular structure
from tabs.db_view import DbViewTab

# This ensures backward compatibility with the rest of the application
# Any imports of DbViewTab from tabs.db_view_tab will still work
