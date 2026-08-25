import asyncio

from app.db.database import Base, engine
from app.db import tables  # noqa: F401


async def init_db() -> None:
    """Create local development tables; production should use migrations."""
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(init_db())

