import sqlite3

class SQLiteDatabase:
    def __init__(self, db_path=':memory:'):
        self.db_path = db_path
        self.connection = None
        self.cursor = None

    def connect(self):
        self.connection = sqlite3.connect(self.db_path)
        self.cursor = self.connection.cursor()

    def create_table(self, table_name, columns):
        self.cursor.execute(f"CREATE TABLE IF NOT EXISTS {table_name} ({columns})")
        self.connection.commit()

    def insert_data(self, table_name, data):
        placeholders = ', '.join(['?' for _ in data])
        self.cursor.execute(f"INSERT INTO {table_name} VALUES ({placeholders})", data)
        self.connection.commit()

    def execute_query(self, query):
        self.cursor.execute(query)
        self.connection.commit()

    def fetch_data(self, query):
        self.cursor.execute(query)
        return self.cursor.fetchall()

    def close_connection(self):
        if self.connection:
            self.connection.close()



