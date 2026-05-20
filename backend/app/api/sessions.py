from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session as DBSession

from app.api.deps import get_current_user
from app.db.base import get_db
from app.models.session import Session
from app.schemas.session import CreateSessionRequest, SessionResponse
from app.services.streak_service import update_streak

router = APIRouter(prefix="/sessions", tags=["sessions"])


@router.post("", response_model=SessionResponse)
def create_session(
    req: CreateSessionRequest,
    user_id: int = Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    session = Session(
        user_id=user_id,
        category=req.category,
        task_name=req.task_name,
        duration=req.duration,
        notes=req.notes,
    )
    db.add(session)
    db.commit()
    db.refresh(session)

    update_streak(db, user_id)

    return session


@router.get("", response_model=list[SessionResponse])
def list_sessions(
    user_id: int = Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    sessions = (
        db.query(Session)
        .filter(Session.user_id == user_id)
        .order_by(Session.created_at.desc())
        .all()
    )
    return sessions


@router.delete("/{session_id}")
def delete_session(
    session_id: int,
    user_id: int = Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    session = (
        db.query(Session)
        .filter(Session.id == session_id, Session.user_id == user_id)
        .first()
    )
    if not session:
        raise HTTPException(404, "Session not found")

    db.delete(session)
    db.commit()
    return {"message": "Session deleted"}
