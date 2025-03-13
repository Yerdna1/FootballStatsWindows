import sqlite3

# Connect to the database
conn = sqlite3.connect('football_stats.db')
cursor = conn.cursor()

# Tables to clean (excluding system tables like sqlite_sequence)
tables_to_clean = ['predictions', 'fixtures', 'teams', 'leagues']

# For each table, keep only 2 rows and delete the rest
for table_name in tables_to_clean:
    print(f"Cleaning table: {table_name}")
    
    # Get the primary key column (usually 'id')
    cursor.execute(f"PRAGMA table_info({table_name})")
    columns = cursor.fetchall()
    primary_key = None
    for column in columns:
        if column[5] == 1:  # The 6th element (index 5) indicates if it's a primary key
            primary_key = column[1]
            break
    
    if not primary_key:
        primary_key = 'id'  # Default to 'id' if no primary key is found
    
    # Get the first 2 IDs to keep
    cursor.execute(f"SELECT {primary_key} FROM {table_name} LIMIT 2")
    ids_to_keep = [row[0] for row in cursor.fetchall()]
    
    if ids_to_keep:
        # Delete all rows except the ones to keep
        placeholders = ','.join(['?' for _ in ids_to_keep])
        cursor.execute(f"DELETE FROM {table_name} WHERE {primary_key} NOT IN ({placeholders})", ids_to_keep)
        print(f"  Kept IDs: {ids_to_keep}")
        print(f"  Deleted {cursor.rowcount} rows")
    else:
        print(f"  Table is empty, nothing to clean")

# Commit the changes
conn.commit()

# Verify the results
for table_name in tables_to_clean:
    cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
    row_count = cursor.fetchone()[0]
    print(f"Table {table_name} now has {row_count} rows")

# Close the connection
conn.close()

print("\nDatabase cleanup complete!")
