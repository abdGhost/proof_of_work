from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api import auth, sessions, stats
from app.db.base import engine, Base

Base.metadata.create_all(bind=engine)

app = FastAPI(title="Proof of Work Tracker")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)
app.include_router(sessions.router)
app.include_router(stats.router)


@app.get("/health")
def health():
    return {"status": "ok"}
