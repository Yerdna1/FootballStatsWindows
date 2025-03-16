"""
Chart components for the Stats tab.
"""

import logging
import customtkinter as ctk
import matplotlib.pyplot as plt
from matplotlib.backends.backend_tkagg import FigureCanvasTkAgg
import numpy as np

logger = logging.getLogger(__name__)

class StatsCharts:
    """Chart component manager for the Stats tab."""
    
    def __init__(self, charts_frame, ui_elements):
        """Initialize the chart components."""
        self.charts_frame = charts_frame
        self.ui_elements = ui_elements
        
        # Create chart components
        self._create_charts()
        
    def _create_charts(self):
        """Create chart components"""
        # Create frame for charts
        self.charts_container = ctk.CTkFrame(self.charts_frame)
        self.charts_container.pack(fill="both", expand=True, padx=20, pady=20)
        
        # Create grid layout for charts
        self.charts_container.columnconfigure(0, weight=1)
        self.charts_container.columnconfigure(1, weight=1)
        self.charts_container.rowconfigure(0, weight=1)
        self.charts_container.rowconfigure(1, weight=1)
        
        # Accuracy Pie Chart
        self.accuracy_chart_frame = ctk.CTkFrame(self.charts_container)
        self.accuracy_chart_frame.grid(row=0, column=0, padx=10, pady=10, sticky="nsew")
        
        self.accuracy_chart_label = ctk.CTkLabel(
            self.accuracy_chart_frame,
            text="Prediction Accuracy",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        self.accuracy_chart_label.pack(pady=10)
        
        # Create matplotlib figure for accuracy chart
        self.accuracy_fig = plt.Figure(figsize=(4, 3), dpi=100)
        self.accuracy_canvas = FigureCanvasTkAgg(self.accuracy_fig, master=self.accuracy_chart_frame)
        self.accuracy_canvas.get_tk_widget().pack(fill="both", expand=True, padx=10, pady=10)
        
        # Predictions by Level Chart
        self.level_chart_frame = ctk.CTkFrame(self.charts_container)
        self.level_chart_frame.grid(row=0, column=1, padx=10, pady=10, sticky="nsew")
        
        self.level_chart_label = ctk.CTkLabel(
            self.level_chart_frame,
            text="Predictions by Level",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        self.level_chart_label.pack(pady=10)
        
        # Create matplotlib figure for level chart
        self.level_fig = plt.Figure(figsize=(4, 3), dpi=100)
        self.level_canvas = FigureCanvasTkAgg(self.level_fig, master=self.level_chart_frame)
        self.level_canvas.get_tk_widget().pack(fill="both", expand=True, padx=10, pady=10)
        
        # Accuracy Over Time Chart
        self.time_chart_frame = ctk.CTkFrame(self.charts_container)
        self.time_chart_frame.grid(row=1, column=0, columnspan=2, padx=10, pady=10, sticky="nsew")
        
        self.time_chart_label = ctk.CTkLabel(
            self.time_chart_frame,
            text="Accuracy Over Time",
            font=ctk.CTkFont(size=16, weight="bold")
        )
        self.time_chart_label.pack(pady=10)
        
        # Create matplotlib figure for time chart
        self.time_fig = plt.Figure(figsize=(8, 3), dpi=100)
        self.time_canvas = FigureCanvasTkAgg(self.time_fig, master=self.time_chart_frame)
        self.time_canvas.get_tk_widget().pack(fill="both", expand=True, padx=10, pady=10)
        
        # Add to UI elements
        self.ui_elements["charts"] = self
        
    def update_charts(self, stats):
        """Update charts with stats data"""
        # Accuracy Pie Chart
        self.accuracy_fig.clear()
        ax = self.accuracy_fig.add_subplot(111)
        
        if stats["completed"] > 0:
            correct = stats["correct"]
            incorrect = stats["completed"] - correct
            
            ax.pie(
                [correct, incorrect],
                labels=["Correct", "Incorrect"],
                autopct='%1.1f%%',
                startangle=90,
                colors=['#4CAF50', '#F44336']
            )
            ax.axis('equal')
        else:
            ax.text(0.5, 0.5, "No completed predictions", ha='center', va='center')
            ax.axis('off')
            
        self.accuracy_canvas.draw()
        
        # Predictions by Level Chart
        self.level_fig.clear()
        ax = self.level_fig.add_subplot(111)
        
        if stats["total"] > 0 and "by_level" in stats:
            levels = stats["by_level"]["counts"]
            level_labels = [f"Level {level}" for level in sorted(levels.keys())]
            level_counts = [levels[level] for level in sorted(levels.keys())]
            
            ax.bar(level_labels, level_counts, color='#3498DB')
            ax.set_ylabel('Count')
            ax.set_title('Predictions by Level')
            
            # Add accuracy as text on bars
            if "accuracy" in stats["by_level"]:
                for i, level in enumerate(sorted(levels.keys())):
                    accuracy = stats["by_level"]["accuracy"].get(level, 0)
                    if accuracy > 0:
                        ax.text(
                            i, level_counts[i] + 0.1,
                            f"{accuracy:.1f}%",
                            ha='center', va='bottom'
                        )
        else:
            ax.text(0.5, 0.5, "No predictions", ha='center', va='center')
            ax.axis('off')
            
        self.level_canvas.draw()
        
        # Accuracy Over Time Chart (placeholder)
        self.time_fig.clear()
        ax = self.time_fig.add_subplot(111)
        
        # This would require more complex data processing
        # For now, just show a placeholder
        ax.text(0.5, 0.5, "Accuracy Over Time (Coming Soon)", ha='center', va='center')
        ax.axis('off')
            
        self.time_canvas.draw()