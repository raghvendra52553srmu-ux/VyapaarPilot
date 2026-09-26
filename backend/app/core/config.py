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

    # Custom DATABASE_URL override (defaults to Render PostgreSQL cluster)
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL",
        "postgresql://vyapaaradmin:0rvYGkLvnblVe70ap5ADcR62t7FUnkb3@dpg-darpugrbc2fs7382tr20-a.singapore-postgres.render.com:5432/vyapaarpilot1"
    )


    # AI Provider Settings (gemini, groq, mock)
    AI_PROVIDER: str = "groq"
    GEMINI_API_KEY: str = ""
    GROQ_API_KEY: str = ""
    GROQ_MODEL: str = "qwen/qwen3.8-27b"
    GROQ_STT_MODEL: str = "whisper-large-v3-turbo"

    # Voice / Multimodal Settings
    ASSEMBLYAI_API_KEY: str = ""
    STT_PROVIDER: str = "assemblyai"
    TTS_PROVIDER: str = "assemblyai"
    VOICE_MAX_UPLOAD_MB: float = 15.0
    VOICE_DEFAULT_LANGUAGE: str = "hinglish"

    # CORS
    CORS_ORIGINS: Union[List[str], str] = [
        "http://localhost:5173",
        "http://localhost:3000",
        "http://localhost:8080",
        "https://vyapaarpilot.sundram-devv.workers.dev",
        "*"
    ]

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
        Falls back to self-contained SQLite for seamless cloud (Render) and local dev
        when no remote MySQL server is configured.
        """
        if self.DATABASE_URL:
            url = self.DATABASE_URL
            if url.startswith("postgres://"):
                url = url.replace("postgres://", "postgresql://", 1)
            return url
        
        # If DB_HOST is explicitly configured to a remote MySQL host, use PyMySQL
        if self.DB_HOST and self.DB_HOST not in ("localhost", "127.0.0.1"):
            encoded_password = quote_plus(self.DB_PASSWORD) if self.DB_PASSWORD else ""
            if encoded_password:
                user_pass = f"{self.DB_USER}:{encoded_password}"
            else:
                user_pass = f"{self.DB_USER}"
            return f"mysql+pymysql://{user_pass}@{self.DB_HOST}:{self.DB_PORT}/{self.DB_NAME}?charset=utf8mb4"
            
        # Default to self-contained SQLite for robust zero-config cloud/local operation
        return "sqlite:///./vyapaarpilot.db"

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
