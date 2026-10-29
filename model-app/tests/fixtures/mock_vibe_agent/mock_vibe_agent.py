# Databricks notebook source
# MAGIC %md
# MAGIC # Mock Vibe Modelling Agent
# MAGIC
# MAGIC A drop-in replacement for the real `vibe-modelling-agent` notebook for
# MAGIC **testing only**. Produces the same Delta progress event sequence and
# MAGIC model.json output shape as the real v0.5.x agent, but completes in
# MAGIC ~30 seconds instead of hours.
# MAGIC
# MAGIC Useful for:
# MAGIC - Exercising the app's full vibe run lifecycle (launch, poll, handshake, sync) end-to-end
# MAGIC - Testing resume-after-restart and failure paths
# MAGIC - Integration tests that can't afford to run the real agent
# MAGIC
# MAGIC ## Contract
# MAGIC
# MAGIC Matches the v0.5.x integration contract exactly:
# MAGIC - `_business` and `_vibe_progress` Delta tables under `<metamodel_catalog>.<metamodel_schema>`
# MAGIC - Session handshake via `session_id` (BIGINT) derived from `vibe_session_id` widget
# MAGIC - 20 ordered `(stage_name, step_name)` events ending in `Vibe Session` / `Session Ended`
# MAGIC - `model.json` written to `<TARGET_VOLUME>/model.json`
# MAGIC
# MAGIC ## Mock control widgets
# MAGIC
# MAGIC In addition to the standard 28 widgets, this mock reads:
# MAGIC - `mock_mode` = `success` | `failure_at_stage_<N>` | `long_failure`
# MAGIC - `mock_event_delay_seconds` = `0.5` (default)

# COMMAND ----------

# MAGIC %md ## Widgets

# COMMAND ----------

dbutils.widgets.text("business_name", "", "01 Business Name")
dbutils.widgets.text("business_description", "", "02 Business Description")
dbutils.widgets.dropdown("operation", "new base model", [
    "new base model", "vibe modeling of version", "shrink ecm", "enlarge mvm",
    "install model", "uninstall model version", "generate sample data",
], "03 Operation")
dbutils.widgets.dropdown("model_version", "", [""] + [str(i) for i in range(1, 101)], "04 Model Version")
dbutils.widgets.dropdown("data_model_scopes", "Minimum Viable Model - MVM", [
    "Minimum Viable Model - MVM", "Expanded Coverage Model - ECM",
], "05 Data Model Scopes")
dbutils.widgets.text("business_domains", "", "06 Business Domains")
dbutils.widgets.dropdown("org_divisions", "Operations and Business", [
    "Operations", "Operations and Business", "Operations, Business and Corporate",
], "07 Org Divisions")
dbutils.widgets.text("model_vibes", "", "08 Model Vibes")
dbutils.widgets.text("deployment_catalog", "", "09 Deployment Catalog")
dbutils.widgets.dropdown("cataloging_style", "One Catalog", [
    "One Catalog", "Catalog per Division", "Catalog per Domain",
], "09a Cataloging Style")
dbutils.widgets.text("catalog_prefix", "", "09b Catalog Prefix")
dbutils.widgets.text("catalog_suffix", "", "09c Catalog Suffix")
dbutils.widgets.text("context_file", "", "11 Context File")
dbutils.widgets.dropdown("naming_convention", "snake_case", [
    "snake_case", "camelCase", "PascalCase", "SCREAMING_CASE",
], "12 Naming Convention")
dbutils.widgets.text("primary_key_suffix", "_id", "13 Primary Key Suffix")
dbutils.widgets.text("schema_prefix", "", "15 Schema Prefix")
dbutils.widgets.text("schema_suffix", "", "15a Schema Suffix")
dbutils.widgets.text("tag_prefix", "dbx_", "16 Tag Prefix")
dbutils.widgets.text("tag_suffix", "", "16a Tag Suffix")
dbutils.widgets.dropdown("table_id_type", "BIGINT", ["BIGINT", "INT", "LONG", "STRING"], "17 Table ID Type")
dbutils.widgets.dropdown("boolean_format", "Boolean (True/False)", [
    "Boolean (True/False)", "Int (0/1)", "String (Y/N)",
], "18 Boolean Format")
dbutils.widgets.dropdown("date_format", "yyyy-MM-dd", [
    "yyyy-MM-dd", "dd/MM/yyyy", "MM/dd/yyyy", "yyyy/MM/dd", "dd-MM-yyyy",
], "19 Date Format")
dbutils.widgets.dropdown("timestamp_format", "yyyy-MM-dd'T'HH:mm:ss.SSSXXX", [
    "yyyy-MM-dd'T'HH:mm:ss.SSSXXX",
    "yyyy-MM-dd HH:mm:ss",
    "yyyy-MM-dd'T'HH:mm:ss",
    "yyyy-MM-dd HH:mm:ss.SSS",
], "20 Timestamp Format")
dbutils.widgets.text(
    "classification_levels",
    "restricted=restricted, confidential=confidential, internal=Internal, public=public",
    "21 Classification Levels",
)
dbutils.widgets.dropdown("housekeeping_columns", "No", ["No", "Yes"], "22 Housekeeping Columns")
dbutils.widgets.dropdown("history_tracking_columns", "No", ["No", "Yes"], "23 History Tracking Columns")
dbutils.widgets.text("vibe_session_id", "", "24 Vibe Session ID")

