"""Pydantic shapes for the Domain Taxonomy Builder (/api/taxonomy/*).

Names carry a ``Taxonomy`` prefix so the generated OpenAPI client has no
collisions with existing models.
"""

from __future__ import annotations

from datetime import datetime
from typing import Literal, Optional

from pydantic import BaseModel, Field, field_validator

from ..models import BUSINESS_NAME_PATTERN, OrgDivisions
from .slots import DEFAULT_CAPACITY, MAX_CAPACITY, MIN_CAPACITY

SECTION_KEYS: tuple[str, ...] = (
    "company", "channels", "processes", "terminology", "systems_of_record", "regulatory",
)
SECTION_HEADINGS: dict[str, str] = {
    "company": "Company and segments",
    "channels": "Channels and customer touchpoints",
    "processes": "Core business processes",
    "terminology": "Industry terminology",
    "systems_of_record": "Systems of record",
    "regulatory": "Regulatory and compliance",
}
PART_TREE = "tree"
PART_DESCRIPTION = "description"

Provenance = Literal["user", "industry", "confirm"]
Strictness = Literal["strict", "guided"]
# ``busy``: no free LLM slot, or the gateway rate-limited the call. Terminal for
# polling; the client retries the part on its own countdown.
PartStatus = Literal["pending", "running", "done", "failed", "cancelled", "timed_out", "busy"]
DraftStatus = Literal["running", "done", "failed", "cancelled", "timed_out", "busy"]
# Outcome of a model-service test call (TaxonomyLLM.probe).
ProbeStatus = Literal["ok", "denied", "not_found", "busy", "error"]


class TaxonomyIntake(BaseModel):
    company_name: str = Field(min_length=1, max_length=128, pattern=BUSINESS_NAME_PATTERN)
    industry: str = Field(min_length=1, max_length=200)
    one_liner: str = Field(default="", max_length=500)
    known_domains: str = Field(default="", max_length=4000)
    key_systems: str = Field(default="", max_length=4000)
    regulators: str = Field(default="", max_length=4000)
    pasted_doc: str = Field(default="", max_length=60000)


class TaxonomySubdomain(BaseModel):
    name: str = Field(min_length=1)
    categories: list[str] = Field(default_factory=list)


class TaxonomyDomain(BaseModel):
    name: str = Field(min_length=1)
    # Blank = derive with snake(name). Users may override in the editor.
    schema_name: str = ""
    subdomains: list[TaxonomySubdomain] = Field(default_factory=list)


class TaxonomySharedMaster(BaseModel):
    entity: str = Field(min_length=1)  # snake entity name, e.g. "customer_account"
    home_domain: str = Field(min_length=1)  # a domain schema name


class TaxonomyRelationship(BaseModel):
    source: str = Field(min_length=1)
    targets: list[str] = Field(min_length=1)


class TaxonomyTree(BaseModel):
    domains: list[TaxonomyDomain] = Field(min_length=1)
    shared_masters: list[TaxonomySharedMaster] = Field(default_factory=list)
    relationships: list[TaxonomyRelationship] = Field(default_factory=list)
    division_names: list[str] = Field(default_factory=list)
    coverage: OrgDivisions = "Operations, Business and Corporate"


class TaxonomyClaim(BaseModel):
    text: str = Field(min_length=1)
    provenance: Provenance


class TaxonomySection(BaseModel):
    claims: list[TaxonomyClaim] = Field(min_length=1)


def _known_sections(value: dict[str, "TaxonomySection"]) -> dict[str, "TaxonomySection"]:
    unknown = sorted(set(value) - set(SECTION_KEYS))
    if unknown:
        raise ValueError(f"unknown section keys: {', '.join(unknown)}")
    return value


class TaxonomyDraftCreateIn(TaxonomyIntake):
    """A draft request. ``seed_tree`` and ``seed_sections`` are parts the user
    already has (Draft again after a lost draft, or a resumed wizard): they
    start ``done`` without a model call, and only the missing parts are
    drafted."""

    seed_tree: TaxonomyTree | None = None
    seed_sections: dict[str, TaxonomySection] = Field(default_factory=dict)

    _check_seed_sections = field_validator("seed_sections")(_known_sections)

    def fully_seeded(self) -> bool:
        return self.seed_tree is not None and set(SECTION_KEYS) <= set(self.seed_sections)

    def intake(self) -> TaxonomyIntake:
        return TaxonomyIntake.model_validate(self.model_dump(include=set(TaxonomyIntake.model_fields)))


