"""
Firebase tab for the Football Stats application.
This file is a compatibility layer that imports from the modular firebase package.
"""

# Import the FirebaseTab class from the new modular structure
from tabs.firebase import FirebaseTab

# This ensures backward compatibility with the rest of the application
# Any imports of FirebaseTab from tabs.firebase_tab will still work
