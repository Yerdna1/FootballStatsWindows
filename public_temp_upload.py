import os
import sys
import requests
import json
import datetime
import webbrowser
import uuid
import time
from datetime import datetime

# File to upload
INSTALLER_PATH = "FootballStats_Setup.exe"

def upload_to_temporary_service():
    """Upload file to a temporary file hosting service that provides direct links"""
    print(f"Uploading {INSTALLER_PATH} to temporary file hosting service...")
    
    # Get file size
    file_size = os.path.getsize(INSTALLER_PATH)
    file_size_mb = file_size / (1024 * 1024)
    
    try:
        # First, try transfer.sh
        try:
            with open(INSTALLER_PATH, 'rb') as f:
                print("Uploading to transfer.sh (may take a few minutes for large files)...")
                response = requests.put(f"https://transfer.sh/{os.path.basename(INSTALLER_PATH)}", 
                                       data=f, 
                                       timeout=300)  # 5 minute timeout
                
                if response.status_code == 200:
                    url = response.text.strip()
                    print(f"Upload successful to transfer.sh!")
                    return url, "transfer.sh", 7  # Link valid for 7 days
        except Exception as e:
            print(f"transfer.sh upload failed: {str(e)}")
        
        # If transfer.sh fails, try file.io
        try:
            with open(INSTALLER_PATH, 'rb') as f:
                print("Uploading to file.io (may take a few minutes for large files)...")
                response = requests.post("https://file.io/?expires=14d",  # 14 days expiration
                                        files={"file": f},
                                        timeout=300)  # 5 minute timeout
                
                if response.status_code == 200:
                    result = response.json()
                    if result.get('success') and result.get('link'):
                        url = result.get('link')
                        print(f"Upload successful to file.io!")
                        return url, "file.io", 14  # Link valid for 14 days
        except Exception as e:
            print(f"file.io upload failed: {str(e)}")
            
        # Try another service - 0x0.st
        try:
            with open(INSTALLER_PATH, 'rb') as f:
                print("Uploading to 0x0.st (may take a few minutes for large files)...")
                response = requests.post("https://0x0.st", 
                                        files={"file": f},
                                        timeout=300)  # 5 minute timeout
                
                if response.status_code == 200:
                    url = response.text.strip()
                    print(f"Upload successful to 0x0.st!")
                    return url, "0x0.st", 30  # Link valid for about a month
        except Exception as e:
            print(f"0x0.st upload failed: {str(e)}")
            
        # If all fail, return error
        print("All upload attempts failed.")
        return None, None, 0
    except Exception as e:
        print(f"Error during upload: {str(e)}")
        return None, None, 0

def create_download_page(download_url, service_name, days_valid):
    """Create a nice download page for the installer"""
    try:
        # Get file size for display
        file_size = os.path.getsize(INSTALLER_PATH)
        file_size_mb = file_size / (1024 * 1024)
        
        # Create a unique identifier for this version
        unique_id = str(uuid.uuid4())[:8]
        
        # Get current date for version info
        today = datetime.now().strftime("%B %d, %Y")
        
        # Calculate expiration date
        expiry_date = (datetime.now() + datetime.timedelta(days=days_valid)).strftime("%B %d, %Y")
        
        # Create HTML file
        html_file = "FootballStats_Download.html"
        
        with open(html_file, 'w', encoding='utf-8') as f:
            html = f"""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Football Stats Installer</title>
                <style>
                    :root {{
                        --primary-color: #4CAF50;
                        --hover-color: #45a049;
                        --text-color: #333;
                        --light-text: #666;
                        --bg-color: #f8f9fa;
                        --border-color: #e1e4e8;
                        --alert-color: #ff9800;
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
                    
                    .alert {{
                        background-color: #fff3e0;
                        border-left: 4px solid var(--alert-color);
                        padding: 15px;
                        margin: 20px 0;
                        border-radius: 0 4px 4px 0;
                        color: #856404;
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
                            
                            <div class="alert">
                                <strong>Note:</strong> This download link is temporary and will expire on {expiry_date}.
                            </div>
                            
                            <p>Thank you for choosing Football Stats. Your download is ready!</p>
                            
                            <a href="{download_url}" class="download-btn">Download Now</a>
                            
                            <p class="secure-note">This download is hosted on {service_name}</p>
                            
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
        
        print(f"\nCreated download page: {html_file}")
        return html_file
    except Exception as e:
        print(f"Error creating download page: {str(e)}")
        return None

def main():
    print("\n=====================================================")
    print("   Temporary Hosting for Football Stats Installer")
    print("=====================================================")
    
    # Check if installer exists
    if not os.path.exists(INSTALLER_PATH):
        print(f"Error: Installer not found: {INSTALLER_PATH}")
        return
    
    # Upload to temporary file hosting service
    download_url, service_name, days_valid = upload_to_temporary_service()
    
    if download_url:
        # Create download page
        download_page = create_download_page(download_url, service_name, days_valid)
        
        if download_page:
            # Open download page in browser
            try:
                webbrowser.open(download_page)
            except:
                pass
                
            print("\n=====================================================")
            print("  Deployment Complete!")
            print("=====================================================")
            print(f"\nFootballStats_Setup.exe has been uploaded to {service_name}.")
            print(f"\nDownload URL: {download_url}")
            print(f"\nDownload page: {os.path.abspath(download_page)}")
            print(f"\nThis link will be valid for {days_valid} days (until {(datetime.now() + datetime.timedelta(days=days_valid)).strftime('%B %d, %Y')}).")
            print("\nShare either the direct download link or the download page.")
    else:
        print("\nDeployment failed. Check the error messages above.")
        print("\nSince all online uploads failed, your installer is still available at http://localhost:8000")
        print("If the local server is still running, users can download from there.")

if __name__ == "__main__":
    main()
