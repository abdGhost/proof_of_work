from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session as DBSession

from app.api.deps import get_current_user
from app.db.base import get_db
from app.services import stats_service

router = APIRouter(prefix="/stats", tags=["stats"])


@router.get("/dashboard")
def get_dashboard(
    user_id: int = Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    return stats_service.get_dashboard(db, user_id)


@router.get("/weekly")
def get_weekly(
    user_id: int = Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    return stats_service.get_weekly_stats(db, user_id)


@router.get("/monthly")
def get_monthly(
    user_id: int = Depends(get_current_user),
    db: DBSession = Depends(get_db),
):
    return stats_service.get_monthly_stats(db, user_id)
