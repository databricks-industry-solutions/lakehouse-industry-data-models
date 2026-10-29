"""``services.schema_names``: the schema the agent writes for a stored
``database_name`` (agent 5.3.3).

* Generation stores the prefix in ``database_name`` (nb 81765-81782); a
  name that starts with the deploy prefix is kept.
* An install that sends another prefix makes the agent rebuild each name
  as ``prefix + apply_convention(domain name)`` (nb 106953, 107063, 107191).
* ``resolve_schema`` adds the deploy suffix only when missing (nb 7541-7560).
"""
from __future__ import annotations

import json

import pytest
from sqlmodel import Session

from vibe_modeling.backend.db_models import Business, Domain, ModelVersion, Run, RunOperation
from vibe_modeling.backend.services.schema_names import (
    agent_snake_case,
    domain_schema_name,
    install_schema_names,
    physical_schema_name,
    pick_affix,
    recorded_schema_names,
)


@pytest.mark.parametrize("stored, prefix, suffix, domain, expected", [
    ("ecm_sales", "ecm_", "", None, "ecm_sales"),
    ("mvm_ecm_sales", "mvm_", "", None, "mvm_ecm_sales"),
    ("sales", "ecm_", "", None, "ecm_sales"),
    ("ECM_Sales", "ecm_", "", None, "ecm_sales"),
    ("ecm_sales", "ecm_", "_wt", None, "ecm_sales_wt"),
    ("ecm_sales_wt", "ecm_", "_wt", None, "ecm_sales_wt"),
    ("acme_sales", "ecm_", "", "sales", "ecm_sales"),
    ("acme_sales", "ecm_", "", "Customer Service", "ecm_customer_service"),
    ("acme_sales", "ecm_", "", None, "ecm_acme_sales"),
    ("ecm_sales", "", "", None, "ecm_sales"),
    ("", "ecm_", "", None, ""),
    ("  ", "", "_wt", None, ""),
])
def test_physical_schema_name(stored, prefix, suffix, domain, expected):
    assert physical_schema_name(stored, prefix, suffix, domain_name=domain) == expected


@pytest.mark.parametrize("name, expected", [
    ("sales", "sales"),
    ("Customer Service", "customer_service"),
    ("CustomerService", "customer_service"),
    ("meter-to-cash", "meter_to_cash"),
    ("element_element_id", "element_id"),
    ("", ""),
])
def test_agent_snake_case(name, expected):
    assert agent_snake_case(name) == expected


def test_domain_schema_name_falls_back_to_the_domain_name():
    assert domain_schema_name("ecm_sales", "Sales") == "ecm_sales"
    assert domain_schema_name("", "Customer Service") == "customer_service"
    assert domain_schema_name(None, "Sales", suffix="_wt") == "sales_wt"


def test_install_schema_names_rebuilds_on_another_prefix(engine):
    with Session(engine) as s:
        b = Business(name="Acme", description="d")
        s.add(b)
        s.flush()
        mv = ModelVersion(business_id=b.id, version=1, scope="ecm", status="completed")
        s.add(mv)
        s.flush()
        s.add(Domain(version_id=mv.id, name="sales", database_name="acme_sales"))
        s.add(Domain(version_id=mv.id, name="orders", database_name="acme_orders"))
        s.commit()
        assert install_schema_names(s, mv.id, prefix="ecm_", suffix="") == {"ecm_sales", "ecm_orders"}
        assert install_schema_names(s, mv.id, prefix="acme_", suffix="_wt") == {
            "acme_sales_wt", "acme_orders_wt",
        }


@pytest.mark.parametrize("values, fallback, expected", [
    (["", "mvm_"], "ecm_", "mvm_"),
    (["mvm_", "mvm_v2_"], "ecm_", "mvm_v2_"),
    ([""], "mvm_", ""),
    ([], "mvm_", "mvm_"),
    ([], "", ""),
])
def test_pick_affix(values, fallback, expected):
    assert pick_affix(values, fallback) == expected