# Mock-only control widgets
dbutils.widgets.dropdown("mock_mode", "success", [
    "success", "failure_at_stage_3", "failure_at_stage_12", "long_failure",
], "90 Mock Mode")
dbutils.widgets.text("mock_event_delay_seconds", "0.5", "91 Mock Event Delay (s)")

# COMMAND ----------

# MAGIC %md ## Read widgets + resolve metamodel location

# COMMAND ----------

import hashlib
import json
import time
from datetime import datetime, timezone
from pathlib import PurePosixPath

# Standard 28 widgets
W = {
    "business_name": dbutils.widgets.get("business_name"),
    "business_description": dbutils.widgets.get("business_description"),
    "operation": dbutils.widgets.get("operation"),
    "model_version": dbutils.widgets.get("model_version") or "1",
    "data_model_scopes": dbutils.widgets.get("data_model_scopes"),
    "business_domains": dbutils.widgets.get("business_domains"),
    "org_divisions": dbutils.widgets.get("org_divisions"),
    "model_vibes": dbutils.widgets.get("model_vibes"),
    "deployment_catalog": dbutils.widgets.get("deployment_catalog"),
    "cataloging_style": dbutils.widgets.get("cataloging_style"),
    "catalog_prefix": dbutils.widgets.get("catalog_prefix"),
    "catalog_suffix": dbutils.widgets.get("catalog_suffix"),
    "context_file": dbutils.widgets.get("context_file"),
    "naming_convention": dbutils.widgets.get("naming_convention"),
    "primary_key_suffix": dbutils.widgets.get("primary_key_suffix"),
    "schema_prefix": dbutils.widgets.get("schema_prefix"),
    "schema_suffix": dbutils.widgets.get("schema_suffix"),
    "tag_prefix": dbutils.widgets.get("tag_prefix"),
    "tag_suffix": dbutils.widgets.get("tag_suffix"),
    "table_id_type": dbutils.widgets.get("table_id_type"),
    "boolean_format": dbutils.widgets.get("boolean_format"),
    "date_format": dbutils.widgets.get("date_format"),
    "timestamp_format": dbutils.widgets.get("timestamp_format"),
    "classification_levels": dbutils.widgets.get("classification_levels"),
    "housekeeping_columns": dbutils.widgets.get("housekeeping_columns"),
    "history_tracking_columns": dbutils.widgets.get("history_tracking_columns"),
    "vibe_session_id": dbutils.widgets.get("vibe_session_id"),
}
MOCK_MODE = dbutils.widgets.get("mock_mode")
EVENT_DELAY = float(dbutils.widgets.get("mock_event_delay_seconds") or 0.5)

