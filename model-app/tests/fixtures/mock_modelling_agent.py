# Databricks notebook source
"""Mock Modelling Agent — lightweight notebook implementing the monolith's Delta contract.

Implements the same widget interface and Delta table contract as
vibe_modelling_agent_v27.py but produces synthetic data in seconds.
Used as the integration test target.

Behavior by operation:
  - Model-producing (new base model, vibe modeling, shrink ecm, enlarge mvm):
    Write _business row, emit progress events, write canned model.json, handshake.
  - Lifecycle (install model, uninstall model version, generate sample data):
    No-op success.
  - Error: If business_name contains "__fail__", emit pipeline_error.
"""

import json
import time
import hashlib
import os
from datetime import datetime, timezone

# --- Widget setup (same 28 widgets as real monolith) ---

WIDGET_DEFAULTS = {
    "operation": "new base model",
    "business_name": "test_corp",
    "business_description": "A test company",
    "context_file": "",
    "deployment_catalog": "test_catalog",
    "data_model_scopes": "Minimum Viable Model - MVM",
    "model_vibes": "",
    "vibe_session_id": "",
    "naming_convention": "snake_case",
    "pk_suffix": "_id",
    "pk_type": "BIGINT",
    "fk_suffix": "_id",
    "boolean_format": "true/false",
    "timestamp_type": "TIMESTAMP",
    "string_type": "STRING",
    "decimal_type": "DECIMAL(18,2)",
    "audit_columns": "created_at,updated_at",
    "table_prefix": "",
    "schema_prefix": "",
    "industry_alignment": "Retail",
    "max_domains": "10",
    "max_products_per_domain": "20",
    "max_attributes_per_product": "30",
    "model_version": "",
    "model_folder": "",
    "llm_endpoint": "databricks-meta-llama-3-1-70b-instruct",
    "log_level": "INFO",
}

for name, default in WIDGET_DEFAULTS.items():
    try:
        dbutils.widgets.text(name, default)  # type: ignore[name-defined]
    except Exception:
        pass

def _get_widget(name: str) -> str:
    try:
        return dbutils.widgets.get(name)  # type: ignore[name-defined]
    except Exception:
        return WIDGET_DEFAULTS.get(name, "")


# --- Helpers ---

def _session_id_to_bigint(sid: str) -> int:
    return int(hashlib.sha256(sid.encode()).hexdigest(), 16) & 0x7FFFFFFFFFFFFFFF


def _now_str() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M:%S")


# --- Delta table writers ---

def _ensure_tables(spark, catalog: str):
    """Create _metamodel._business and _metamodel._vibe_progress if they don't exist."""
    spark.sql(f"CREATE DATABASE IF NOT EXISTS `{catalog}`.`_metamodel`")

    spark.sql(f"""
        CREATE TABLE IF NOT EXISTS `{catalog}`.`_metamodel`.`_business` (
            session_id BIGINT,
            processing_status STRING,
            completed_percent DOUBLE,
            session_started_at TIMESTAMP,
            last_updated_at TIMESTAMP,
            session_json STRING,
            results_json STRING,
            completion_date TIMESTAMP,
            business STRING,
            version STRING,
            model_scope STRING
        ) USING DELTA
    """)

    spark.sql(f"""
        CREATE TABLE IF NOT EXISTS `{catalog}`.`_metamodel`.`_vibe_progress` (
            session_id BIGINT,
            step_id BIGINT,
            last_updated TIMESTAMP,
            stage_name STRING,
            step_name STRING,
            attempt_number INT,
            progress_increment DOUBLE,
            message STRING,
            status STRING,
            event_seq BIGINT,
            result_json STRING
        ) USING DELTA
    """)


def _write_business_row(spark, catalog, session_id_int, business, version, model_scope):
    """Insert or update the _business session row via SQL INSERT to avoid schema inference issues."""
    now_str = _now_str()
    spark.sql(f"""
        INSERT INTO `{catalog}`.`_metamodel`.`_business`
        (session_id, processing_status, completed_percent, session_started_at,
         last_updated_at, session_json, results_json, completion_date,
         business, version, model_scope)
        VALUES (
            {session_id_int}, 'pending', 0.0,
            CAST('{now_str}' AS TIMESTAMP), CAST('{now_str}' AS TIMESTAMP),
            '{{}}', '{{}}', NULL,
            '{business}', '{version}', '{model_scope}'
        )
    """)


def _write_progress_event(spark, catalog, session_id_int, step_id, stage, step, status, message, increment, result_json=None):
    """Append a progress event to _vibe_progress via SQL INSERT."""
    now_str = _now_str()
    rj_escaped = json.dumps(result_json).replace("'", "\\'") if result_json else None
    rj_sql = f"'{rj_escaped}'" if rj_escaped else "NULL"
    msg_escaped = message.replace("'", "\\'")
    spark.sql(f"""
        INSERT INTO `{catalog}`.`_metamodel`.`_vibe_progress`
        (session_id, step_id, last_updated, stage_name, step_name,
         attempt_number, progress_increment, message, status, event_seq, result_json)
        VALUES (
            {session_id_int}, {step_id}, CAST('{now_str}' AS TIMESTAMP),
            '{stage}', '{step}', 1, {increment},
            '{msg_escaped}', '{status}', {step_id}, {rj_sql}
        )
    """)


