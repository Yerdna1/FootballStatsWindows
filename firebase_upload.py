import firebase_admin
from firebase_admin import credentials, storage
import os
import sys
import time
import uuid
import tempfile
import shutil

# File to upload
FILE_PATH = "FootballStats_Setup.exe"
FILE_NAME = os.path.basename(FILE_PATH)

def upload_to_firebase(cred_path):
    """
    Upload a file to Firebase Storage.
    
    Args:
        cred_path: Path to the Firebase service account credentials file
    
    Returns:
        The public URL of the uploaded file
    """
    try:
        # Initialize Firebase with the service account credentials
        cred = credentials.Certificate(cred_path)
        
        # Check if Firebase is already initialized
        try:
            firebase_admin.get_app()
        except ValueError:
            firebase_admin.initialize_app(cred, {
                'storageBucket': get_storage_bucket_from_credentials(cred_path)
            })
        
        # Get the storage bucket
        bucket = storage.bucket()
        
        # Generate a unique blob name to avoid conflicts
        unique_id = str(uuid.uuid4())[:8]
        timestamp = int(time.time())
        blob_name = f"installers/FootballStats_Setup_{timestamp}_{unique_id}.exe"
        
        # Create a reference to the blob
        blob = bucket.blob(blob_name)
        
        print(f"Uploading {FILE_PATH}...")
        
        # Upload the file
        blob.upload_from_filename(FILE_PATH)
        
        # Make the blob publicly accessible
        blob.make_public()
        
        # Get the public URL
        url = blob.public_url
        
        print(f"Upload complete!")
        return url
        
    except Exception as e:
        print(f"Error uploading to Firebase: {str(e)}")
        return None

def get_storage_bucket_from_credentials(cred_path):
    """
    Extract the storage bucket name from the credentials file.
    
    Args:
        cred_path: Path to the Firebase service account credentials file
    
    Returns:
        The storage bucket name in the format 'project-id.appspot.com'
    """
    import json
    
    try:
        with open(cred_path, 'r') as f:
            cred_data = json.load(f)
            project_id = cred_data.get('project_id')
            
            if project_id:
                return f"{project_id}.appspot.com"
            else:
                raise ValueError("Project ID not found in credentials file")
    except Exception as e:
        print(f"Error extracting project ID: {str(e)}")
        return None

def get_credentials_path():
    """
    Get the path to the Firebase credentials file, either from command line or by searching.
    
    Returns:
        Path to the credentials file
    """
    # Check if provided as command line argument
    if len(sys.argv) > 1:
        return sys.argv[1]
    
    # Check for firebase-service-account.json in the current directory
    if os.path.exists("firebase-service-account.json"):
        return "firebase-service-account.json"
    
    print("\nFirebase credentials file not specified.")
    print("Please provide the path to your Firebase service account credentials file.")
    print("You can download this file from the Firebase Console:")
    print("  1. Go to Project Settings > Service accounts")
    print("  2. Click 'Generate new private key'")
    
    path = input("\nEnter path to credentials file: ")
    
    if os.path.exists(path):
        return path
    else:
        print(f"Error: File {path} not found.")
        return None

def main():
    # Get credentials path
    cred_path = get_credentials_path()
    
    if not cred_path:
        print("No valid credentials file provided. Exiting.")
        return
    
    # Upload the file
    url = upload_to_firebase(cred_path)
    
    if url:
        print("\nInstaller is now available for download at:")
        print(url)
        print("\nThis link can be shared with users to download the installer.")
        
        # Create a simple HTML file with the download link
        html_file = "download_link.html"
        with open(html_file, 'w') as f:
            file_size_mb = os.path.getsize(FILE_PATH) / (1024 * 1024)
            
            html = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <title>Football Stats Installer Download</title>
                <style>
                    body {{ font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; }}
                    .container {{ background-color: #f8f9fa; border-radius: 8px; padding: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }}
                    .button {{ background-color: #4CAF50; color: white; padding: 10px 20px; border: none; border-radius: 4px; 
                              cursor: pointer; font-size: 16px; text-decoration: none; display: inline-block; }}
                    .info {{ color: #666; margin: 15px 0; }}
                    .footer {{ margin-top: 30px; color: #999; font-size: 12px; }}
                    h1 {{ color: #333; }}
                </style>
            </head>
            <body>
                <div class="container">
                    <h1>Football Stats Installer</h1>
                    <p>Click the button below to download the Football Stats application installer.</p>
                    <a href="{url}" class="button">Download Installer</a>
                    <p class="info">File size: {file_size_mb:.2f} MB</p>
                    <div class="footer">
                        <p>Football Stats Application - Version 1.0</p>
                    </div>
                </div>
            </body>
            </html>
            """
            
            f.write(html)
        
        print(f"\nA download page has been created at: {html_file}")
        
        # Try to open the HTML file in a browser
        try:
            import webbrowser
            webbrowser.open(html_file)
        except:
            pass
    else:
        print("Failed to upload the installer. Please check your credentials and try again.")

if __name__ == "__main__":
    main()
