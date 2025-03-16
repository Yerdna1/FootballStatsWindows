"""
Login tab for the Football Stats application.
This file is a compatibility layer that imports from the modular login package.
"""

# Import the LoginTab class from the new modular structure
from tabs.login.login_tab import LoginTab

# This ensures backward compatibility with the rest of the application
# Any imports of LoginTab from tabs.login_tab will still work
