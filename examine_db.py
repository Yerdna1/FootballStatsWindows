import sqlite3

# Connect to the database
conn = sqlite3.connect('football_stats.db')
cursor = conn.cursor()

# Get list of tables
cursor.execute("SELECT name FROM sqlite_master WHERE type='table'")
tables = cursor.fetchall()

print("Tables in the database:")
for table in tables:
    table_name = table[0]
    print(f"\n{table_name}")
    
    # Get row count
    cursor.execute(f"SELECT COUNT(*) FROM {table_name}")
    row_count = cursor.fetchone()[0]
    print(f"  Row count: {row_count}")
    
    # Get column names
    cursor.execute(f"PRAGMA table_info({table_name})")
    columns = cursor.fetchall()
    print(f"  Columns: {', '.join(column[1] for column in columns)}")
    
    # Show first row as sample
    if row_count > 0:
        cursor.execute(f"SELECT * FROM {table_name} LIMIT 1")
        sample = cursor.fetchone()
        print(f"  Sample row: {sample}")

# Close the connection
conn.close()
