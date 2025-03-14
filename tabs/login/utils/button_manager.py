"""
Button manager utility for handling button states during async operations.
"""
import logging
import threading
from typing import Dict, Any, Optional

logger = logging.getLogger(__name__)

class ButtonManager:
    """
    Utility class for managing button states during asynchronous operations.
    Prevents multiple clicks and provides visual feedback.
    """
    
    def __init__(self):
        """Initialize the button manager"""
        self.buttons = {}
        self.lock = threading.Lock()
        
    def set_loading(self, button_id: str, button: Any) -> bool:
        """
        Set a button to loading state.
        
        Args:
            button_id: Unique identifier for the button
            button: The button object
            
        Returns:
            bool: True if the button was set to loading, False if it was already loading
        """
        with self.lock:
            # Check if button is already loading
            if button_id in self.buttons:
                logger.debug(f"Button {button_id} is already loading")
                return False
                
            # Store original text and state
            original_text = button.cget("text")
            original_state = button.cget("state")
            
            # Store button info
            self.buttons[button_id] = {
                "button": button,
                "original_text": original_text,
                "original_state": original_state
            }
            
            # Set loading state
            button.configure(text="Loading...", state="disabled")
            
            logger.debug(f"Button {button_id} set to loading state")
            return True
            
    def reset(self, button_id: str) -> bool:
        """
        Reset a button from loading state to its original state.
        
        Args:
            button_id: Unique identifier for the button
            
        Returns:
            bool: True if the button was reset, False if it wasn't in loading state
        """
        with self.lock:
            # Check if button is in loading state
            if button_id not in self.buttons:
                logger.debug(f"Button {button_id} is not in loading state")
                return False
                
            # Get button info
            button_info = self.buttons[button_id]
            button = button_info["button"]
            original_text = button_info["original_text"]
            original_state = button_info["original_state"]
            
            # Reset button
            button.configure(text=original_text, state=original_state)
            
            # Remove from loading buttons
            del self.buttons[button_id]
            
            logger.debug(f"Button {button_id} reset to original state")
            return True
            
    def is_loading(self, button_id: str) -> bool:
        """
        Check if a button is in loading state.
        
        Args:
            button_id: Unique identifier for the button
            
        Returns:
            bool: True if the button is in loading state, False otherwise
        """
        with self.lock:
            return button_id in self.buttons
            
    def get_button(self, button_id: str) -> Optional[Any]:
        """
        Get a button by its ID.
        
        Args:
            button_id: Unique identifier for the button
            
        Returns:
            The button object if found, None otherwise
        """
        with self.lock:
            if button_id in self.buttons:
                return self.buttons[button_id]["button"]
            return None
            
    def reset_all(self):
        """Reset all buttons to their original state"""
        with self.lock:
            button_ids = list(self.buttons.keys())
            
            for button_id in button_ids:
                self.reset(button_id)
                
            logger.debug(f"Reset {len(button_ids)} buttons")
