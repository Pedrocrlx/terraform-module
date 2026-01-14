from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import os
import psycopg2
app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow requests from any origin (Frontend)
    allow_credentials=True,
    allow_methods=["*"],  # Allow all methods (GET, POST, etc)
    allow_headers=["*"],  # Allow all headers
)

def init_db():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("""
        CREATE TABLE IF NOT EXISTS notes (
            id SERIAL PRIMARY KEY,
            content TEXT NOT NULL
        );
    """)
    conn.commit()
    cur.close()
    conn.close()

@app.on_event("startup")
def startup():
    init_db()

def get_db():
    return psycopg2.connect(
        host=os.getenv("DB_HOST"),
        database=os.getenv("POSTGRES_DB"),
        user=os.getenv("POSTGRES_USER", "postgres"),
        password=os.getenv("POSTGRES_PASSWORD"),
        port=os.getenv("POSTGRES_PORT", 5432),
        )
    
@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/notes")
def get_notes():
    conn = get_db()
    cur = conn.cursor()
    cur.execute("SELECT id, content FROM notes;")
    rows = cur.fetchall()
    cur.close()
    conn.close()
    return rows

@app.post("/notes")
def create_note(note: str):
    conn = get_db()
    cur = conn.cursor()
    cur.execute("INSERT INTO notes (content) VALUES (%s);", (note,))
    conn.commit()
    cur.close()
    conn.close()
    return {"message": "Note created"}