# Derive metamodel catalog.schema (matching the real agent's convention —
# the app's AgentConfig.deployment_catalog drives this). Fallback to a default.
METAMODEL_CATALOG = W["deployment_catalog"] or "vibe_modeling_metamodel"
METAMODEL_SCHEMA = "_metamodel"
BUSINESS_TABLE = f"{METAMODEL_CATALOG}.{METAMODEL_SCHEMA}._business"
PROGRESS_TABLE = f"{METAMODEL_CATALOG}.{METAMODEL_SCHEMA}._vibe_progress"

# session_id derivation matches the real agent (hash of the UUID string)
if W["vibe_session_id"]:
    SESSION_ID = int(
        hashlib.sha256(W["vibe_session_id"].encode()).hexdigest(), 16
    ) & 0x7FFFFFFFFFFFFFFF
else:
    SESSION_ID = int(time.time() * 1000)

# Derive the Volume root matching the real agent
_sanitized = "".join(c if c.isalnum() else "_" for c in W["business_name"]).lower()
_scope_abbr = "mvm" if "MVM" in W["data_model_scopes"] else "ecm"
TARGET_VOLUME = (
    f"/Volumes/{METAMODEL_CATALOG}/{METAMODEL_SCHEMA}/vol_root"
    f"/business/{_sanitized}/v{W['model_version']}_{_scope_abbr}"
)

print(f"Mock agent running in mode: {MOCK_MODE}")
print(f"Session ID: {SESSION_ID}")
print(f"Business: {W['business_name']!r} v{W['model_version']} ({_scope_abbr})")
print(f"Metamodel: {METAMODEL_CATALOG}.{METAMODEL_SCHEMA}")
print(f"Target volume: {TARGET_VOLUME}")

# COMMAND ----------

# MAGIC %md ## Verify schema + tables exist (DO NOT create)
# MAGIC
# MAGIC The mock is a **test double**, not an installer. It assumes the
# MAGIC metamodel schema, `_business`, `_vibe_progress`, and the volume
# MAGIC already exist on the target workspace. If they don't, fail loudly
# MAGIC and point at the setup required.
# MAGIC
# MAGIC One-time setup (per-workspace, done manually or by the real agent's
# MAGIC first real run):
# MAGIC ```sql
# MAGIC CREATE SCHEMA IF NOT EXISTS {catalog}._metamodel;
# MAGIC CREATE TABLE ... _business (...);
# MAGIC CREATE TABLE ... _vibe_progress (...);
# MAGIC CREATE VOLUME ... vol_root;
# MAGIC ```

# COMMAND ----------

def _assert_exists(fqn: str, kind: str):
    """Fail with a clear message if the required infrastructure isn't set up."""
    try:
        spark.sql(f"DESCRIBE {kind} {fqn}")
    except Exception as e:
        raise RuntimeError(
            f"Mock agent requires {kind} {fqn!r} to already exist. "
            f"Set it up once per workspace (or run the real agent first). "
            f"Original error: {e}"
        ) from e

_assert_exists(BUSINESS_TABLE, "TABLE")
_assert_exists(PROGRESS_TABLE, "TABLE")
_assert_exists(f"{METAMODEL_CATALOG}.{METAMODEL_SCHEMA}.vol_root", "VOLUME")

# COMMAND ----------

# MAGIC %md ## Write handshake row

# COMMAND ----------

# Insert the pending row then flip to 'done' — mirrors the real agent
spark.sql(f"""
  INSERT INTO {BUSINESS_TABLE} (
    business, version, model_scope, session_id, processing_status,
    completed_percent, session_started_at, last_updated_at,
    session_json, results_json
  ) VALUES (
    '{W["business_name"]}', '{W["model_version"]}', '{W["data_model_scopes"]}',
    {SESSION_ID}, 'pending', 0.0,
    current_timestamp(), current_timestamp(),
    '{{}}', NULL
  )
""")

# Immediately flip to done
spark.sql(f"""
  UPDATE {BUSINESS_TABLE}
  SET processing_status = 'done', last_updated_at = current_timestamp()
  WHERE session_id = {SESSION_ID}
""")

# COMMAND ----------

# MAGIC %md ## Emit progress events

# COMMAND ----------

