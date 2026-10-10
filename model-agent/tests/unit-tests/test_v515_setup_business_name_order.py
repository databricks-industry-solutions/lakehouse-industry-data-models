"""v5.1.5: step_setup_and_clean must store the business name before the base-conventions lookup and the
schema-ownership gate (decision 12A) read it.

Live run 222415511766934 (R2, unscoped 'vibe modeling of version' of vs514 retail v1) failed in setup:
"SCHEMA OWNERSHIP CLASH ... for business '' would deploy into 4 existing schema(s) that this business
does not own ... the ownership read failed (the business name or the _metamodel tables are not
configured)". step_setup_and_clean called _early_clash_detection before it stored
widgets_values["business_name"], so _schema_ownership_snapshot read ownership for business '' and
refused the business's own schemas. Every VOV / shrink / enlarge into an existing catalog failed. The
same gap made the 7A base-conventions lookup miss the base model.json (no business name to build its path)
and fall back to the _metamodel.business row, whose timestamp_format had lost its quotes.
"""
import sys
from pathlib import Path

import pytest

sys.path.insert(0, str(Path(__file__).resolve().parent))
import conftest  # noqa: F401,E402
import agent_helpers as ah  # noqa: E402
import test_v514_schema_ownership_teardown as own  # noqa: E402
from notebook_source_util import notebook_concat_source, slice_function_source  # noqa: E402


def _setup_body():
    return slice_function_source("step_setup_and_clean", source=notebook_concat_source())


def test_the_business_name_is_stored_before_any_setup_reader_needs_it():
    body = _setup_body()
    store = body.index('widgets_values["business_name"] = business_name')
    assert store < body.index("business_name = business_name_raw.strip().title()") + 200, "store it right where it is derived"
    for reader in ("_resolve_base_model_json(widgets_values, None, base_version=_vov_cv_ver",
                   "_early_clash_detection(spark, config, widgets_values, logger)"):
        assert store < body.index(reader), f"{reader.split('(')[0]} runs before widgets_values carries the business name"


def test_without_the_business_name_the_gate_refuses_the_business_own_schemas():
    spark = own._spark(own.ALL_SCHEMAS, *own._history())
    wv = own._vov_wv(pins=("crew", "flight"))
    wv.pop("business_name")
    with pytest.raises(ValueError, match="SCHEMA OWNERSHIP CLASH"):
        ah._early_clash_detection(spark, own._config(), wv, own._Log())
    assert spark.drops() == []


def test_with_the_business_name_the_same_vov_tears_down_only_its_own_schemas():
    spark = own._spark(own.ALL_SCHEMAS, *own._stale_history())
    ah._early_clash_detection(spark, own._config(), own._vov_wv(pins=("crew", "flight")), own._Log())
    assert {d.split("`.`")[1].split("`")[0] for d in spark.drops() if d.startswith("DROP SCHEMA")} == {"crew", "flight"}
