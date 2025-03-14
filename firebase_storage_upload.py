import firebase_admin
from firebase_admin import credentials, storage
import os
import sys
import datetime
import webbrowser
import uuid
import json

# File to upload
INSTALLER_PATH = "FootballStats_Setup.exe"
SERVICE_ACCOUNT_PATH = "firebase-service-account.json"

def get_firebase_config():
    """Get Firebase project ID from service account file"""
    if os.path.exists(SERVICE_ACCOUNT_PATH):
        try:
            with open(SERVICE_ACCOUNT_PATH, 'r') as f:
                service_account = json.load(f)
                project_id = service_account.get('project_id')
                if project_id:
                    print(f"Using project ID from service account: {project_id}")
                    return service_account
        except Exception as e:
            print(f"Error reading service account file: {e}")
    
    print("Service account file not found or invalid.")
    return None

def initialize_firebase():
    """Initialize Firebase with service account"""
    try:
        # Get Firebase config
        config = get_firebase_config()
        if not config:
            return False
        
        # Initialize Firebase with the service account credentials
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        
        # Check if Firebase is already initialized
        try:
            firebase_admin.get_app()
        except ValueError:
            firebase_admin.initialize_app(cred, {
                'storageBucket': f"{config['project_id']}.appspot.com"
            })
        
        return True
    except Exception as e:
        print(f"Error initializing Firebase: {str(e)}")
        return False

def upload_to_firebase_storage():
    """Upload installer to Firebase Storage and make it public"""
    try:
        # Get file name and extension
        file_name = os.path.basename(INSTALLER_PATH)
        file_size = os.path.getsize(INSTALLER_PATH) / (1024 * 1024)  # Size in MB
        
        # Generate unique file path to avoid conflicts
        timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
        unique_id = str(uuid.uuid4())[:8]
        storage_path = f"installers/FootballStats_Setup_{timestamp}_{unique_id}.exe"
        
        print(f"Uploading {file_name} ({file_size:.2f} MB) to Firebase Storage...")
        
        # Get storage bucket
        bucket = storage.bucket()
        
        # Create a blob and upload the file
        blob = bucket.blob(storage_path)
        blob.upload_from_filename(INSTALLER_PATH)
        
        # Make the blob publicly accessible
        blob.make_public()
        
        # Get the public URL
        public_url = blob.public_url
        
        print("\nUpload successful!")
        print(f"\nInstaller available at: {public_url}")
        
        return public_url
    except Exception as e:
        print(f"Error uploading to Firebase Storage: {str(e)}")
        return None