# Ordered (stage_name, step_name, status, progress_increment) matching the
# real agent v0.5.x integration guide §4. The mock emits each event with a
# small delay so the app's UI shows live progress.
EVENTS = [
    ("Vibe Session", "Session Started", "stage_started", 0.0),
    ("Setup and Configuration", "Pipeline Initialization", "stage_started", 0.0),
    ("Setup and Configuration", "Pipeline Initialization", "stage_succeeded", 1.0),
    ("Collecting Business Context", "Business Context Generation", "stage_started", 0.0),
    ("Collecting Business Context", "Business Context Generation", "stage_succeeded", 1.0),
    ("Designing Domains", "Domain Generation", "stage_started", 0.0),
    ("Designing Domains", "Domain Generation", "stage_succeeded", 2.0),
    ("Creating Data Products", "Product Generation", "stage_started", 0.0),
    ("Creating Data Products", "Product Generation", "stage_succeeded", 5.0),
    ("Enriching Data Products with Attributes", "Attribute Generation", "stage_started", 0.0),
    ("Enriching Data Products with Attributes", "Attribute Generation", "stage_succeeded", 25.0),
    ("Cross-Domain Linking", "FK Linking", "stage_started", 0.0),
    ("Cross-Domain Linking", "FK Linking", "stage_succeeded", 8.0),
    ("Quality Assurance", "Model QA Checks", "stage_started", 0.0),
    ("Quality Assurance", "Model QA Checks", "stage_succeeded", 5.0),
    ("Applying Naming Conventions", "Naming Conventions", "stage_started", 0.0),
    ("Applying Naming Conventions", "Naming Conventions", "stage_succeeded", 1.0),
    ("Model Finalization", "Finalize Model", "stage_started", 0.0),
    ("Model Finalization", "Finalize Model", "stage_succeeded", 1.0),
    ("Subdomain Allocation", "Allocate Subdomains", "stage_started", 0.0),
    ("Subdomain Allocation", "Allocate Subdomains", "stage_succeeded", 1.0),
    ("Physical Schema Construction", "Creating Databases and Tables", "stage_started", 0.0),
    ("Physical Schema Construction", "Creating Databases and Tables", "stage_succeeded", 10.0),
    ("Applying Foreign Keys", "FK Constraints", "stage_started", 0.0),
    ("Applying Foreign Keys", "FK Constraints", "stage_succeeded", 3.0),
    ("Applying Tags", "Tag Application Complete", "stage_started", 0.0),
    ("Applying Tags", "Tag Application Complete", "stage_succeeded", 18.0),
    ("Applying Metric Views", "Metric View Creation", "stage_started", 0.0),
    ("Applying Metric Views", "Metric View Creation", "stage_succeeded", 2.0),
    ("Generating Sample Data", "Sample Generation Complete", "stage_started", 0.0),
    ("Generating Sample Data", "Sample Generation Complete", "stage_succeeded", 8.0),
    ("Generating Artifacts", "Generating Artifacts", "stage_started", 0.0),
    ("Generating Artifacts", "Generating Artifacts", "stage_succeeded", 5.0),
    ("Consolidation and Cleanup", "Consolidate and Cleanup", "stage_started", 0.0),
    ("Consolidation and Cleanup", "Consolidate and Cleanup", "stage_succeeded", 2.0),
    ("Generating Metric View Artifacts", "Metric View Artifacts", "stage_started", 0.0),
    ("Generating Metric View Artifacts", "Metric View Artifacts", "stage_succeeded", 1.0),
]

step_id = 0
event_seq = 0
cumulative_percent = 0.0

def emit(stage: str, step: str, status: str, increment: float, message: str = ""):
    global step_id, event_seq, cumulative_percent
    step_id += 1
    event_seq += 1
    cumulative_percent += increment
    spark.sql(f"""
      INSERT INTO {PROGRESS_TABLE} (
        session_id, step_id, last_updated, stage_name, step_name,
        attempt_number, progress_increment, message, status, event_seq, result_json
      ) VALUES (
        {SESSION_ID}, {step_id}, current_timestamp(),
        '{stage}', '{step}', 1, {increment},
        '{message.replace("'", "''")}', '{status}', {event_seq}, '{{}}'
      )
    """)
    spark.sql(f"""
      UPDATE {BUSINESS_TABLE}
      SET completed_percent = {cumulative_percent},
          last_updated_at = current_timestamp()
      WHERE session_id = {SESSION_ID}
    """)


