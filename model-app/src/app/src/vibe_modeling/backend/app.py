import logging
import sys

logging.basicConfig(level=logging.INFO, stream=sys.stderr, force=True)

from .core import create_app
from ._routers import ROUTERS

__all__ = ["ROUTERS", "app"]

app = create_app(routers=list(ROUTERS))
