import pytest
from pydantic import ValidationError

from app.core.config import settings
from app.schemas.user import UserCreate


def test_password_policy_rejects_weak_password():
    with pytest.raises(ValidationError):
        UserCreate(
            full_name="Weak User",
            email="weak@example.com",
            password="weakpass",
        )


def test_password_policy_accepts_strong_password():
    payload = UserCreate(
        full_name="Strong User",
        email="strong@example.com",
        password="StrongPass#2026",
    )
    assert payload.password == "StrongPass#2026"


def test_insecure_config_issues_detect_defaults():
    issues = settings.insecure_config_issues()
    assert isinstance(issues, list)
