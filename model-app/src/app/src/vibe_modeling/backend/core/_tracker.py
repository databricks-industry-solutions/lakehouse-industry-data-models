"""ProgressTracker lifespan dependency — wires the tracker into the app lifecycle."""

from __future__ import annotations

from contextlib import asynccontextmanager
from typing import Annotated, AsyncGenerator, TypeAlias

from fastapi import FastAPI, Request
from sqlmodel import Session

from ._base import LifespanDependency
from ._config import logger


class _TrackerDependency(LifespanDependency):
    @asynccontextmanager
    async def lifespan(self, app: FastAPI) -> AsyncGenerator[None, None]:
        from ..progress_tracker import ProgressTracker

        ws = app.state.workspace_client
        config = app.state.config
        engine = app.state.engine

        def session_factory():
            return Session(bind=engine)

        tracker = ProgressTracker(ws, config, session_factory)
        app.state.progress_tracker = tracker

        # Resume tracking for any runs that were in-flight when the app restarted
        await tracker.resume_running_runs()
        logger.info("ProgressTracker initialized")

        yield

        # Cancel all active tracking tasks and stop the tick executor.
        await tracker.shutdown()
        logger.info("ProgressTracker shut down")

    @staticmethod
    def __call__(request: Request) -> "ProgressTracker":
        from ..progress_tracker import ProgressTracker

        return request.app.state.progress_tracker


TrackerDependency: TypeAlias = Annotated["ProgressTracker", _TrackerDependency.depends()]
