from datetime import date, timedelta

from sqlalchemy import func
from sqlalchemy.orm import Session as DBSession

from app.models.session import Session
from app.models.streak import Streak


def update_streak(db: DBSession, user_id: int):
    today = date.today()

    has_session_today = (
        db.query(Session)
        .filter(
            Session.user_id == user_id,
            func.date(Session.created_at) == today,
        )
        .first()
    )

    streak = db.query(Streak).filter(Streak.user_id == user_id).first()
    if not streak:
        streak = Streak(
            user_id=user_id,
            current_streak=1 if has_session_today else 0,
            best_streak=1 if has_session_today else 0,
        )
        db.add(streak)
        db.commit()
        return streak

    if has_session_today:
        yesterday = today - timedelta(days=1)
        had_session_yesterday = (
            db.query(Session)
            .filter(
                Session.user_id == user_id,
                func.date(Session.created_at) == yesterday,
            )
            .first()
        )

        if had_session_yesterday:
            streak.current_streak += 1
        else:
            today_sessions = (
                db.query(Session)
                .filter(
                    Session.user_id == user_id,
                    func.date(Session.created_at) == today,
                )
                .count()
            )
            if today_sessions == 1:
                streak.current_streak = 1

        if streak.current_streak > streak.best_streak:
            streak.best_streak = streak.current_streak
    else:
        pass

    db.commit()
    db.refresh(streak)
    return streak
