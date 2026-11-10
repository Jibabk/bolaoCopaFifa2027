import os
from functools import lru_cache

from sqlalchemy import Engine, create_engine, text
from sqlalchemy.exc import SQLAlchemyError

# Persistência síncrona com psycopg 3 (ADR-001): DATABASE_URL usa o esquema postgresql+psycopg://
CONNECT_TIMEOUT_SECONDS = 3


@lru_cache
def _engine(url: str) -> Engine:
    return create_engine(
        url, pool_pre_ping=True, connect_args={"connect_timeout": CONNECT_TIMEOUT_SECONDS}
    )


def check_database() -> bool:
    """Retorna True se o banco responde a SELECT 1; nunca expõe detalhes do erro."""
    url = os.getenv("DATABASE_URL")
    if not url:
        return False
    try:
        with _engine(url).connect() as connection:
            connection.execute(text("SELECT 1"))
    except SQLAlchemyError:
        return False
    return True
