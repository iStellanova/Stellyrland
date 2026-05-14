import psycopg2
from psycopg2 import sql
import datetime

class DatabaseManager:
    def __init__(self, dbname="ai_memory", user=None):
        self.dbname = dbname
        self.user = user
        self.conn = None
        self.connect()
        self.initialize_schema()

    def connect(self):
        try:
            # Peer authentication assumes the current OS user has access
            self.conn = psycopg2.connect(dbname=self.dbname, user=self.user)
            self.conn.autocommit = True
        except Exception as e:
            print(f"Error connecting to PostgreSQL: {e}")
            raise

    def initialize_schema(self):
        with self.conn.cursor() as cur:
            # Conversation logs table
            cur.execute("""
                CREATE TABLE IF NOT EXISTS conversation_logs (
                    id SERIAL PRIMARY KEY,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    role TEXT NOT NULL,
                    content TEXT NOT NULL
                );
            """)
            # Entity facts table
            cur.execute("""
                CREATE TABLE IF NOT EXISTS entity_facts (
                    id SERIAL PRIMARY KEY,
                    fact_key TEXT UNIQUE NOT NULL,
                    fact_value TEXT NOT NULL,
                    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                    relevance_score FLOAT DEFAULT 1.0
                );
            """)

    def save_log(self, role, content):
        with self.conn.cursor() as cur:
            cur.execute(
                "INSERT INTO conversation_logs (role, content) VALUES (%s, %s)",
                (role, content)
            )

    def get_recent_logs(self, limit=10):
        with self.conn.cursor() as cur:
            cur.execute(
                "SELECT role, content FROM conversation_logs ORDER BY timestamp DESC LIMIT %s",
                (limit,)
            )
            logs = cur.fetchall()
            return logs[::-1] # Return in chronological order

    def save_fact(self, key, value, score=None):
        with self.conn.cursor() as cur:
            if score is None:
                # If key exists, increment score slightly to reflect reinforcement
                cur.execute("SELECT relevance_score FROM entity_facts WHERE fact_key = %s", (key,))
                row = cur.fetchone()
                score = (row[0] + 0.1) if row else 1.0

            cur.execute("""
                INSERT INTO entity_facts (fact_key, fact_value, relevance_score, last_updated)
                VALUES (%s, %s, %s, CURRENT_TIMESTAMP)
                ON CONFLICT (fact_key) DO UPDATE SET
                    fact_value = EXCLUDED.fact_value,
                    relevance_score = EXCLUDED.relevance_score,
                    last_updated = CURRENT_TIMESTAMP
            """, (key, value, min(score, 5.0))) # Cap at 5.0

    def get_all_facts(self):
        with self.conn.cursor() as cur:
            cur.execute("SELECT fact_key, fact_value FROM entity_facts ORDER BY relevance_score DESC")
            return cur.fetchall()

    def close(self):
        if self.conn:
            self.conn.close()
