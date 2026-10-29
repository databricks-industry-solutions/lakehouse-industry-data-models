"""Constants, enums and path builders for headless assessments."""
from __future__ import annotations

import re
from datetime import timedelta
from enum import Enum

# ADMIN_HELP: the ``error`` discriminator of a failure the admin must act on, and the readiness
# ``fix_action`` of a check the app sets up itself. The UI renders both as the admin-help block.
from ..core._errors import ADMIN_HELP as ADMIN_HELP

JOB_NAME = "vibe-assess"
TASK_KEY = "assess_domain"
RUNS_VOLUME = "assess_runs"
POLL_INTERVAL_S = 20
TASK_TIMEOUT_S = 3 * 60 * 60
JOB_FOLDER = "vibe-assess"  # under the app SP home: /Users/<app-sp>/vibe-assess/<app version>/
SKILLS_WORKSPACE_DIR = "/Workspace/.assistant/skills"

# Ingest attempt window: a failed ingest is retried after each of these waits, and the attempt after
# the last wait is final (5 attempts over about 81 minutes, then results_invalid).
INGEST_RETRY_WAITS = (timedelta(minutes=1), timedelta(minutes=5), timedelta(minutes=15), timedelta(minutes=60))
INGEST_MAX_ATTEMPTS = len(INGEST_RETRY_WAITS) + 1

# assessment.json contract versions the app ingests (``x-schema-version`` in the vendored
# assessment.schema.json, copied by the notebook to summary.json ``schema_version``). Policy: on a
# bump to N, keep N-1 here for one release, then drop it. Anything else is refused as results_invalid.
SUPPORTED_SCHEMA_VERSIONS = frozenset({1})


class AssessStatus(str, Enum):
    queued = "queued"
    starting = "starting"
    assessing = "assessing"
    rate_limited = "rate_limited"
    completed = "completed"
    results_invalid = "results_invalid"
    failed = "failed"
    cancelled = "cancelled"


TERMINAL_STATUSES = frozenset({"completed", "results_invalid", "failed", "cancelled"})


def domain_segment(name: str) -> str:
    seg = re.sub(r"[^A-Za-z0-9_-]", "_", name or "")
    return seg or "_"


def runs_root(deployment_catalog: str) -> str:
    return f"/Volumes/{deployment_catalog}/_metamodel/{RUNS_VOLUME}"


def domain_out_dir(deployment_catalog: str, batch_id: str, domain_name: str) -> str:
    return f"{runs_root(deployment_catalog)}/{batch_id}/{domain_segment(domain_name)}"