class TaxonomyDraftPartOut(BaseModel):
    status: PartStatus
    error: str | None = None
    tree: TaxonomyTree | None = None
    section: TaxonomySection | None = None
    description: str | None = None


class TaxonomyDraftOut(BaseModel):
    draft_id: str
    status: DraftStatus
    # keys: "tree", each SECTION_KEYS entry, and/or "description"
    parts: dict[str, TaxonomyDraftPartOut]


class TaxonomyDraftCreated(BaseModel):
    draft_id: str


class TaxonomyCompileIn(BaseModel):
    tree: TaxonomyTree
    strictness: Strictness = "strict"
    sections: dict[str, TaxonomySection] = Field(default_factory=dict)


class TaxonomyIssue(BaseModel):
    severity: Literal["error", "warning"]
    message: str
    # The agent rule (DOM-RUL-NNN) behind the issue; "" for builder-only checks.
    rule_id: str = ""
    # Indices into tree.domains the issue belongs to; [] = model-level.
    domains: list[int] = Field(default_factory=list)


class TaxonomyCompileOut(BaseModel):
    clamp: str
    business_vibes: str
    business_domains: str  # comma+space separated schema names, tree order
    csv: str
    issues: list[TaxonomyIssue]


class TaxonomyCondenseIn(BaseModel):
    intake: TaxonomyIntake
    tree: TaxonomyTree
    sections: dict[str, TaxonomySection]


class TaxonomyExampleOut(BaseModel):
    company_name: str
    industry: str
    tree: TaxonomyTree
    sections: dict[str, TaxonomySection]
    description: str


# --- Saved wizard: /taxonomy/saved ----------------------------------------

WIZARD_LAST_STEP = 3


class TaxonomyWizardStateIn(BaseModel):
    """The whole wizard document, saved on every change. ``revision`` is the
    revision this tab last loaded or saved (0 when nothing is saved yet); a
    save from an older revision answers 409 ``stale_revision``. ``tree`` and
    ``sections`` hold only finished parts: the client sends the sanitized
    editor state, and nothing for a part still drafting."""

    revision: int = Field(ge=0)
    step: int = Field(ge=0, le=WIZARD_LAST_STEP)
    sector_id: Optional[str] = None
    strictness: Strictness = "strict"
    intake: TaxonomyIntake
    tree: TaxonomyTree | None = None
    sections: dict[str, TaxonomySection] = Field(default_factory=dict)

    _check_sections = field_validator("sections")(_known_sections)


class TaxonomyWizardStateOut(BaseModel):
    revision: int
    step: int
    sector_id: Optional[str] = None
    strictness: Strictness
    intake: TaxonomyIntake
    tree: TaxonomyTree | None = None
    sections: dict[str, TaxonomySection]
    updated_at: datetime
    expires_at: datetime


class TaxonomySavedWizardOut(BaseModel):
    """GET /taxonomy/saved: the caller's saved wizard, or ``saved = null``."""

    saved: TaxonomyWizardStateOut | None = None


class TaxonomyWizardDiscardOut(BaseModel):
    # False when there was nothing saved.
    discarded: bool


# --- Settings: /config/taxonomy -------------------------------------------


class TaxonomyCheckOut(BaseModel):
    """One model-service test call: ``ok`` saves; ``busy`` saves with a
    warning; the rest refuse."""

    status: ProbeStatus
    message: str
    checked_at: datetime


class TaxonomyConfigOut(BaseModel):
    installed: bool
    model_service: str
    install_default_model_service: str
    max_concurrency: int
    # Whether the wizard can be offered: installed, a model service is set,
    # and its last test call was not denied / not_found / error (never
    # checked and busy count as ready). Computed only by GET /config/taxonomy.
    ready: bool
    # Most recent test call for ``model_service`` in this app process.
    last_check: Optional[TaxonomyCheckOut] = None
    # Who last saved these settings and when (UTC); None until the first save.
    updated_by: Optional[str] = None
    updated_at: Optional[datetime] = None


class TaxonomyConfigIn(BaseModel):
    # ``""`` clears the setting (allowed only without an install default).
    model_service: str = Field(default="", max_length=800)
    max_concurrency: int = Field(DEFAULT_CAPACITY, ge=MIN_CAPACITY, le=MAX_CAPACITY)


class TaxonomyModelServicesOut(BaseModel):
    """Model services the app service principal can see, sorted, ``system.ai``
    last. Being listed does not prove EXECUTE; the test call does."""

    services: list[str]
    # Set when the list call failed (``services`` is then empty): Settings
    # falls back to free text.
    message: Optional[str] = None
