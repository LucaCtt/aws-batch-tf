from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Settings for the app. Will be loaded from environment variables or a .env file."""

    region_name: str = "us-east-1"
    job_queue: str | None = None
    job_definition: str | None = None
