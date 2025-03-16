"""
Firebase Authentication module for the Football Stats application.
This file is a compatibility layer that imports from the modular firebase package.
"""

# Import the FirebaseAuth class from the new modular structure
from modules.firebase import FirebaseAuth

# This ensures backward compatibility with the rest of the application
# Any imports of FirebaseAuth from modules.firebase_auth will still work