# Domain names of the agriculture industry model (lakehouse-industry-data-models
# data-models/agriculture/v1/mvm/model.json, model_conventions schema_prefix "")
# and of a 5.3.3 New Base Model (P0 business_3 wt_p0_grain_coop v1 mvm,
# schema_prefix "mvm_").
_AGRI = [("crop", "crop"), ("land", "land")]
_BASE = [("ecm_intake", "mvm_ecm_intake"), ("ecm_sales", "mvm_ecm_sales")]


def _version(s, *, domains, dispatched, scope="mvm", catalog="business_1", name="WT Kick",
             deployed=True, status="succeeded"):
    b = Business(name=name, description="d")
    s.add(b)
    s.flush()
    mv = ModelVersion(business_id=b.id, version=2, scope=scope, status="completed",
                      deployment_status="deployed" if deployed else "draft",
                      uc_catalog=catalog if deployed else None, files_catalog=catalog)
    s.add(mv)
    s.flush()
    for name, db in domains:
        s.add(Domain(version_id=mv.id, name=name, database_name=db))
    run = Run(business_id=b.id, intent="vibe-iterate", status="completed")
    s.add(run)
    s.flush()
    for i, (op, widgets) in enumerate(dispatched):
        s.add(RunOperation(
            run_id=run.id, step_index=i, operation_name=op, status=status,
            output_version_id=mv.id if op != "install" else None,
            parent_version_id=mv.id if op == "install" else None,
            dispatched_widgets_json=json.dumps(widgets),
        ))
    s.commit()
    return mv


# The vibe-iterate widgets of a kickstarted business (T2 run C,
# j8_dispatch_c.json notebook_params): One Catalog, blank prefix and suffix.
_KICK_VIBE = {"cataloging_style": "One Catalog", "deployment_catalog": "business_1",
              "schema_prefix": "", "schema_suffix": ""}


