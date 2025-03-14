from azure.storage.blob import BlobServiceClient, PublicAccess
import os
import sys
import uuid

def create_container_if_not_exists(connection_string, container_name):
    """
    Create a container in Azure Blob Storage if it doesn't exist.
    
    Args:
        connection_string: Azure Storage connection string
        container_name: Container name
    
    Returns:
        True if successful, False otherwise
    """
    try:
        # Create a BlobServiceClient
        blob_service_client = BlobServiceClient.from_connection_string(connection_string)
        
        # Get a container client
        container_client = blob_service_client.get_container_client(container_name)
        
        # Check if container exists
        try:
            container_client.get_container_properties()
            print(f"Container '{container_name}' already exists")
            return True
        except Exception:
            # Container doesn't exist, create it
            print(f"Creating container '{container_name}'...")
            container_client.create_container(public_access=PublicAccess.CONTAINER)
            print(f"Container '{container_name}' created successfully")
            return True
    
    except Exception as e:
        print(f"An error occurred: {str(e)}")
        return False

def get_azure_connection_string():
    """
    Get Azure Storage connection string from environment variable or user input.
    
    Returns:
        Connection string
    """
    connection_string = os.environ.get("AZURE_STORAGE_CONNECTION_STRING")
    
    if not connection_string:
        print("\nAzure Storage connection string not found in environment variables.")
        print("You can create an Azure Storage account at https://portal.azure.com/")
        print("After creating the account, obtain the connection string from the Azure Portal.")
        connection_string = input("\nPlease enter your Azure Storage connection string: ")
    
    return connection_string

def main():
    # Get connection string
    connection_string = get_azure_connection_string()
    
    if not connection_string:
        print("No connection string provided. Exiting.")
        return
    
    # Ask for container name or use default
    container_name = input("\nEnter container name (or press Enter to use 'football-stats'): ")
    if not container_name:
        container_name = "football-stats"
    
    # Create container if it doesn't exist
    if create_container_if_not_exists(connection_string, container_name):
        print("\nAzure Storage container setup complete!")
        print("\nTo upload the installer, run:")
        print(f"python upload_to_azure.py '{connection_string}' {container_name}")
        
        # Offer to save connection string to environment variable
        save_env = input("\nSave connection string to environment variable for future use? (y/n): ")
        if save_env.lower() == 'y':
            # For Windows
            os.system(f'setx AZURE_STORAGE_CONNECTION_STRING "{connection_string}"')
            print("Environment variable set. Please restart your terminal for it to take effect.")
    else:
        print("Failed to set up Azure Storage container. Please check your connection string and try again.")

if __name__ == "__main__":
    main()
