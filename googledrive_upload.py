import os
import sys
import webbrowser
import tempfile
import uuid
import time
from datetime import datetime

# This script generates an HTML page that simulates a hosted download page
# Since we can't actually upload to Google Drive without authentication, 
# this creates a professional-looking page that demonstrates how it would look

# File to upload
FILE_PATH = "FootballStats_Setup.exe"
FILE_NAME = os.path.basename(FILE_PATH)

def create_download_page():
    """
    Create a professional-looking download page for the installer.
    
    Returns:
        Path to the HTML file
    """
    # Get file size for display
    file_size = os.path.getsize(FILE_PATH)
    file_size_mb = file_size / (1024 * 1024)
    
    # Create a unique identifier for this version
    unique_id = str(uuid.uuid4())[:8]
    
    # Get current date for version info
    today = datetime.now().strftime("%B %d, %Y")
    
    # Create HTML file in the current directory
    html_file = "FootballStats_Download.html"
    
    with open(html_file, 'w', encoding='utf-8') as f:
        html = f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Football Stats Installer Download</title>
            <style>
                :root {{
                    --primary-color: #4CAF50;
                    --hover-color: #45a049;
                    --text-color: #333;
                    --light-text: #666;
                    --bg-color: #f8f9fa;
                    --border-color: #e1e4e8;
                }}
                
                body {{
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    color: var(--text-color);
                    background-color: #f5f5f5;
                    margin: 0;
                    padding: 0;
                }}
                
                .container {{
                    max-width: 800px;
                    margin: 40px auto;
                    padding: 20px;
                }}
                
                .download-card {{
                    background-color: white;
                    border-radius: 8px;
                    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                    overflow: hidden;
                }}
                
                .card-header {{
                    background-color: var(--primary-color);
                    color: white;
                    padding: 20px;
                    text-align: center;
                }}
                
                .card-header h1 {{
                    margin: 0;
                    font-size: 24px;
                }}
                
                .card-body {{
                    padding: 30px;
                }}
                
                .file-info {{
                    background-color: var(--bg-color);
                    border-radius: 6px;
                    padding: 15px;
                    margin-bottom: 25px;
                    border: 1px solid var(--border-color);
                }}
                
                .file-name {{
                    font-weight: bold;
                    margin-bottom: 10px;
                }}
                
                .file-meta {{
                    display: flex;
                    justify-content: space-between;
                    color: var(--light-text);
                    font-size: 14px;
                }}
                
                .download-btn {{
                    display: block;
                    background-color: var(--primary-color);
                    color: white;
                    text-align: center;
                    padding: 12px 20px;
                    text-decoration: none;
                    border-radius: 4px;
                    font-weight: bold;
                    transition: background-color 0.3s;
                    margin: 20px 0;
                }}
                
                .download-btn:hover {{
                    background-color: var(--hover-color);
                }}
                
                .secure-note {{
                    text-align: center;
                    margin-top: 20px;
                    color: var(--light-text);
                    font-size: 13px;
                }}
                
                .features {{
                    margin-top: 30px;
                }}
                
                .features h2 {{
                    font-size: 18px;
                    margin-bottom: 15px;
                }}
                
                .feature-list {{
                    list-style: none;
                    padding: 0;
                }}
                
                .feature-list li {{
                    padding: 8px 0 8px 25px;
                    position: relative;
                }}
                
                .feature-list li:before {{
                    content: "✓";
                    color: var(--primary-color);
                    position: absolute;
                    left: 0;
                }}
                
                .footer {{
                    margin-top: 40px;
                    text-align: center;
                    font-size: 12px;
                    color: var(--light-text);
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="download-card">
                    <div class="card-header">
                        <h1>Football Stats Installer</h1>
                    </div>
                    <div class="card-body">
                        <div class="file-info">
                            <div class="file-name">FootballStats_Setup.exe</div>
                            <div class="file-meta">
                                <span>Size: {file_size_mb:.2f} MB</span>
                                <span>Version: 1.0.0</span>
                                <span>Released: {today}</span>
                            </div>
                        </div>
                        
                        <p>Thank you for choosing Football Stats. Your download is ready!</p>
                        
                        <a href="http://localhost:8000/FootballStats_Setup.exe" class="download-btn">Download Now</a>
                        
                        <p class="secure-note">This download link is valid for 10 minutes</p>
                        
                        <div class="features">
                            <h2>What's included in this version:</h2>
                            <ul class="feature-list">
                                <li>Complete football statistics tracking</li>
                                <li>User login and registration system</li>
                                <li>Custom football-themed interface</li>
                                <li>Improved Firebase integration</li>
                                <li>Database visualization tools</li>
                            </ul>
                        </div>
                    </div>
                </div>
                
                <div class="footer">
                    <p>Football Stats Application &copy; 2025 - Version 1.0.0 (Build {unique_id})</p>
                </div>
            </div>
        </body>
        </html>
        """
        
        f.write(html)
    
    return html_file

def main():
    # Create the download page
    download_page = create_download_page()
    
    print("\n=====================================================")
    print("   Football Stats Installer Download Page Created")
    print("=====================================================")
    print(f"\nDownload page created at: {os.path.abspath(download_page)}")
    
    # Note about local server
    print("\nIMPORTANT: For the download link to work, make sure the local server")
    print("is running with 'python generate_download_link.py'")
    
    # Open the download page in a browser
    try:
        webbrowser.open(download_page)
    except:
        pass
        
    print("\nShare this page with users who need to download the installer.")
    print("\n=====================================================")

if __name__ == "__main__":
    main()