def create_download_page(download_url):
    """Create a nice download page for the installer"""
    try:
        # Get file size for display
        file_size = os.path.getsize(INSTALLER_PATH)
        file_size_mb = file_size / (1024 * 1024)
        
        # Create a unique identifier for this version
        unique_id = str(uuid.uuid4())[:8]
        
        # Get current date for version info
        today = datetime.datetime.now().strftime("%B %d, %Y")
        
        # Create HTML file
        html_file = "Firebase_Download.html"
        
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
                        --primary-color: #FF8F00;
                        --hover-color: #F57C00;
                        --text-color: #333;
                        --light-text: #666;
                        --bg-color: #f8f9fa;
                        --border-color: #FFCA28;
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
                    
                    .firebase-logo {{
                        text-align: center;
                        margin-top: 30px;
                    }}
                    
                    .firebase-logo img {{
                        height: 30px;
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
                            
                            <a href="{download_url}" class="download-btn">Download Now</a>
                            
                            <p class="secure-note">This download is hosted on Firebase Storage</p>
                            
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
                            
                            <div class="firebase-logo">
                                <p>Powered by</p>
                                <svg width="100" viewBox="0 0 256 351" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid"><defs><path d="M1.253 280.732l1.605-3.131 99.353-188.518-44.15-83.475C54.392-1.283 45.074.474 43.87 8.188L1.253 280.732z" id="a"/><filter x="-50%" y="-50%" width="200%" height="200%" filterUnits="objectBoundingBox" id="b"><feGaussianBlur stdDeviation="17.5" in="SourceAlpha" result="shadowBlurInner1"/><feOffset in="shadowBlurInner1" result="shadowOffsetInner1"/><feComposite in="shadowOffsetInner1" in2="SourceAlpha" operator="arithmetic" k2="-1" k3="1" result="shadowInnerInner1"/><feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.06 0" in="shadowInnerInner1"/></filter><path d="M134.417 148.974l32.039-32.812-32.039-61.007c-3.042-5.791-10.433-6.398-13.443-.59l-17.705 34.109-.53 1.744 31.678 58.556z" id="c"/><filter x="-50%" y="-50%" width="200%" height="200%" filterUnits="objectBoundingBox" id="d"><feGaussianBlur stdDeviation="3.5" in="SourceAlpha" result="shadowBlurInner1"/><feOffset dx="1" dy="-9" in="shadowBlurInner1" result="shadowOffsetInner1"/><feComposite in="shadowOffsetInner1" in2="SourceAlpha" operator="arithmetic" k2="-1" k3="1" result="shadowInnerInner1"/><feColorMatrix values="0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0.09 0" in="shadowInnerInner1"/></filter></defs><path d="M0 282.998l2.123-2.972L102.527 89.512l.212-2.017L58.48 4.358C54.77-2.606 44.33-.845 43.114 6.951L0 282.998z" fill="#FFC24A"/><use fill="#FFA712" fill-rule="evenodd" xlink:href="#a"/><use filter="url(#b)" xlink:href="#a"/><path d="M135.005 150.38l32.955-33.75-32.965-62.93c-3.129-5.957-11.866-5.975-14.962 0L102.42 87.287v2.86l32.584 60.233z" fill="#F4BD62"/><use fill="#FFA50E" fill-rule="evenodd" xlink:href="#c"/><use filter="url(#d)" xlink:href="#c"/><path fill="#F6820C" d="M0 282.998l.962-.968 3.496-1.42 128.477-128 1.628-4.431-32.05-61.074z"/><path d="M139.121 347.551l116.275-64.847-33.204-204.495c-1.039-6.398-8.888-8.927-13.468-4.34L0 282.998l115.608 64.548a24.126 24.126 0 0 0 23.513.005" fill="#FDE068"/><path d="M254.354 282.16L221.402 79.218c-1.03-6.35-7.558-8.977-12.103-4.424L1.29 282.6l114.339 63.908a23.943 23.943 0 0 0 23.334.006l115.392-64.355z" fill="#FCCA3F"/><path d="M139.12 345.64a24.126 24.126 0 0 1-23.512-.005L.931 282.015l-.93.983 115.607 64.548a24.126 24.126 0 0 0 23.513.005l116.275-64.847-.285-1.752-115.99 64.689z" fill="#EEAB37"/></svg>
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
    print("  Firebase Storage Uploader for Football Stats")
    print("=====================================================")
    
    # Check if installer exists
    if not os.path.exists(INSTALLER_PATH):
        print(f"Error: Installer not found: {INSTALLER_PATH}")
        return
        
    # Check if service account exists
    if not os.path.exists(SERVICE_ACCOUNT_PATH):
        print(f"Error: Service account not found: {SERVICE_ACCOUNT_PATH}")
        print("Make sure firebase-service-account.json is in the current directory.")
        return
    
    # Initialize Firebase
    print("\nInitializing Firebase...")
    if not initialize_firebase():
        print("Failed to initialize Firebase. Check service account configuration.")
        return
    
    # Upload to Firebase Storage
    download_url = upload_to_firebase_storage()
    
    if download_url:
        # Create download page
        download_page = create_download_page(download_url)
        
        if download_page:
            # Open download page in browser
            try:
                webbrowser.open(download_page)
            except:
                pass
                
            print("\n=====================================================")
            print("  Deployment Complete!")
            print("=====================================================")
            print(f"\nFootballStats_Setup.exe has been deployed to Firebase Storage.")
            print(f"\nDownload URL: {download_url}")
            print(f"\nDownload page: {os.path.abspath(download_page)}")
            print("\nYou can share either the direct download link or the download page.")
            print("Files on Firebase Storage will remain available until you delete them.")
    else:
        print("\nDeployment failed. Check the error messages above.")

if __name__ == "__main__":
    main()
