import os
import sys
import subprocess
import json
import time
import webbrowser
from datetime import datetime

# Configuration
INSTALLER_PATH = "FootballStats_Setup.exe"
SERVICE_ACCOUNT_PATH = "firebase-service-account.json"

def check_firebase_cli():
    """Check if Firebase CLI is installed"""
    try:
        result = subprocess.run(['firebase', '--version'], 
                                capture_output=True, 
                                text=True, 
                                check=False)
        if result.returncode == 0:
            print(f"Firebase CLI installed: {result.stdout.strip()}")
            return True
        else:
            return False
    except FileNotFoundError:
        return False

def install_firebase_cli():
    """Install Firebase CLI"""
    print("Installing Firebase CLI...")
    try:
        subprocess.run(['npm', 'install', '-g', 'firebase-tools'], 
                       check=True)
        print("Firebase CLI installed successfully.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error installing Firebase CLI: {e}")
        return False
    except FileNotFoundError:
        print("Error: npm not found. Please install Node.js first.")
        print("You can download it from: https://nodejs.org/")
        return False

def login_to_firebase():
    """Login to Firebase"""
    print("\nLogging in to Firebase...")
    try:
        subprocess.run(['firebase', 'login'], check=True)
        print("Firebase login successful.")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Error logging in to Firebase: {e}")
        return False

def get_project_id():
    """Get Firebase project ID from service account file or user input"""
    if os.path.exists(SERVICE_ACCOUNT_PATH):
        try:
            with open(SERVICE_ACCOUNT_PATH, 'r') as f:
                service_account = json.load(f)
                project_id = service_account.get('project_id')
                if project_id:
                    print(f"Using project ID from service account: {project_id}")
                    return project_id
        except Exception as e:
            print(f"Error reading service account file: {e}")
    
    # Ask user for project ID
    print("\nCould not determine Firebase project ID automatically.")
    project_id = input("Please enter your Firebase project ID: ")
    return project_id.strip()

def create_distribution_manifest():
    """Create distribution manifest for the installer"""
    manifest_path = "firebase-distribution-manifest.json"
    
    # Get current version
    version = "1.0.0"  # Default version
    
    # Get current date for release notes
    today = datetime.now().strftime("%B %d, %Y")
    
    manifest = {
        "version": version,
        "releaseNotes": f"Football Stats Installer - {today}\n\n"
                        "• Added custom football icon\n"
                        "• Fixed Firebase authentication issues\n"
                        "• Improved error handling\n"
                        "• Added better configuration file handling"
    }
    
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print(f"Created distribution manifest: {manifest_path}")
    return manifest_path

def upload_to_app_distribution(project_id, groups="testers"):
    """Upload installer to Firebase App Distribution"""
    print("\nUploading installer to Firebase App Distribution...")
    
    # Create distribution manifest
    manifest_path = create_distribution_manifest()
    
    # Upload command
    cmd = [
        'firebase', 'appdistribution:distribute', INSTALLER_PATH,
        '--app', f"{project_id}",
        '--release-notes-file', manifest_path,
        '--groups', groups
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True, check=False)
        
        if result.returncode == 0:
            print("Upload successful!")
            print(result.stdout)
            return True, result.stdout
        else:
            print(f"Error uploading to Firebase App Distribution:")
            print(result.stderr)
            
            # Check for common errors
            if "not authorized" in result.stderr:
                print("\nTIP: You may need to login first. Try running 'firebase login' manually.")
            elif "not found" in result.stderr and "app" in result.stderr:
                print("\nTIP: Make sure you've registered your app in the Firebase console.")
                print("Go to: https://console.firebase.google.com/project/_/appdistribution")
            
            return False, result.stderr
    except Exception as e:
        print(f"Error executing command: {e}")
        return False, str(e)

