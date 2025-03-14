"""
Translation module for the Football Statistics Analyzer application.
Contains translations from English to Slovak, Czech, and German.
"""
from typing import Dict, Optional
import logging

# Import language dictionaries
from .slovak import EN_TO_SK
from .czech import EN_TO_CS
from .german import EN_TO_DE

# Import settings manager
from modules.config import AVAILABLE_LANGUAGES

# Set up logging
logger = logging.getLogger(__name__)

# Current language (default to Slovak)
CURRENT_LANGUAGE = "sk"

# Dictionary of language dictionaries
TRANSLATIONS = {
    "sk": EN_TO_SK,
    "cs": EN_TO_CS,
    "de": EN_TO_DE,
    "en": {}  # English is just the original text
}

def set_language(language_code: str) -> bool:
    """
    Set the current language for translations.
    
    Args:
        language_code (str): Language code ('sk', 'cs', 'de', 'en')
        
    Returns:
        bool: True if language was set successfully, False otherwise
    """
    global CURRENT_LANGUAGE
    if language_code in TRANSLATIONS:
        CURRENT_LANGUAGE = language_code
        logger.info(f"Language set to {language_code} ({AVAILABLE_LANGUAGES.get(language_code, 'Unknown')})")
        return True
    logger.warning(f"Attempted to set unknown language: {language_code}")
    return False

def get_language() -> str:
    """
    Get the current language code.
    
    Returns:
        str: Current language code
    """
    return CURRENT_LANGUAGE

def get_available_languages() -> Dict[str, str]:
    """
    Get a dictionary of available languages.
    
    Returns:
        Dict[str, str]: Dictionary mapping language codes to language names
    """
    return AVAILABLE_LANGUAGES

def translate(text: str, language_code: Optional[str] = None) -> str:
    """
    Translate text from English to the specified language.
    If the text is not found in the dictionary, return the original text.
    
    Args:
        text (str): Text to translate
        language_code (str, optional): Language code to translate to. 
                                      If None, use the current language.
        
    Returns:
        str: Translated text
    """
    if language_code is None:
        language_code = CURRENT_LANGUAGE
        
    if language_code not in TRANSLATIONS:
        return text
        
    # For English, just return the original text
    if language_code == "en":
        return text
        
    translation_dict = TRANSLATIONS[language_code]
    return translation_dict.get(text, text)

def format_translated(text: str, *args, **kwargs) -> str:
    """
    Translate text and then format it with the provided arguments.
    
    Args:
        text (str): Text to translate and format
        *args: Positional arguments for formatting
        **kwargs: Keyword arguments for formatting
        
    Returns:
        str: Translated and formatted text
    """
    translated_text = translate(text)
    try:
        return translated_text.format(*args, **kwargs)
    except Exception as e:
        logger.error(f"Error formatting translated text: {e}")
        # If formatting fails, return the translated text as is
        return translated_text
