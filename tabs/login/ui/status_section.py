"""
Status section component for the login tab.
"""
import logging
import tkinter as tk
import customtkinter as ctk
from typing import Callable, Dict, Any

logger = logging.getLogger(__name__)

def create_status_section(
    parent,
    logout_callback: Callable,
    create_button_callback: Callable
) -> Dict[str, Any]:
    """
    Create the status section for the login tab.
    
    Args:
        parent: Parent widget
        logout_callback: Callback for logout button
        create_button_callback: Callback for creating buttons
        
    Returns:
        Dict: Dictionary containing the created widgets
    """
    # Create frame
    status_frame = ctk.CTkFrame(parent)
    status_frame.pack(fill="x", padx=20, pady=10)
    
    # User status label
    user_status_label = ctk.CTkLabel(
        status_frame,
        text="Not logged in",
        font=("Helvetica", 12, "bold")
    )
    user_status_label.pack(side="left", padx=20, pady=10)
    
    # License status label
    license_status_label = ctk.CTkLabel(
        status_frame,
        text="",
        font=("Helvetica", 12)
    )
    license_status_label.pack(side="left", padx=20, pady=10)
    
    # Logout button (initially hidden)
    logout_button = create_button_callback(
        status_frame,
        text="Logout",
        command=logout_callback,
        fg_color="gray",
        hover_color="#555555"
    )
    # Don't pack yet - will be shown when logged in
    
    # Return created widgets
    return {
        "status_frame": status_frame,
        "user_status_label": user_status_label,
        "license_status_label": license_status_label,
        "logout_button": logout_button
    }
