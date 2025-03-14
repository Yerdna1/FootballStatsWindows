import http.server
import socketserver
import os
import socket
import webbrowser
from urllib.parse import quote
import threading
import time

# Get file size for display
file_size = os.path.getsize("FootballStats_Setup.exe")
file_size_mb = file_size / (1024 * 1024)

# Configuration
PORT = 8000
FILE_PATH = "FootballStats_Setup.exe"
FILE_NAME = os.path.basename(FILE_PATH)
SERVER_DURATION = 60 * 10  # 10 minutes in seconds

class MyHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # For the root path, show info and link
        if self.path == '/':
            self.send_response(200)
            self.send_header('Content-type', 'text/html')
            self.end_headers()
            
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
                    <a href="/{quote(FILE_NAME)}" class="button">Download Installer</a>
                    <p class="info">File size: {file_size_mb:.2f} MB</p>
                    <p class="info">This download link will be available for 10 minutes.</p>
                    <div class="footer">
                        <p>Football Stats Application - Version 1.0</p>
                    </div>
                </div>
            </body>
            </html>
            """
            
            self.wfile.write(html.encode())
            return
        
        # For all other paths, use the default behavior
        return http.server.SimpleHTTPRequestHandler.do_GET(self)

def get_local_ip():
    """Get the local IP address of the machine"""
    try:
        # Connect to a public server to determine the interface
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        ip = s.getsockname()[0]
        s.close()
        return ip
    except:
        return "127.0.0.1"  # Fallback to localhost

def shutdown_server(httpd, duration):
    """Shutdown the server after the specified duration"""
    time.sleep(duration)
    print(f"\nServer has been running for {duration} seconds. Shutting down...")
    httpd.shutdown()

# Start the server
with socketserver.TCPServer(("", PORT), MyHandler) as httpd:
    local_ip = get_local_ip()
    
    print(f"\n{'=' * 60}")
    print(f"Football Stats Installer Download Server")
    print(f"{'=' * 60}")
    print(f"\nServing at:")
    print(f"  Local:   http://127.0.0.1:{PORT}")
    print(f"  Network: http://{local_ip}:{PORT}")
    print(f"\nFile:     {FILE_NAME}")
    print(f"Size:     {file_size_mb:.2f} MB")
    print(f"\nThis server will automatically stop after 10 minutes.")
    print(f"Press Ctrl+C to stop the server manually.")
    print(f"\n{'=' * 60}")
    
    # Open the browser automatically
    webbrowser.open(f"http://127.0.0.1:{PORT}")
    
    # Start a thread to shutdown the server after the specified duration
    shutdown_thread = threading.Thread(target=shutdown_server, args=(httpd, SERVER_DURATION))
    shutdown_thread.daemon = True
    shutdown_thread.start()
    
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        print("\nServer stopped by user.")
    except Exception as e:
        print(f"\nServer error: {e}")
    
    print("Server has stopped. Download link is no longer available.")
