# Phase 0 - USDM Study Ingest Setup Queries

This document contains SQL queries for Phase 0 setup: resolving the study domain products from the `_metamodel`, confirming they exist and are empty or historical, and checking for study_version_id collisions.

## Step 1: Resolve Study Domain Products from _metamodel

Assumes the metamodel is at `{metamodel_schema}.vibe_metamodel_*` or `{schema}._metamodel.*`. Adjust schema references as needed.

```sql
-- Resolve metamodel location
SELECT 
  table_schema, 
  table_name
FROM information_schema.tables
WHERE table_name LIKE '%metamodel%'
  AND table_schema NOT IN ('information_schema', 'sys')
LIMIT 10;
```

Once you identify the metamodel schema, query the product inventory for the study domain:

```sql
-- Resolve study domain products from _metamodel
-- Adjust {metamodel_schema} to match your environment
SELECT 
  product_id,
  product,
  description,
  vibe_class,
  domain,
  version
FROM {metamodel_schema}.vibe_metamodel_product
WHERE domain = 'study'
  AND version = (
    SELECT MAX(version) 
    FROM {metamodel_schema}.vibe_metamodel_product 
    WHERE domain = 'study'
  )
ORDER BY product;
```

Expected products (v2 model, not all may exist in v1):
- study_version
- study_design
- arm
- epoch
- study_cell
- study_element
- schedule_timeline
- scheduled_activity_instance
- encounter
- activity
- biomedical_concept
- study_identifier
- governance_date
- population
- cohort
- study_intervention
- estimand
- intercurrent_event
- objective
- endpoint
- eligibility_criterion

## Step 2: Confirm Study Domain Products Exist and are Empty

For each product identified above, check whether the corresponding table exists in the silver/target catalog:

```sql
-- Check which study-domain tables exist in the target schema
SELECT 
  table_schema,
  table_name
FROM information_schema.tables
WHERE table_schema = '{silver_schema}'
  AND table_name IN (
    'study_version', 'study_design', 'arm', 'epoch', 
    'study_cell', 'study_element', 'schedule_timeline', 
    'scheduled_activity_instance', 'encounter', 'activity', 
    'biomedical_concept', 'study_identifier', 'governance_date', 
    'population', 'cohort', 'study_intervention', 'estimand', 
    'intercurrent_event', 'objective', 'endpoint', 'eligibility_criterion'
  )
ORDER BY table_name;
```

> information_schema does not carry live row counts. For each table returned above, get its
> count with a per-table query (`SELECT COUNT(*) FROM {silver_schema}.{table}`) or a `UNION ALL`
> across those tables; use that to decide whether each is empty or holds historical data.

If any table does not exist, create it as an empty table with the schema inferred from the `_metamodel`:

```sql
-- Example: Create empty study_version table
-- Use the attribute list from vibe_metamodel_attribute for the given product_id
CREATE TABLE IF NOT EXISTS {silver_schema}.study_version (
  study_version_id STRING NOT NULL,
  study_id STRING,
  version_number INTEGER,
  study_title STRING,
  study_rationale STRING,
  brief_summary STRING,
  sponsor_name STRING,
  study_type STRING,
  design_type STRING,
  is_master_protocol BOOLEAN,
  therapeutic_areas STRING,
  study_phase STRING,
  icf_version STRING,
  _load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP(),
  _load_date DATE DEFAULT CURRENT_DATE()
)
USING DELTA;
```

## Step 3: Check for Existing study_version Collisions

Before loading a new USDM study definition, check whether any study_version_id already exists:

```sql
-- Check for existing study_version entries
SELECT 
  study_version_id,
  study_id,
  version_number,
  study_title,
  COUNT(*) AS occurrences
FROM {silver_schema}.study_version
GROUP BY study_version_id, study_id, version_number, study_title
ORDER BY occurrences DESC;
```

If collisions are found, this is a HITL gate: decide whether to:
- **Append** - insert as a new version (only if version_number is different)
- **Replace** - use a Type-1 merge (update the existing row, overwrite metadata)
- **Skip** - do not load (idempotent, assume already loaded)

Document the disposition in the manifest.

## Step 4: Validate the Target Layer Catalog and Schema

Confirm the target catalog and schema (where SDTM datasets will be written) exist and are accessible:

```sql
-- List available catalogs
SHOW CATALOGS;

-- List schemas in the target catalog
SHOW SCHEMAS IN {target_catalog};

-- Create the target schema if needed
CREATE SCHEMA IF NOT EXISTS {target_catalog}.{target_schema}
COMMENT 'Study domain for USDM ingest';
```

## Step 5: Create Audit Table for Load Tracking

Create or clear the audit table to record load metadata:

```sql
-- Create _audit_usdm_ingest table
CREATE TABLE IF NOT EXISTS {target_schema}._audit_usdm_ingest (
  audit_id STRING,
  load_timestamp TIMESTAMP,
  source_file_path STRING,
  source_file_hash STRING,
  ddf_ra_version STRING,
  usdm_package_version STRING,
  study_version_id STRING,
  row_count_study_version INTEGER,
  row_count_study_arm INTEGER,
  row_count_study_epoch INTEGER,
  row_count_study_cell INTEGER,
  row_count_study_element INTEGER,
  row_count_schedule_timeline INTEGER,
  row_count_scheduled_activity_instance INTEGER,
  row_count_encounter INTEGER,
  row_count_activity INTEGER,
  row_count_biomedical_concept INTEGER,
  row_count_study_identifier INTEGER,
  row_count_governance_date INTEGER,
  row_count_population INTEGER,
  row_count_cohort INTEGER,
  row_count_study_intervention INTEGER,
  row_count_estimand INTEGER,
  row_count_intercurrent_event INTEGER,
  row_count_objective INTEGER,
  row_count_endpoint INTEGER,
  row_count_eligibility_criterion INTEGER,
  load_status STRING,
  reconciliation_notes STRING,
  load_disposition STRING
)
USING DELTA;

-- Record audit entry for this load
INSERT INTO {target_schema}._audit_usdm_ingest (
  audit_id,
  load_timestamp,
  source_file_path,
  ddf_ra_version,
  usdm_package_version,
  load_status
) VALUES (
  '{random_uuid}',
  CURRENT_TIMESTAMP(),
  '{source_file_path}',
  'v4',
  '{usdm_package_version}',
  'IN_PROGRESS'
);
```

## Notes

- All study-version IDs and related natural keys must be non-null and unique within their scope.
- If the study domain products do not exist in the metamodel, escalate to a HITL gate: either defer until the model is updated to v2, or run the vibe-model agent to extend it.
- Archive any prior USDM loads in a historical schema or partition for reproducibility and audit trails.