def _update_business_status(spark, catalog, session_id_int, status, percent, results_json=None, completion_date=None):
    """Update the _business row for this session."""
    set_clauses = [
        f"processing_status = '{status}'",
        f"completed_percent = {percent}",
        f"last_updated_at = current_timestamp()",
    ]
    if results_json:
        escaped = json.dumps(results_json).replace("'", "\\'")
        set_clauses.append(f"results_json = '{escaped}'")
    if completion_date:
        set_clauses.append(f"completion_date = current_timestamp()")

    spark.sql(f"""
        UPDATE `{catalog}`.`_metamodel`.`_business`
        SET {', '.join(set_clauses)}
        WHERE session_id = {session_id_int}
    """)


_CANNED_MODEL = {
    "business_name": "",
    "version": "",
    "model_scope": "Minimum Viable Model - MVM",
    "industry": "Retail",
    "domains": [
        {
            "name": "sales",
            "division": "Commercial",
            "description": "Core sales domain covering transactions and customers",
            "database_name": "sales",
            "products": [
                {
                    "product": "customer",
                    "type": "Master",
                    "data_type": "Structured",
                    "description": "Customer master data including demographics and contact information",
                    "primary_key": "customer_id",
                    "attributes": [
                        {"attribute": "customer_id", "type": "BIGINT", "description": "Unique customer identifier", "tags": "pii", "foreign_key_to": ""},
                        {"attribute": "customer_name", "type": "STRING", "description": "Full name of the customer", "tags": "pii", "foreign_key_to": ""},
                        {"attribute": "email", "type": "STRING", "description": "Primary email address", "tags": "pii", "foreign_key_to": ""},
                        {"attribute": "segment_id", "type": "BIGINT", "description": "Reference to customer segment", "tags": "", "foreign_key_to": "sales.customer_segment.segment_id"},
                    ],
                },
                {
                    "product": "customer_segment",
                    "type": "Reference",
                    "data_type": "Structured",
                    "description": "Customer segmentation reference data",
                    "primary_key": "segment_id",
                    "attributes": [
                        {"attribute": "segment_id", "type": "BIGINT", "description": "Unique segment identifier", "tags": "", "foreign_key_to": ""},
                        {"attribute": "segment_name", "type": "STRING", "description": "Name of the customer segment", "tags": "", "foreign_key_to": ""},
                    ],
                },
            ],
        },
        {
            "name": "inventory",
            "division": "Operations",
            "description": "Inventory and product management domain",
            "database_name": "inventory",
            "products": [
                {
                    "product": "product_catalog",
                    "type": "Master",
                    "data_type": "Structured",
                    "description": "Product master catalog with pricing and categorization",
                    "primary_key": "product_id",
                    "attributes": [
                        {"attribute": "product_id", "type": "BIGINT", "description": "Unique product identifier", "tags": "", "foreign_key_to": ""},
                        {"attribute": "product_name", "type": "STRING", "description": "Product display name", "tags": "", "foreign_key_to": ""},
                        {"attribute": "unit_price", "type": "DECIMAL(10,2)", "description": "Standard unit price", "tags": "", "foreign_key_to": ""},
                        {"attribute": "category_code", "type": "STRING", "description": "Product category classification code", "tags": "", "foreign_key_to": ""},
                    ],
                },
            ],
        },
    ],
}


def _write_model_json(catalog, business, version):
    """Write canned model.json to Volumes."""
    import copy
    model = copy.deepcopy(_CANNED_MODEL)
    model["business_name"] = business
    model["version"] = version

    vol_path = f"/Volumes/{catalog}/_metamodel/vol_root/business/{business}/{version}/docs"
    dbutils.fs.mkdirs(vol_path)  # type: ignore[name-defined]

    output_path = f"{vol_path}/{business}_data_model_{version}.json"
    dbutils.fs.put(output_path, json.dumps(model, indent=2), overwrite=True)  # type: ignore[name-defined]


def _do_handshake(spark, catalog, session_id_int, timeout_seconds=5):
    """Set processing_status='ready', wait for 'done', then flush."""
    _update_business_status(spark, catalog, session_id_int, "ready", 100)

    deadline = time.time() + timeout_seconds
    while time.time() < deadline:
        row = spark.sql(f"""
            SELECT processing_status FROM `{catalog}`.`_metamodel`.`_business`
            WHERE session_id = {session_id_int}
        """).collect()
        if row and row[0].processing_status == "done":
            return
        time.sleep(1)
    # Timeout — flush anyway (same as real monolith)


# --- Operation handlers ---

MODEL_PRODUCING_OPS = {
    "new base model",
    "vibe modeling of version",
    "shrink ecm",
    "enlarge mvm",
}

LIFECYCLE_OPS = {
    "install model",
    "uninstall model version",
    "generate sample data",
}