# Failure stage parsing
fail_at_stage = None
if MOCK_MODE.startswith("failure_at_stage_"):
    try:
        fail_at_stage = int(MOCK_MODE.split("_")[-1])
    except ValueError:
        fail_at_stage = None

stage_counter = 0
for stage, step, status, increment in EVENTS:
    time.sleep(EVENT_DELAY)

    # Count distinct stages to honour failure_at_stage_<N>
    if status == "stage_started":
        stage_counter += 1

    if fail_at_stage is not None and stage_counter == fail_at_stage and status == "stage_started":
        emit(stage, step, "stage_failed",
             0.0, message=f"Mock failure injected at stage {fail_at_stage}")
        spark.sql(f"""
          UPDATE {BUSINESS_TABLE}
          SET processing_status = 'error',
              results_json = '{{"status":"pipeline_error","error":"Mock failure at stage {fail_at_stage}"}}',
              completion_date = current_timestamp(),
              last_updated_at = current_timestamp()
          WHERE session_id = {SESSION_ID}
        """)
        raise RuntimeError(f"Mock failure at stage {fail_at_stage}")

    emit(stage, step, status, increment)

if MOCK_MODE == "long_failure":
    # Sleep long enough for the app to detect staleness, then fail
    time.sleep(max(60.0, EVENT_DELAY * 120))
    emit("Generating Artifacts", "Generating Artifacts", "stage_failed", 0.0,
         message="Mock long-running failure")
    spark.sql(f"""
      UPDATE {BUSINESS_TABLE}
      SET processing_status = 'error',
          results_json = '{{"status":"pipeline_error","error":"Mock long failure"}}'
      WHERE session_id = {SESSION_ID}
    """)
    raise RuntimeError("Mock long failure")

# COMMAND ----------

# MAGIC %md ## Write canned model.json + finalize

# COMMAND ----------

# Canned model.json — matches the v0.5.x schema. Two domains, a few products
# each, a couple FK links. Writes via Volume Files API (the real agent uses
# the same mechanism).
import os

