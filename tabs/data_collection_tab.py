"""
Data Collection tab for the Football Stats application.
This file is a compatibility layer that imports from the modular data_collection package.
"""

# Import the DataCollectionTab class from the new modular structure
from tabs.data_collection import DataCollectionTab

# This ensures backward compatibility with the rest of the application
# Any imports of DataCollectionTab from tabs.data_collection_tab will still work
