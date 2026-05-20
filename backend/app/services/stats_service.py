from datetime import date, datetime, timedelta

from sqlalchemy import func
from sqlalchemy.orm import Session as DBSession

from app.models.session import Session
from app.models.streak import Streak


def get_today_hours(db: DBSession, user_id: int) -> float:
    today = date.today()
    result = (
        db.query(func.coalesce(func.sum(Session.duration), 0))
        .filter(
            Session.user_id == user_id,
            func.date(Session.created_at) == today,
        )
        .scalar()
    )
    return round(result / 60, 1)


def get_weekly_hours(db: DBSession, user_id: int) -> float:
    week_ago = datetime.now() - timedelta(days=7)
    result = (
        db.query(func.coalesce(func.sum(Session.duration), 0))
        .filter(
            Session.user_id == user_id,
            Session.created_at >= week_ago,
        )
        .scalar()
    )
    return round(result / 60, 1)


def get_monthly_hours(db: DBSession, user_id: int) -> float:
    month_ago = datetime.now() - timedelta(days=30)
    result = (
        db.query(func.coalesce(func.sum(Session.duration), 0))
        .filter(
            Session.user_id == user_id,
            Session.created_at >= month_ago,
        )
        .scalar()
    )
    return round(result / 60, 1)


def get_weekly_stats(db: DBSession, user_id: int) -> dict:
    week_ago = datetime.now() - timedelta(days=7)
    sessions = (
        db.query(Session)
        .filter(
            Session.user_id == user_id,
            Session.created_at >= week_ago,
        )
        .all()
    )

    total_hours = sum(s.duration for s in sessions) / 60
    daily = {}
    for s in sessions:
        day = s.created_at.strftime("%A")
        daily[day] = daily.get(day, 0) + round(s.duration / 60, 1)

    return {
        "total_hours": round(total_hours, 1),
        "total_sessions": len(sessions),
        "daily_breakdown": daily,
    }


def get_monthly_stats(db: DBSession, user_id: int) -> dict:
    month_ago = datetime.now() - timedelta(days=30)
    sessions = (
        db.query(Session)
        .filter(
            Session.user_id == user_id,
            Session.created_at >= month_ago,
        )
        .all()
    )

    total_hours = sum(s.duration for s in sessions) / 60
    categories = {}
    for s in sessions:
        categories[s.category] = (
            categories.get(s.category, 0) + round(s.duration / 60, 1)
        )

    return {
        "total_hours": round(total_hours, 1),
        "total_sessions": len(sessions),
        "category_breakdown": categories,
    }


def get_proof_score(streak: int, total_hours: float) -> int:
    consistency_bonus = 20 if streak >= 7 else 10 if streak >= 3 else 0
    return (streak * 10) + int(total_hours) + consistency_bonus


def get_dashboard(db: DBSession, user_id: int) -> dict:
    today_h = get_today_hours(db, user_id)
    weekly_h = get_weekly_hours(db, user_id)
    monthly_h = get_monthly_hours(db, user_id)

    streak_record = (
        db.query(Streak).filter(Streak.user_id == user_id).first()
    )
    current_streak = streak_record.current_streak if streak_record else 0
    best_streak = streak_record.best_streak if streak_record else 0

    recent = (
        db.query(Session)
        .filter(Session.user_id == user_id)
        .order_by(Session.created_at.desc())
        .limit(5)
        .all()
    )

    proof_score = get_proof_score(current_streak, monthly_h)

    return {
        "today_hours": today_h,
        "weekly_hours": weekly_h,
        "monthly_hours": monthly_h,
        "current_streak": current_streak,
        "best_streak": best_streak,
        "proof_score": proof_score,
        "recent_sessions": [
            {
                "id": s.id,
                "user_id": s.user_id,
                "category": s.category,
                "task_name": s.task_name,
                "duration": s.duration,
                "notes": s.notes,
                "created_at": s.created_at.isoformat(),
            }
            for s in recent
        ],
    }
