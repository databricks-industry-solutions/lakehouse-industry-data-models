"""Industry catalog endpoints (`/api/industries/*`)."""

from __future__ import annotations

from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException
from sqlmodel import func, select

from ..._metadata import api_prefix
from ..core import Dependencies
from ..db_models import Business, Industry
from ..industry_resolve import industry_ambiguous_detail, industry_candidates
from ..models import IndustryIn, IndustryOut

router = APIRouter(prefix=api_prefix)


@router.get("/industries", response_model=list[IndustryOut], operation_id="listIndustries")
def list_industries(session: Dependencies.Session):
    """List all industries, alphabetical by name.

    Default to alphabetical because that's the convention every UI
    surface ends up wanting (dropdowns, the settings table, future
    pickers). The ``display_order`` column is kept for cases where a
    caller explicitly wants the curated order, but it's no longer the
    default sort key.
    """
    industries = session.exec(
        select(Industry).order_by(Industry.name)
    ).all()
    return industries


@router.post("/industries", response_model=IndustryOut, operation_id="createIndustry")
def create_industry(
    data: IndustryIn,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    """Create a new industry. An active industry whose ``name`` or
    ``short_name`` slug equals an active one's is refused (409): the
    resolver could match neither."""
    if data.is_active:
        taken = {
            i.id: i
            for text in (data.name, data.short_name)
            for i in industry_candidates(session, text)
        }
        if taken:
            detail = industry_ambiguous_detail(data.name, taken.values())
            names = ", ".join(f"'{i['name']}'" for i in detail["industries"])
            detail["error"] = "industry_slug_taken"
            detail["message"] = f"An active industry already has this name or short name: {names}."
            raise HTTPException(status_code=409, detail=detail)
    industry = Industry(
        name=data.name,
        short_name=data.short_name,
        description=data.description,
        notable_businesses=data.notable_businesses,
        display_order=data.display_order,
        is_active=data.is_active,
    )
    session.add(industry)
    session.commit()
    session.refresh(industry)
    return industry


@router.put(
    "/industries/{industry_id}",
    response_model=IndustryOut,
    operation_id="updateIndustry",
)
def update_industry(
    industry_id: str,
    data: IndustryIn,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    """Update an industry."""
    industry = session.get(Industry, industry_id)
    if not industry:
        raise HTTPException(status_code=404, detail="Industry not found")
    industry.name = data.name
    industry.short_name = data.short_name
    industry.description = data.description
    industry.notable_businesses = data.notable_businesses
    industry.display_order = data.display_order
    industry.is_active = data.is_active
    industry.is_auto_created = False  # Clear auto flag on manual update
    industry.updated_at = datetime.now(timezone.utc)
    session.add(industry)
    session.commit()
    session.refresh(industry)
    return industry


@router.delete(
    "/industries/{industry_id}",
    operation_id="deleteIndustry",
)
def delete_industry(
    industry_id: str,
    session: Dependencies.Session,
    _role: Dependencies.BusinessAdminOnly,
):
    """Delete an industry.

    Rejects with 409 ``industry_in_use`` if any Business currently
    references this Industry via ``industry_id``. The user is expected
    to reassign those businesses (or clear their ``industry_id``) first
    — the auto-created-on-mismatch path produced messy slugs that the
    user wants to clean up explicitly, not by cascading FK damage.
    """
    industry = session.get(Industry, industry_id)
    if not industry:
        raise HTTPException(status_code=404, detail="Industry not found")

    business_count = session.exec(
        select(func.count()).select_from(Business).where(
            Business.industry_id == industry_id
        )
    ).one()

    if business_count > 0:
        raise HTTPException(
            status_code=409,
            detail={
                "error": "industry_in_use",
                "industry_id": industry_id,
                "name": industry.name,
                "business_count": business_count,
                "message": (
                    f"Industry '{industry.name}' is used by "
                    f"{business_count} business(es); reassign those "
                    f"businesses first."
                ),
            },
        )

    session.delete(industry)
    session.commit()
    return {"ok": True}
