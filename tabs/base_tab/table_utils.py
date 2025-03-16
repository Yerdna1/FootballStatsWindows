import customtkinter as ctk
import tkinter as tk
from tkinter import ttk
import logging
from typing import Dict, List, Any, Optional, Tuple

logger = logging.getLogger(__name__)

class TableUtils:
    """Utility class for creating and managing tables"""
    
    @staticmethod
    def create_table(parent, columns, height=400, settings_manager=None) -> ttk.Treeview:
        """
        Create a table widget with a vertical scrollbar.
        
        Args:
            parent: Parent widget
            columns: List of column names
            height: Table height
            settings_manager: Optional settings manager for font size
            
        Returns:
            ttk.Treeview: Table widget
        """
        # Create a frame for the table and scrollbar
        frame = ctk.CTkFrame(parent)
        
        # Use grid for layout
        frame.grid(sticky="nsew", padx=10, pady=10)
        
        # Configure the frame's grid
        frame.grid_rowconfigure(0, weight=1)
        frame.grid_columnconfigure(0, weight=1)
        
        # Apply font size if settings manager is provided
        if settings_manager:
            font_size = settings_manager.get_font_size()
            style = ttk.Style()
            style.configure("Treeview", font=('Helvetica', font_size))
            style.configure("Treeview.Heading", font=('Helvetica', font_size + 2, 'bold'))
            style.configure("Treeview", rowheight=max(30, int(font_size * 1.2)))
        
        # Create the table
        table = ttk.Treeview(frame, columns=columns, show="headings", height=height)
        
        # Set column headings
        for col in columns:
            table.heading(col, text=col)
            table.column(col, width=100)
        
        # Add scrollbar
        scrollbar = ttk.Scrollbar(frame, orient="vertical", command=table.yview)
        table.configure(yscrollcommand=scrollbar.set)
        
        # Position table and scrollbar with grid
        table.grid(row=0, column=0, sticky="nsew")
        scrollbar.grid(row=0, column=1, sticky="ns")
        
        # Store the frame as an attribute of the table for future reference
        table.container_frame = frame
        
        return table
    
    @staticmethod    
    def create_legacy_table(parent, columns, height=400, settings_manager=None) -> ttk.Treeview:
        """
        Create a table with the given columns and increased font size.
        This is the older implementation, kept for backward compatibility.
        
        Args:
            parent: Parent widget
            columns: List of column names or column configuration dictionaries
            height: Table height
            settings_manager: Optional settings manager for font size
            
        Returns:
            ttk.Treeview: Table widget
        """
        logger.warning("Using deprecated _create_table method, consider using create_table instead")
        
        # Create frame for table
        frame = ctk.CTkFrame(parent)
        
        # Configure the frame's grid
        frame.grid_rowconfigure(0, weight=1)
        frame.grid_columnconfigure(0, weight=1)
        
        # Configure style for larger font
        style = ttk.Style()
        if settings_manager:
            font_size = settings_manager.get_font_size()  # Get font size from settings
            style.configure("Treeview", font=('Helvetica', font_size))  # Use font size from settings
            style.configure("Treeview.Heading", font=('Helvetica', font_size + 4, 'bold'))  # Increase header font size
            style.configure("Treeview", rowheight=max(60, int(font_size * 1.2)))  # Adjust row height based on font size
        
        # Create treeview
        table = ttk.Treeview(frame, columns=[f"col{i}" for i in range(len(columns))], show="headings", height=height)
        
        # Configure columns
        for i, col in enumerate(columns):
            # Handle both string and dict columns
            if isinstance(col, dict):
                col_text = col.get("text", f"Column {i}")
                col_width = col.get("width", 100)
            else:
                col_text = col
                col_width = 100
                
            table.heading(f"col{i}", text=col_text)
            table.column(f"col{i}", width=col_width, anchor="center")
        
        # Add scrollbars
        vsb = ttk.Scrollbar(frame, orient="vertical", command=table.yview)
        hsb = ttk.Scrollbar(frame, orient="horizontal", command=table.xview)
        table.configure(yscrollcommand=vsb.set, xscrollcommand=hsb.set)
        
        # Grid layout
        table.grid(column=0, row=0, sticky="nsew")
        vsb.grid(column=1, row=0, sticky="ns")
        hsb.grid(column=0, row=1, sticky="ew")
        
        # Configure grid weights
        frame.grid_columnconfigure(0, weight=1)
        frame.grid_rowconfigure(0, weight=1)
        
        # Try to add sorting functionality
        try:
            from modules.table_sorter import TableSorter
            sorter = TableSorter(table)
            table.sorter = sorter
            
            # Apply default sort by date if a date column exists
            date_columns = ["date", "time", "timestamp", "created", "modified"]
            for i, col in enumerate(columns):
                col_text = col.get("text", "") if isinstance(col, dict) else col
                col_text = str(col_text).lower()
                if any(date_name in col_text for date_name in date_columns):
                    sorter.apply_initial_sort(f"col{i}", reverse=True)
                    break
        except Exception as e:
            logger.error(f"Failed to add sorting functionality: {str(e)}")
        
        # For backward compatibility, return just the table
        # But also provide the frame as an attribute that can be accessed if needed
        table.container_frame = frame
        
        return table
    
    @staticmethod
    def create_sortable_table(parent, columns, height=400, settings_manager=None) -> Tuple[ctk.CTkFrame, ttk.Treeview]:
        """
        Create a sortable table with the given columns and increased font size.
        
        Args:
            parent: Parent widget
            columns: List of column names or column configuration dictionaries
            height: Table height
            settings_manager: Optional settings manager for font size
            
        Returns:
            tuple: (frame, table) containing the frame and table widgets
        """
        table = TableUtils.create_legacy_table(parent, columns, height, settings_manager)
        
        # Return both the frame and the table
        return table.container_frame, table
    
    @staticmethod
    def create_advanced_sortable_table(parent, columns=None, height=10) -> Tuple[ctk.CTkFrame, ttk.Treeview]:
        """
        Create a sortable treeview table with advanced column configuration.
        
        Args:
            parent: Parent widget
            columns: List of column configuration dictionaries
            height: Table height
            
        Returns:
            tuple: (frame, table) containing the frame and table widgets
        """
        # Create a frame to hold the treeview and scrollbars
        frame = ctk.CTkFrame(parent)
        
        # Create horizontal and vertical scrollbars
        h_scrollbar = ttk.Scrollbar(frame, orient="horizontal")
        v_scrollbar = ttk.Scrollbar(frame, orient="vertical")
        
        # Configure the treeview
        table = ttk.Treeview(
            frame,
            columns=[col["text"] for col in columns] if columns else [],
            height=height,
            selectmode="extended",
            yscrollcommand=v_scrollbar.set,
            xscrollcommand=h_scrollbar.set
        )
        
        # Configure scrollbars
        h_scrollbar.configure(command=table.xview)
        v_scrollbar.configure(command=table.yview)
        
        # Place scrollbars
        v_scrollbar.pack(side="right", fill="y")
        h_scrollbar.pack(side="bottom", fill="x")
        
        # Place treeview
        table.pack(side="left", fill="both", expand=True)
        
        # Configure column headings and widths
        table.column("#0", width=0, stretch=False)  # Hidden ID column
        table.heading("#0", text="", anchor="w")
        
        if columns:
            for i, col in enumerate(columns):
                # Use column ID as the index (easier for sorting)
                col_id = col.get("id", str(i))
                table.column(i, width=col.get("width", 100), stretch=col.get("stretch", True))
                table.heading(i, text=col.get("text", ""), anchor=col.get("anchor", "w"))
        
        # Try to import and initialize the TableSorter
        try:
            from modules.table_sorter import TableSorter
            sorter = TableSorter(table)
            
            # Store the sorter reference in the table for future access
            table.sorter = sorter
            
            # Apply default sort by date if a date column exists
            if columns:
                # Look for date columns - common names
                date_columns = ["date", "time", "timestamp", "created", "modified"]
                for i, col in enumerate(columns):
                    col_text = col.get("text", "").lower()
                    if any(date_name in col_text for date_name in date_columns):
                        # Found a date column, sort by it (newest first)
                        sorter.apply_initial_sort(str(i), reverse=True)
                        break
        except Exception as e:
            logger.error(f"Failed to add sorting functionality: {str(e)}")
        
        return frame, table
    
    @staticmethod
    def add_row(table, values):
        """
        Add a row to the table.
        
        Args:
            table: The table widget
            values: List of values for the row
            
        Returns:
            str: Item ID of the new row
        """
        return table.insert("", "end", values=values)
        
    @staticmethod
    def clear_table(table):
        """
        Clear all rows from the table.
        
        Args:
            table: The table widget
        """
        for item in table.get_children():
            table.delete(item)
            
    @staticmethod
    def get_selected_row(table):
        """
        Get the currently selected row in the table.
        
        Args:
            table: The table widget
            
        Returns:
            dict: Dictionary of column:value pairs, or None if no selection
        """
        selection = table.selection()
        if not selection:
            return None
            
        item = selection[0]
        values = table.item(item, "values")
        
        # Create a dictionary of column:value pairs
        columns = table.cget("columns")
        row_data = {}
        
        for i, col in enumerate(columns):
            row_data[col] = values[i] if i < len(values) else None
            
        return row_data