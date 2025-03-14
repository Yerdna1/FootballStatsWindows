from azure.storage.blob import BlobServiceClient
import os
import sys

def upload_file_to_azure(connection_string, container_name, file_path, blob_name=None):
    """
    Upload a file to Azure Blob Storage.
    
    Args:
        connection_string: Azure Storage connection string
        container_name: Container name
        file_path: Path to the file to upload
        blob_name: Name of the blob (if None, uses the file name)
    
    Returns:
        The URL of the uploaded blob
    """
    # If blob_name is not provided, use the file name
    if blob_name is None:
        blob_name = os.path.basename(file_path)
    
    try:
        # Create a BlobServiceClient
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        
        # Create a BlobClient
        blob_client = blob_service_client.get_blob_client(
            container=container_name, 
            blob=blob_name
        )
        
        # Upload the file
        with open(file_path, "rb") as data:
            blob_client.upload_blob(data, overwrite=True)
        
        # Get the URL
        url = blob_client.url
        
        print(f"File {file_path} uploaded successfully to {url}")
        return url
    
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return None

if __name__ == "__main__":
    # Check if connection string is provided
    if len(sys.argv) < 2:
        print("Usage: python upload_to_azure.py <connection_string>")
        print("Optional: set container name as second argument (default: 'football-stats')")
        sys.exit(1)
    
    # Get connection string from command line
    connection_string = sys.argv[1]
    
    # Set container name (default or from command line)
    container_name = "football-stats"
    if len(sys.argv) >= 3:
        container_name = sys.argv[2]
    
    # File to upload
    file_path = "FootballStats_Setup.exe"
    
    # Upload the file
    url = upload_file_to_azure(connection_string, container_name, file_path)
    
    if url:
        print("\nInstaller is now available at:")
        print(url)
        print("\nShare this URL to provide access to the installer.")