CANNED_MODEL = {
    "model_requirements": {k: v for k, v in W.items() if k != "model_vibes"},
    "_vibe_session_metadata": {
        "generated_from_version": "",
        "target_model_version": f"v{W['model_version']}_{_scope_abbr}",
        "start_time": datetime.now(timezone.utc).isoformat(),
        "end_time": datetime.now(timezone.utc).isoformat(),
        "duration_hours": 0.01,
        "status": "success",
        "confidence_score": 0.95,
        "summary": "Mock agent run — canned model for testing",
        "model_stats_at_generation": {
            "domain_count": 2, "product_count": 4,
            "attribute_count": 10, "fk_count": 2,
            "unlinked_id_count": 0, "siloed_count": 0,
            "llm_fk_skip_count": 0,
        },
        "version_history": [],
        "ai_usage": {},
    },
    "model": {
        "type": "business",
        "name": W["business_name"] or "mock_business",
        "version": f"v{W['model_version']}_{_scope_abbr}",
        "description": W["business_description"] or "Mock business for testing",
        "industry_alignment": "",
        "location": "",
        "core_business_processes": "",
        "orgnaization_divisions": W["org_divisions"],
        "data_domains": "",
        "common_business_jargons": "",
        "operational_systems_of_records": "",
        "industry_governing_body": "",
        "model_conventions": {
            "data_asset_naming_convention": W["naming_convention"],
            "primary_key_suffix": W["primary_key_suffix"],
            "schema_prefix": W["schema_prefix"],
            "schema_suffix": W["schema_suffix"],
            "tag_prefix": W["tag_prefix"],
            "tag_suffix": W["tag_suffix"],
            "table_id_type": W["table_id_type"],
            "boolean_format": W["boolean_format"],
            "date_format": W["date_format"],
            "timestamp_format": W["timestamp_format"],
            "data_classification_levels": W["classification_levels"],
            "housekeeping_columns": W["housekeeping_columns"],
            "history_tracking_columns": W["history_tracking_columns"],
        },
        "domains": [
            {
                "name": "sales",
                "division": "Business",
                "description": "Sales domain — customers, orders, products",
                "database_name": "sales",
                "products": [
                    {
                        "name": "customers",
                        "table_name": "customers",
                        "primary_key": "customer_id",
                        "description": "Customers table",
                        "type": "reference",
                        "attributes": [
                            {"name": "customer_id", "column_name": "customer_id",
                             "type": "BIGINT", "description": "PK"},
                            {"name": "customer_name", "column_name": "customer_name",
                             "type": "STRING", "description": "Name"},
                            {"name": "customer_email", "column_name": "customer_email",
                             "type": "STRING", "description": "Email"},
                        ],
                    },
                    {
                        "name": "orders",
                        "table_name": "orders",
                        "primary_key": "order_id",
                        "description": "Orders table",
                        "type": "transaction",
                        "attributes": [
                            {"name": "order_id", "column_name": "order_id",
                             "type": "BIGINT", "description": "PK"},
                            {"name": "customer_id", "column_name": "customer_id",
                             "type": "BIGINT", "description": "FK to customers",
                             "foreign_key_to": "sales.customers.customer_id"},
                            {"name": "total_amount", "column_name": "total_amount",
                             "type": "DECIMAL(18,2)", "description": "Total"},
                        ],
                    },
                ],
            },
            {
                "name": "inventory",
                "division": "Operations",
                "description": "Inventory domain — products and stock",
                "database_name": "inventory",
                "products": [
                    {
                        "name": "products",
                        "table_name": "products",
                        "primary_key": "product_id",
                        "description": "Product catalog",
                        "type": "reference",
                        "attributes": [
                            {"name": "product_id", "column_name": "product_id",
                             "type": "BIGINT", "description": "PK"},
                            {"name": "product_name", "column_name": "product_name",
                             "type": "STRING", "description": "Name"},
                        ],
                    },
                    {
                        "name": "stock_levels",
                        "table_name": "stock_levels",
                        "primary_key": "stock_id",
                        "description": "Current stock levels",
                        "type": "transaction",
                        "attributes": [
                            {"name": "stock_id", "column_name": "stock_id",
                             "type": "BIGINT", "description": "PK"},
                            {"name": "product_id", "column_name": "product_id",
                             "type": "BIGINT", "description": "FK to products",
                             "foreign_key_to": "inventory.products.product_id"},
                        ],
                    },
                ],
            },
        ],
        "metric_views": {},
    },
}

# Write to Volume — the real agent uses dbutils.fs or the Files API
# The Volume was created above; write the file
model_json_path = f"{TARGET_VOLUME}/model.json"
# Use dbutils.fs.put for Volume writes (Volume paths are compatible)
dbutils.fs.put(
    model_json_path,
    json.dumps(CANNED_MODEL, indent=2),
    overwrite=True,
)

print(f"Wrote canned model.json to {model_json_path}")

# COMMAND ----------

# MAGIC %md ## Closing bookend

# COMMAND ----------

emit("Vibe Session", "Session Ended", "stage_ended", 1.0,
     message=f"Mock run complete: 2 domains, 4 products, 10 attributes, 2 FKs")

# Final status flip
spark.sql(f"""
  UPDATE {BUSINESS_TABLE}
  SET processing_status = 'ready',
      completed_percent = 100.0,
      completion_date = current_timestamp(),
      last_updated_at = current_timestamp(),
      results_json = '{{"status":"success","domain_count":2,"product_count":4,"attribute_count":10,"fk_count":2}}'
  WHERE session_id = {SESSION_ID}
""")

print("Mock run complete.")

# COMMAND ----------

# Return a summary for job output
dbutils.notebook.exit(json.dumps({
    "status": "success",
    "session_id": SESSION_ID,
    "mode": MOCK_MODE,
    "volume_path": TARGET_VOLUME,
    "domain_count": 2,
    "product_count": 4,
    "attribute_count": 10,
    "fk_count": 2,
}))
