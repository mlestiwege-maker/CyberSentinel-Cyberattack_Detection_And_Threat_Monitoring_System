from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    API_TITLE: str = "CyberSentinel API"
    API_VERSION: str = "1.0.0"
    DEBUG: bool = False
    LOG_LEVEL: str = "INFO"

    DATABASE_URL: str = "sqlite:///./cybersentinel.db"

    SECRET_KEY: str = "change-me-in-production"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    MODEL_PATH: str = "./ml_models/threat_model.pkl"
    CONFIDENCE_THRESHOLD: float = 0.75

    ALLOWED_ORIGINS: List[str] = ["http://localhost:3000", "http://localhost:8080"]

    class Config:
        env_file = ".env"


settings = Settings()