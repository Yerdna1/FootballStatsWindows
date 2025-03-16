"""
Logs tab for the Football Stats application.
This file is a compatibility layer that imports from the modular logs package.
"""

# Import the LogsTab class from the new modular structure
from tabs.logs import LogsTab

# This ensures backward compatibility with the rest of the application
# Any imports of LogsTab from tabs.logs_tab will still work