def _run_model_producing(spark, catalog, session_id_int, business, version, model_scope, operation):
    """Simulate a model-producing operation with progress events."""
    is_error = "__fail__" in business

    # Session Started (bookend per Integration Guide)
    _write_progress_event(spark, catalog, session_id_int, 1,
        "Vibe Session", "Session Started", "stage_started",
        f"Starting {operation}",
        0.0,
        {
            "session_id": str(session_id_int),
            "business_name": business,
            "operation": operation,
            "version": version,
            "model_scope": model_scope,
            "deploy_catalog": catalog,
            "llm_endpoint": _get_widget("llm_endpoint"),
            "industry_alignment": _get_widget("industry_alignment"),
        },
    )
    _update_business_status(spark, catalog, session_id_int, "pending", 5)

    # Domain generation
    _write_progress_event(spark, catalog, session_id_int, 2,
        "Logical Schema", "Domain Classification", "stage_succeeded",
        "Classified 2 domains", 20.0)
    _update_business_status(spark, catalog, session_id_int, "pending", 25)

    # Product generation
    _write_progress_event(spark, catalog, session_id_int, 3,
        "Logical Schema", "Product Generation - sales", "stage_succeeded",
        "Generated 2 products for sales domain", 15.0)
    _update_business_status(spark, catalog, session_id_int, "pending", 40)

    _write_progress_event(spark, catalog, session_id_int, 4,
        "Logical Schema", "Product Generation - inventory", "stage_succeeded",
        "Generated 1 product for inventory domain", 15.0)
    _update_business_status(spark, catalog, session_id_int, "pending", 55)

    # Attribute generation
    _write_progress_event(spark, catalog, session_id_int, 5,
        "Logical Schema", "Attribute Generation", "stage_succeeded",
        "Generated 10 attributes across 3 products", 15.0)
    _update_business_status(spark, catalog, session_id_int, "pending", 70)

    if is_error:
        # Simulate pipeline error (bookend per Integration Guide)
        _write_progress_event(spark, catalog, session_id_int, 6,
            "Vibe Session", "Session Ended", "stage_ended",
            "Pipeline failed",
            0.0,
            {"error": "Simulated failure", "details": "business_name contains __fail__", "status": "pipeline_error"},
        )
        _update_business_status(spark, catalog, session_id_int, "ready", 100,
            results_json={"status": "pipeline_error", "error": "Simulated failure"},
            completion_date=True)
        _do_handshake(spark, catalog, session_id_int)
        return

    # FK linking
    _write_progress_event(spark, catalog, session_id_int, 6,
        "Foreign Keys", "FK Linking", "stage_succeeded",
        "Linked 1 foreign key relationship", 10.0)
    _update_business_status(spark, catalog, session_id_int, "pending", 80)

    # Artifacts
    _write_progress_event(spark, catalog, session_id_int, 7,
        "Artifacts", "Model JSON", "stage_succeeded",
        "Generated model.json", 10.0)
    _update_business_status(spark, catalog, session_id_int, "pending", 90)

    # Write model.json to Volumes
    _write_model_json(catalog, business, version)

    # Session Ended (success bookend per Integration Guide)
    _write_progress_event(spark, catalog, session_id_int, 8,
        "Vibe Session", "Session Ended", "stage_ended",
        "Pipeline completed successfully",
        0.0,
        {
            "status": "success",
            "business_name": business,
            "version": version,
            "model_scope": model_scope,
            "duration_seconds": 5,
            "total_domains": 2,
            "total_products": 3,
            "total_attributes": 10,
            "total_fk_links": 1,
            "domains": ["sales", "inventory"],
            "products_by_domain": {"sales": 2, "inventory": 1},
            "fk_links": [{"source": "sales.customer.segment_id", "target": "sales.customer_segment.segment_id"}],
        },
    )
    _update_business_status(spark, catalog, session_id_int, "ready", 100,
        results_json={"status": "success"},
        completion_date=True)

    _do_handshake(spark, catalog, session_id_int)


def _run_lifecycle(spark, catalog, operation):
    """Simulate a lifecycle operation (no Delta progress, just success)."""
    # Lifecycle ops don't use VibeWriter — they just run and exit
    time.sleep(1)  # Simulate brief work


# --- Main dispatch ---

operation = _get_widget("operation")
business = _get_widget("business_name")
catalog = _get_widget("deployment_catalog")
version = _get_widget("model_version") or "v1"
model_scope = _get_widget("data_model_scopes")
session_id_str = _get_widget("vibe_session_id")

if operation in MODEL_PRODUCING_OPS:
    session_id_int = _session_id_to_bigint(session_id_str) if session_id_str else 0
    _ensure_tables(spark, catalog)  # type: ignore[name-defined]
    _write_business_row(spark, catalog, session_id_int, business, version, model_scope)  # type: ignore[name-defined]
    _run_model_producing(spark, catalog, session_id_int, business, version, model_scope, operation)  # type: ignore[name-defined]
elif operation in LIFECYCLE_OPS:
    _run_lifecycle(spark, catalog, operation)  # type: ignore[name-defined]
else:
    raise ValueError(f"Unknown operation: {operation}")
