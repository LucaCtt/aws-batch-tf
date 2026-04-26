from pydantic_settings import BaseSettings


class LauncherSettings(BaseSettings):
    """Settings for the launcher. Will be loaded from environment variables or a .env file."""

    model_config = {"env_file": ".env", "env_file_encoding": "utf-8", "extra": "ignore"}

    region_name: str = "us-east-1"
    job_queue: str | None = None
    job_definition: str | None = None
    messages_queue_name: str | None = None
    poll_interval: int = 30
    poll_timeout: int = 3600
