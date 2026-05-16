from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    API_TITLE: str = "CyberSentinel API"
    API_VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"
    DEBUG: bool = False
    LOG_LEVEL: str = "INFO"

    DATABASE_URL: str = "postgresql://user:password@localhost:5432/cybersentinel_db"

    SECRET_KEY: str = "change-me-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    ENFORCE_STRICT_SECURITY_IN_PROD: bool = True

    MODEL_PATH: str = "./ml_models/threat_model.pkl"
    CONFIDENCE_THRESHOLD: float = 0.75

    DEFAULT_ADMIN_NAME: str = "CyberSentinel Admin"
    DEFAULT_ADMIN_EMAIL: str = "mlestiwege@gmail.com"
    DEFAULT_ADMIN_PASSWORD: str = "ChangeMe123!"

    # SMTP Email Configuration
    SMTP_SERVER: str = "smtp.gmail.com"
    SMTP_PORT: int = 587
    SMTP_USERNAME: str = "your-email@gmail.com"
    SMTP_PASSWORD: str = "your-app-password"
    SMTP_USE_TLS: bool = True

    # Twilio configuration (can be overridden by .env)
    TWILIO_ACCOUNT_SID: str = ""
    TWILIO_AUTH_TOKEN: str = ""
    TWILIO_FROM_NUMBER: str = ""
    # When True, backend will simulate SMS sends instead of calling Twilio.
    # Useful for local testing with Twilio trial accounts.
    USE_MOCK_TWILIO: bool = True

    # Default recipients for automated alerts (can be overridden via .env)
    ALERT_SMS_RECIPIENTS: List[str] = []
    ALERT_EMAIL_RECIPIENTS: List[str] = []

    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8080"]

    # Password policy
    MIN_PASSWORD_LENGTH: int = 10
    REQUIRE_STRONG_PASSWORD: bool = True

    def insecure_config_issues(self) -> List[str]:
        issues: List[str] = []
        if self.SECRET_KEY in {"change-me-in-production", "CHANGE_ME_SECRET_KEY", ""}:
            issues.append("SECRET_KEY is using an insecure default value")
        if self.DEFAULT_ADMIN_PASSWORD in {"ChangeMe123!", "", "password", "admin123"}:
            issues.append("DEFAULT_ADMIN_PASSWORD appears weak/default")
        return issues

    class Config:
        env_file = ".env"


settings = Settings()