def create_alternative_instructions():
    """
    Create HTML file with instructions for manual Firebase App Distribution setup
    """
    html_file = "Firebase_Distribution_Setup.html"
    
    with open(html_file, "w", encoding="utf-8") as f:
        html = f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Firebase App Distribution Setup</title>
            <style>
                body {{
                    font-family: Arial, sans-serif;
                    line-height: 1.6;
                    max-width: 800px;
                    margin: 0 auto;
                    padding: 20px;
                    color: #333;
                }}
                h1 {{
                    color: #F57C00;
                    border-bottom: 2px solid #FFCA28;
                    padding-bottom: 10px;
                }}
                h2 {{
                    color: #F57C00;
                    margin-top: 30px;
                }}
                .step {{
                    background-color: #fff8e1;
                    border-left: 4px solid #FFCA28;
                    padding: 15px;
                    margin-bottom: 20px;
                    border-radius: 0 4px 4px 0;
                }}
                code {{
                    background-color: #f5f5f5;
                    padding: 2px 5px;
                    border-radius: 3px;
                    font-family: monospace;
                }}
                pre {{
                    background-color: #f5f5f5;
                    padding: 10px;
                    border-radius: 4px;
                    overflow-x: auto;
                }}
                .note {{
                    background-color: #e8f4fd;
                    border-left: 4px solid #2196F3;
                    padding: 15px;
                    margin: 15px 0;
                    border-radius: 0 4px 4px 0;
                }}
                a {{
                    color: #1976D2;
                    text-decoration: none;
                }}
                a:hover {{
                    text-decoration: underline;
                }}
            </style>
        </head>
        <body>
            <h1>Firebase App Distribution Setup Guide</h1>
            
            <p>This guide will help you set up Firebase App Distribution to distribute your Football Stats installer to testers.</p>
            
            <div class="note">
                <strong>Note:</strong> Firebase App Distribution is primarily designed for mobile apps, but we can adapt it for Windows applications.
            </div>
            
            <h2>Prerequisites</h2>
            <ul>
                <li>Firebase project</li>
                <li>Node.js and npm installed</li>
                <li>Firebase CLI (will be installed in the steps below)</li>
            </ul>
            
            <h2>Step 1: Install Firebase CLI</h2>
            <div class="step">
                <p>Open a terminal and run:</p>
                <pre>npm install -g firebase-tools</pre>
            </div>
            
            <h2>Step 2: Login to Firebase</h2>
            <div class="step">
                <p>Authenticate with Firebase using your Google account:</p>
                <pre>firebase login</pre>
                <p>This will open a browser window for authentication.</p>
            </div>
            
            <h2>Step 3: Set Up Your Firebase Project</h2>
            <div class="step">
                <ol>
                    <li>Go to the <a href="https://console.firebase.google.com/" target="_blank">Firebase Console</a></li>
                    <li>Create a new project or select an existing one</li>
                    <li>In the left sidebar, click on "App Distribution"</li>
                    <li>Follow the setup process to create a new app</li>
                </ol>
            </div>
            
            <h2>Step 4: Prepare Distribution Manifest</h2>
            <div class="step">
                <p>Create a file named <code>firebase-distribution-manifest.json</code> with the following content:</p>
                <pre>{{
  "version": "1.0.0",
  "releaseNotes": "Football Stats Installer - Initial Release\\n\\n• Custom football icon\\n• Fixed Firebase authentication\\n• Improved error handling"
}}</pre>
            </div>
            
            <h2>Step 5: Distribute Your Installer</h2>
            <div class="step">
                <p>Run the following command to upload your installer:</p>
                <pre>firebase appdistribution:distribute FootballStats_Setup.exe --app YOUR_PROJECT_ID --release-notes-file firebase-distribution-manifest.json --groups testers</pre>
                <p>Replace <code>YOUR_PROJECT_ID</code> with your Firebase project ID.</p>
            </div>
            
            <h2>Step 6: Invite Testers</h2>
            <div class="step">
                <ol>
                    <li>In the Firebase Console, go to App Distribution</li>
                    <li>Find your app and click on it</li>
                    <li>Click on "Testers & Groups"</li>
                    <li>Add testers by email address</li>
                </ol>
                <p>The testers will receive an email invitation to download the installer.</p>
            </div>
            
            <div class="note">
                <p><strong>Tip:</strong> If you prefer a simpler approach, consider using Firebase Storage instead. Upload your installer to Firebase Storage, set the file permissions to public, and share the download URL.</p>
            </div>
            
            <p>For more detailed information, visit the <a href="https://firebase.google.com/docs/app-distribution" target="_blank">Firebase App Distribution documentation</a>.</p>
        </body>
        </html>
        """
        f.write(html)
    
    return html_file

def main():
    print("\n=====================================================")
    print("  Firebase App Distribution Setup for Football Stats")
    print("=====================================================")
    
    # Check for Firebase CLI
    if not check_firebase_cli():
        print("\nFirebase CLI not found. Installing...")
        if not install_firebase_cli():
            print("\nCould not install Firebase CLI automatically.")
            instructions_file = create_alternative_instructions()
            print(f"\nCreated manual instructions file: {instructions_file}")
            try:
                webbrowser.open(instructions_file)
            except:
                pass
            return
    
    # Login to Firebase
    if not login_to_firebase():
        print("\nFirebase login failed.")
        instructions_file = create_alternative_instructions()
        print(f"\nCreated manual instructions file: {instructions_file}")
        try:
            webbrowser.open(instructions_file)
        except:
            pass
        return
    
    # Get project ID
    project_id = get_project_id()
    if not project_id:
        print("No project ID provided. Exiting.")
        return
    
    # Upload to App Distribution
    success, message = upload_to_app_distribution(project_id)
    
    if success:
        print("\n=====================================================")
        print("  Upload Successful!")
        print("=====================================================")
        print("\nYour installer has been uploaded to Firebase App Distribution.")
        print("\nTesters will receive an email invitation to download the installer.")
        print("\nYou can manage testers and releases in the Firebase Console:")
        print(f"https://console.firebase.google.com/project/{project_id}/appdistribution")
    else:
        print("\n=====================================================")
        print("  Upload Failed")
        print("=====================================================")
        print("\nCreating instructions for manual setup...")
        instructions_file = create_alternative_instructions()
        print(f"Created manual instructions file: {instructions_file}")
        try:
            webbrowser.open(instructions_file)
        except:
            pass

if __name__ == "__main__":
    main()
