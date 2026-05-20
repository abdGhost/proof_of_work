from pydantic import BaseModel


class WeeklyStatsResponse(BaseModel):
    total_hours: float
    total_sessions: int
    daily_breakdown: dict


class MonthlyStatsResponse(BaseModel):
    total_hours: float
    total_sessions: int
    category_breakdown: dict


class DashboardResponse(BaseModel):
    today_hours: float
    weekly_hours: float
    monthly_hours: float
    current_streak: int
    best_streak: int
    proof_score: int
    recent_sessions: list