class TestRecordedSchemaNames:
    def test_an_unprefixed_deploy_holds_its_stored_names(self, engine):
        """E-12: deployed by a vibe with prefix "" and no install record, the
        version holds ``crop``; the scope-prefixed form is claimed too."""
        with Session(engine) as s:
            mv = _version(s, domains=_AGRI, dispatched=[("vibe_iterate", _KICK_VIBE)])
            names = recorded_schema_names(s, mv.id, "mvm", "business_1")
        assert names == {"crop", "land", "mvm_crop", "mvm_land"}

    def test_a_prefixed_deploy_is_unchanged(self, engine):
        with Session(engine) as s:
            mv = _version(s, domains=_BASE, dispatched=[
                ("generate_mvm", {"cataloging_style": "One Catalog", "schema_prefix": "mvm_"}),
            ])
            names = recorded_schema_names(s, mv.id, "mvm", "business_1")
        assert names == {"mvm_ecm_intake", "mvm_ecm_sales"}

    def test_mixed_dispatches_claim_every_form(self, engine):
        """A blank generation prefix and an ``mvm_`` install into another
        catalog: in this catalog the version is deployed, so it claims the
        stored and scope-prefixed forms; the other catalog's install is
        exact there."""
        with Session(engine) as s:
            mv = _version(s, domains=_AGRI, dispatched=[
                ("vibe_iterate", _KICK_VIBE),
                ("install", {"cataloging_style": "One Catalog", "deployment_catalog": "business_2",
                             "schema_prefix": "mvm_"}),
            ])
            here = recorded_schema_names(s, mv.id, "mvm", "business_1")
            there = recorded_schema_names(s, mv.id, "mvm", "business_2")
        assert here == {"crop", "land", "mvm_crop", "mvm_land"}
        assert there == {"mvm_crop", "mvm_land"}

    def test_an_unprefixed_install_record_is_exact(self, engine):
        with Session(engine) as s:
            mv = _version(s, domains=_AGRI, dispatched=[
                ("install", {"cataloging_style": "One Catalog", "deployment_catalog": "business_1",
                             "schema_prefix": ""}),
            ])
            names = recorded_schema_names(s, mv.id, "mvm", "business_1")
        assert names == {"crop", "land"}

    def test_no_dispatch_keeps_the_scope_default(self, engine):
        """An older version with a logical name and no recorded widgets."""
        with Session(engine) as s:
            mv = _version(s, domains=[("sales", "sales")], dispatched=[], scope="ecm")
            names = recorded_schema_names(s, mv.id, "ecm", "business_1")
        assert names == {"ecm_sales", "sales"}

    def test_a_failed_install_elsewhere_claims_nothing_here(self, engine):
        """T2 E-12: the downloaded Agriculture MVM (files in business_1, never
        deployed) had its ``mvm_`` install into business_2 fail (E-15). That
        failure does not make it own ``mvm_crop`` in business_1."""
        with Session(engine) as s:
            mv = _version(s, name="Agriculture", domains=_AGRI, deployed=False, dispatched=[
                ("install", {"cataloging_style": "One Catalog", "deployment_catalog": "business_2",
                             "schema_prefix": "mvm_"}),
            ], status="failed")
            assert recorded_schema_names(s, mv.id, "mvm", "business_1") == {"crop", "land"}
            assert recorded_schema_names(s, mv.id, "mvm", "business_2") == {"crop", "land"}

    def test_a_succeeded_install_elsewhere_claims_nothing_here(self, engine):
        with Session(engine) as s:
            mv = _version(s, name="Agriculture", domains=_AGRI, deployed=False, dispatched=[
                ("install", {"cataloging_style": "One Catalog", "deployment_catalog": "business_2",
                             "schema_prefix": "mvm_"}),
            ])
            assert recorded_schema_names(s, mv.id, "mvm", "business_1") == {"crop", "land"}
            assert recorded_schema_names(s, mv.id, "mvm", "business_2") == {"mvm_crop", "mvm_land"}

    def test_the_producing_ops_prefix_is_claimed_without_an_install(self, engine):
        with Session(engine) as s:
            mv = _version(s, name="WT Conv", domains=_BASE, deployed=False, dispatched=[
                ("generate_mvm", {"cataloging_style": "One Catalog", "schema_prefix": "mvm_"}),
            ])
            assert recorded_schema_names(s, mv.id, "mvm", "business_1") == {"mvm_ecm_intake", "mvm_ecm_sales"}

    def test_a_child_shrink_does_not_make_the_ecm_claim_mvm_names(self, engine):
        """T2 WT-Conv: its ECM (``ecm_inventory``) has a child shrink whose
        widgets carry ``mvm_``; the ECM still claims only ``ecm_*``."""
        ecm = [("inventory", "ecm_inventory"), ("sales", "ecm_sales")]
        with Session(engine) as s:
            ecm_v = _version(s, name="WT Conv", scope="ecm", domains=ecm, dispatched=[])
            mvm_v = ModelVersion(business_id=ecm_v.business_id, version=1, scope="mvm", status="completed",
                                 deployment_status="deployed", uc_catalog="business_1", files_catalog="business_1")
            s.add(mvm_v)
            run = Run(business_id=ecm_v.business_id, intent="new-base-model", status="completed")
            s.add(run)
            s.flush()
            s.add(RunOperation(
                run_id=run.id, step_index=1, operation_name="shrink_ecm", status="succeeded",
                parent_version_id=ecm_v.id, output_version_id=mvm_v.id,
                dispatched_widgets_json=json.dumps({"cataloging_style": "One Catalog", "schema_prefix": "mvm_"}),
            ))
            s.add(RunOperation(
                run_id=run.id, step_index=0, operation_name="generate_ecm", status="succeeded",
                output_version_id=ecm_v.id,
                dispatched_widgets_json=json.dumps({"cataloging_style": "One Catalog", "schema_prefix": "ecm_"}),
            ))
            s.commit()
            assert recorded_schema_names(s, ecm_v.id, "ecm", "business_1") == {"ecm_inventory", "ecm_sales"}
