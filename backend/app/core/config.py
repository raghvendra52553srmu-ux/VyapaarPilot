import os
from urllib.parse import quote_plus
from typing import List, Union
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import field_validator

class Settings(BaseSettings):
    PROJECT_NAME: str = "VyapaarPilot Backend API"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api"

    # MySQL Database Settings
    DB_HOST: str = "localhost"
    DB_PORT: int = 3306
    DB_USER: str = "root"
    DB_PASSWORD: str = ""
    DB_NAME: str = "vyapaarpilot1"

    # Custom DATABASE_URL override (e.g. for SQLite dev/testing)
    DATABASE_URL: str = ""

    # AI Provider Settings (gemini, groq, mock)
    AI_PROVIDER: str = "groq"
    GEMINI_API_KEY: str = ""
    GROQ_API_KEY: str = ""
    GROQ_MODEL: str = "qwen/qwen3.8-27b"
    GROQ_STT_MODEL: str = "whisper-large-v3-turbo"

    # Voice / Multimodal Settings
    STT_PROVIDER: str = "groq"
    TTS_PROVIDER: str = "mock"
    VOICE_MAX_UPLOAD_MB: float = 15.0
    VOICE_DEFAULT_LANGUAGE: str = "hinglish"

    # CORS
    CORS_ORIGINS: Union[List[str], str] = ["http://localhost:5173", "http://localhost:3000", "*"]

    @field_validator("CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> List[str]:
        if isinstance(v, str):
            return [i.strip() for i in v.split(",") if i.strip()]
        return v

    def get_database_url(self) -> str:
        """
        Returns configured DATABASE_URL. If not explicitly set, constructs
        the MySQL PyMySQL connection string from individual DB parameters.
        """
        if self.DATABASE_URL:
            return self.DATABASE_URL
        
        encoded_password = quote_plus(self.DB_PASSWORD) if self.DB_PASSWORD else ""
        if encoded_password:
            user_pass = f"{self.DB_USER}:{encoded_password}"
        else:
            user_pass = f"{self.DB_USER}"
            
        return f"mysql+pymysql://{user_pass}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}?charset=utf8mb4"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
