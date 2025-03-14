"""
Translation module for the Football Statistics Analyzer application.
This is a backward compatibility module that imports from the new translations package.
"""

# Import from the new translations package
from modules.translations import translate, set_language, get_language, get_available_languages, format_translated
from modules.translations.slovak import EN_TO_SK
from modules.translations.czech import EN_TO_CS
from modules.translations.german import EN_TO_DE

# Export all symbols for backward compatibility
__all__ = [
    'translate', 
    'set_language', 
    'get_language',
    'get_available_languages',
    'format_translated',
    'EN_TO_SK',
    'EN_TO_CS',
    'EN_TO_DE'
]
