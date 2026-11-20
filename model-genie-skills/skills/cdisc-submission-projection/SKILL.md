---
name: cdisc-submission-projection
description: Project governed silver data into SDTM and ADaM datasets as a metadata-driven submission layer. Use when transforming normalized biomedical data from the clinical_trials model into CDISC SDTM (Study Data Tabulation Model) domain datasets and ADaM (Analysis Data Model) outputs for regulatory submission. Driven by sdtm_mapping and sdtm_variable_spec products; leverages cdisc-org COSMoS specializations and Dataset-JSON export format. Keeps silver data un-SDTM-shaped and projection layered. Also useful for cross-domain variable mapping, generating Define-XML metadata, and auditing submission readiness. Read-only on silver, write to gold/submission layer only. Not for study-design ingestion (use usdm-study-ingest) or terminology loading (use cdisc-terminology-load).
---

# CDISC Submission Projection Skill

> **Prerequisites:** This skill works against a Databricks workspace with the clinical_trials v2 model fully built out with populated silver biomedical data (subject, trial_subject, adverse_event, concomitant_medication, lab_result, vital_signs, disposition, medical_history, etc.). It reads from silver, applies submission-level transformations, and writes SDTM datasets (typically to a gold/submission layer) in Delta format. Also outputs Dataset-JSON and Define-XML metadata. Load `autonomous-validation` alongside this skill to govern execution discipline and batch validation (not automatic; load explicitly).

## Overview

This skill provides guidance for generating CDISC SDTM and ADaM datasets from the clinical_trials model's normalized silver biomedical data. SDTM is the regulatory submission standard for clinical trial data, required by FDA, EMA and other authorities. The projection is metadata-driven: each `sdtm_mapping` record specifies how a silver entity/column maps to an SDTM domain and variable, and each `sdtm_variable_spec` product defines the variable's name, label, role, core designation, codelist, and type. Silver data stays normalized and business-shaped; the projection is a downstream, read-only layer that consumes silver and outputs submission-ready SDTM domain tables in Delta format, plus Dataset-JSON (CDISC's text-based JSON dataset-exchange format for submission).

**What this skill produces:**
- **SDTM domain projection notebooks** - per-domain (AE, LB, VS, DM, DS, etc.), a notebook that reads from silver, applies the mapping defined in `sdtm_mapping` + `sdtm_variable_spec`, performs variable recoding (e.g. unit conversion, date standardization), resolves foreign keys and codelists, and writes one SDTM domain table (e.g. AE dataset with STUDYID, DOMAIN, USUBJID, AEDT, AESTDY, AEREL, AEOUT, etc.).
- **ADaM dataset production** (optional, scoped) - analysis datasets (ADSL, ADAE, ADLB, etc.) built from SDTM domains for analysis workflows. Focuses on ADSL (Subject-Level) and one or two analysis datasets per the Statistical Analysis Plan (SAP).
- **SDTM domain specializations** - per COSMoS (CDISC Open-Source Metadata Specifications), metadata for each domain (domain name, domain description, class, purpose, example variables).
- **Variable-level metadata** - via `sdtm_variable_spec`, a catalog of all SDTM variables with name, label, role (IDENTIFIER, QUALIFIER, RECORD_QUALIFIER, TOPIC, RESULT, TIMING, VARIABLE_QUALIFIER, VARIABILITY_QUALIFIER), core designation (Req, Exp, Perm, Cond), codelist reference (if applicable), and type.
- **Dataset-JSON export** - a single, submission-ready JSON file containing all SDTM domains in the CDISC DataExchange Dataset-JSON format (v1.1 or v2.0), with metadata embedded.
- **Define-XML 2.1 metadata document** - the regulatory snapshot of the submission datasets, including variable definitions, codelists, computational methods (derivations), comments, and administrative information. Generated from the sdtm_variable_spec + study metadata.
- **Submission-readiness validation report** - checks for completeness (all Req variables present), correctness (no orphaned FKs, dates within study timeline, codelists valid), and formatting (variable name lengths, no special characters, datetime precision).
- **Mapping gap analysis** - flags silver entities/columns not yet mapped to SDTM, offering choices for each (map to an existing SDTM variable, create a custom variable, or defer).
- **docs/commentary/cdisc-submission-projection-improvement-recommendations.md** - emitted at closeout (skill-improvement recommendations, following `autonomous-validation/commentary-protocol.md`).

**Scope:** Metadata-driven projection from clinical_trials silver (normalized, business-shaped) to SDTM gold/submission layer (normalized, submission-shaped). Handles the CDISC SDTM Implementation Guide (SDTMIG) standard domains (DM, EX, DS, PE, VS, LB, AE, CM, MH, PC, TA, etc.) with variable specifications from the configured SDTMIG version (via conventions.yml; typically SDTMIG 3.4 with SDTM v2.0, SDTMIG 3.3 with SDTM v1.7, or SDTMIG 3.2 with SDTM v1.4). ADaM scope is optional and scoped to ADSL + selected analysis datasets. Dataset-JSON export per CDISC DataExchange spec. Define-XML 2.1 (FDA accepts 2.0 and 2.1). Does NOT create or modify gold business-logic products (marts, KPIs) - that is a separate engagement.

---

## When to Load This Skill

Load when:
- Preparing data for regulatory submission (FDA, EMA, etc.) in SDTM format
- Transforming clinical trial data into submission datasets (AE, LB, VS, DM, DS, PE, etc.)
- Generating analysis datasets (ADSL, ADAE, ADLB) from SDTM
- Creating Define-XML metadata for a submission package
- Validating submission readiness before hand-off to regulatory affairs
- Auditing which silver entities/columns map to SDTM and which have gaps
- Exporting submission data in Dataset-JSON format for CDISC-compliant workflows
- Testing SDTM variable mapping before production submission run
- Updating SDTM datasets after silver-data corrections (re-projection after fixes)

Do NOT load for:
- General business-logic transformation (use `etl-development-framework`)
- Creating new business entities or data lineage (use business-layer skills instead)
- Study-design or protocol work (use `usdm-study-ingest`)
- Terminology or standards reference loading (use `cdisc-terminology-load`)
- Unstructured data parsing or de-identification

---

## Execution Model

### Phase 0 - Setup & Validation

1. **Locate the silver biomedical products** - query `_metamodel` to resolve silver domain entities (adverse_event, concomitant_medication, lab_result, vital_signs, disposition, medical_history, etc.); confirm they are populated.
2. **Locate the SDTM metadata products** - resolve `sdtm_mapping`, `sdtm_variable_spec`, `cdisc_standard` from `_metamodel`; confirm they exist and are populated (should have been loaded by `cdisc-terminology-load` or uploaded separately).
3. **Resolve the target layer** - decide where SDTM datasets will be written: gold/submission schema, or a separate submission catalog. This is a HITL gate; confirm before proceeding.
4. **Validate conventions.yml** - confirm `output_model` (normalized/dimensional/hybrid), gold catalog/schema, and any submission-specific config (e.g. variable-naming rules, date-handling conventions, codelist versioning).
5. **Check for prior SDTM builds** - if SDTM datasets already exist at the target location, decide whether to replace (full re-projection) or merge (incremental, subject-level); record the disposition.

### Phase 1 - Assess Silver-to-SDTM Mapping

1. **Enumerate silver entities** - query the silver biomedical products (adverse_event, concomitant_medication, lab_result, vital_signs, etc.); for each, list columns.
2. **Cross-reference sdtm_mapping** - for each silver entity, query `sdtm_mapping` to determine which SDTM domain and variables it populates. Grouping by SDTM domain:
   - **AE domain** - from silver `adverse_event` table
   - **CM domain** - from silver `concomitant_medication` table
   - **LB domain** - from silver `lab_result` table
   - **VS domain** - from silver `vital_signs` table
   - **DS domain** - from silver `disposition` table
   - **MH domain** - from silver `medical_history` table
   - **DM domain** - from silver `trial_subject` + `subject` tables
   - **PE domain** (if applicable) - from physical-exam observations
   - **EX domain** (if applicable) - from study-intervention (drug exposures)
3. **Flag mapping gaps** - for each silver column, confirm it maps to an SDTM variable via `sdtm_mapping`. If not mapped:
   - Option A: map it to an existing SDTM variable (e.g. a custom column becomes an Exp or Perm variable).
   - Option B: defer (do not include in submission).
   - Option C: create a new custom variable (requires Define-XML comment).
   - Record the decision per gap.
4. **Emit gap-analysis report** - list all unmapped silver columns, proposed resolutions, and any columns flagged for deferral.

### Phase 2 - Plan SDTM Domain Projections

For each SDTM domain (AE, LB, VS, DM, DS, etc.), plan the projection:

| SDTM Domain | Source Silver Entity | Key Silver Columns | Mapping Challenges | Notes |
|---|---|---|---|---|
| **DM** | subject.demographic + subject.trial_subject | unique_subject_identifier, subject_number, date_of_birth, age_at_screening, age_unit_codelist_term_id, sex_codelist_term_id, race_codelist_term_id, ethnicity_codelist_term_id, country, arm_id, reference_start_date, informed_consent_date | SEX, RACE, ETHNIC and AGEU come from `datamanagement.codelist_term.submission_value` through the `*_codelist_term_id` foreign keys; USUBJID from unique_subject_identifier | Host demographics; one row per subject |
| **AE** | safety.adverse_event | adverse_event_id, ae_verbatim_term, meddra_pt_name, meddra_llt_code, onset_date, is_serious, causality_assessment, adverse_severity_codelist_term_id, adverse_outcome_codelist_term_id, adverse_action_taken_codelist_term_id | AESEV, AEOUT and AEACN decode through `codelist_term`; MedDRA coding version from meddra_version; AESTDY relative to RFSTDTC | One row per adverse event; MedDRA content is customer-licensed |
| **CM** | subject.concomitant_medication | concomitant_medication_id, verbatim_term, whodrug_drug_name, whodrug_atc_code, dose, dose_unit_codelist_term_id, route_codelist_term_id, dose_form_codelist_term_id, dose_frequency, indication, start_date, end_date | CMDOSU, CMROUTE and CMDOSFRM decode through `codelist_term`; WHODrug coding from whodrug_version; CMSTDY relative to RFSTDTC | One row per medication; WHODrug content is customer-licensed |
| **LB** | laboratory.laboratory_lab_result | laboratory_lab_result_id, lab_analyte_id, loinc_id, result_value, result_unit, result_standard_unit, normal_range_lower, normal_range_upper, collection_datetime, lbcat, lbscat | Unit standardization to the CDISC UNIT codelist; LOINC linkage through loinc_id; date handling | One row per lab test per visit; repeat visits possible |
| **VS** | laboratory.laboratory_vital_sign | laboratory_vital_sign_id, loinc_id, subject_visit_id, esource_capture_datetime | Unit standardization; date handling (VSDTC, VSDY) | One row per vital-sign measurement per visit |
| **DS** | subject.disposition | disposition_id, term, event, milestone_category, disposition_date, screen_failure_reason, death_date | Mapping to DSDECOD (NCOMPLT codelist) and DSCAT; one row per disposition event | One row per disposition event |
| **MH** | medical_history | mh_id, condition, onset_date, resolution_date, relationship, status | Condition-to-MedDRA PT mapping (if available); date handling | One row per medical history condition |
| **PE** (if applicable) | physical_exam | pe_id, exam_type, finding, date | Map to PE domain variables (PETEST, PEORRES, PEDAT, etc.) | One row per exam / finding combination per visit |
| **EX** (if applicable) | study_intervention | intervention_id, intervention_type, dose, route, frequency, start_date, end_date | Map to EX domain (EXDOSE, EXROUTE, EXSTDY, EXENDY, etc.) | One row per dose administration or period |

### Phase 3 - Generate SDTM Domain Projections

For each SDTM domain:

1. **Write domain-specific notebook** - in `src/gold/transformations/sdtm_{domain}`:
   - Read the source silver entity and the relevant sdtm_mapping records.
   - Apply column recoding (e.g. adverse-event severity to AESEV numeric, date formatting to ISO 8601).
   - Resolve foreign keys and codelists (e.g. join to codelist_term to resolve AESEV -> CDISC CT value).
   - Derive SDTM-required variables (e.g. AESTDY = days from enrollment, USUBJID, DOMAIN, EPOCH, etc.).
   - Validate row counts and key uniqueness.
   - Write to the SDTM domain table (e.g. ae_dataset, lb_dataset, etc. or consolidated SDTM table structure).

2. **Example: AE domain projection (pseudocode)**
   ```sql
   SELECT
     STUDYID,
     'AE' AS DOMAIN,
     trial_subject_id AS USUBJID,
     sequence_number AS AESEQ,
     ae_date AS AEDT,
     DATEDIFF(day, enrollment_date, ae_date) AS AESTDY,
     ae_term AS AETERM,
     NULL AS AEDECOD,  -- (will be populated post-MedDRA load)
     CASE severity WHEN 'Mild' THEN 1 WHEN 'Moderate' THEN 2 WHEN 'Severe' THEN 3 END AS AESEV,
     ...
   FROM adverse_event ae
   LEFT JOIN sdtm_mapping sm ON ae.adverse_event_id = sm.source_id AND sm.target_domain = 'AE'
   LEFT JOIN codelist_term ct ON ct.submission_value = ae.outcome AND ct.codelist = 'AEOUT'
   WHERE ae.study_version_id = @study_version_id
   ```

3. **Handle special cases**:
   - **Repeated measures** (e.g. multiple lab results for the same analyte per subject) - ensure one row per observation.
   - **Missing dates** - flag any enrollment or event date that is NULL or outside the study timeline; escalate to HITL gate.
   - **Unmapped codelists** - if a silver value doesn't match any codelist_term, flag and decide: map to a custom term, reject, or defer.
   - **Key derivation** - USUBJID is the linking key across all domains; confirm derivation rule is consistent (e.g. always trial_subject_id, never subject_id).

### Phase 4 - Generate ADaM Datasets (if in scope)

ADaM (Analysis Data Model) is built FROM SDTM, not directly from silver. Typically:

1. **ADSL** (Subject-Level Analysis Dataset) - one row per subject with baseline characteristics, enrollment date, completion status, treatment assignment, protocol deviations, etc. Derived from SDTM DM + DS + EX + other domains.
2. **ADAE** (Adverse Event Analysis Dataset) - the SDTM AE domain with analysis-level flags (e.g. is this AE serious, related to study treatment, etc.).
3. **ADLB** (Laboratory Analysis Dataset) - the SDTM LB domain with derived variables (e.g. lab result change from baseline, % change, etc.).

Each ADaM dataset is built via a separate notebook (similar to SDTM domain projection) and populated from the corresponding SDTM domain(s). This is optional; confirm with the user whether ADaM is required.

### Phase 5 - Dataset-JSON & Define-XML Export

1. **Dataset-JSON** - after all SDTM domains are projected, combine into a single JSON file per CDISC DataExchange Dataset-JSON v1.1 or v2.0 spec:
   - Structure: ItemGroupData (one per domain) containing Items (one per variable per record).
   - Metadata: variable definitions (name, label, type, length), codelist references, computational methods (if any).
   - Required fields: STUDYID, DOMAIN, USUBJID.

2. **Define-XML 2.1** - generate regulatory metadata document:
   - Root element: `Define` with study metadata (protocol version, submission date, etc.).
   - ItemGroupDefs (one per SDTM domain) with item/variable definitions.
   - CodeLists (link to CDISC CT codelists used).
   - Methods (if derivations exist, e.g. AESTDY = days from enrollment).
   - Comments (custom variables, deviations from SDTM IG).

### Phase 6 - Validate & Reconcile

1. **Completeness check** - for each SDTM domain, confirm all Required (Req) variables are present; flag any missing.
2. **Correctness checks**:
   - No NULL USUBJIDs (key validation).
   - All dates are within study timeline (STUDYSTRTDT <= event date <= STUDYENDT).
   - All codelist values match CDISC CT or custom codelist.
   - No orphaned foreign keys (e.g. every AESEQ belongs to a valid USUBJID).
3. **Formatting checks** - SDTM variable names are uppercase and <= 8 characters (pre-validation); no special characters in submission values.
4. **Subject count reconciliation** - confirm # unique USUBJIDs across domains matches the trial enrollment count.
5. **Emit validation report** - row counts per domain, completeness score, correctness findings, formatting issues, submission-readiness score (0-100%).

---

## Reference Files

| File | Content |
|---|---|
| `sdtm-domain-specifics.md` | Domain-by-domain projection rules: DM, AE, CM, LB, VS, DS, MH, PE, EX, TA, etc. Variable names, roles, core designation, derived-variable definitions, handling of repeats/nulls |

---

## Critical Rules (Always Apply)

1. **Metadata-driven** - all variable mappings must come from `sdtm_mapping` and `sdtm_variable_spec`; never hardcode column names or transformations.
2. **Silver stays un-SDTM-shaped** - do not modify the silver entities; projection is read-only on silver, write to gold/submission only.
3. **One SDTM domain projection per notebook** - each domain (AE, LB, VS, etc.) has a dedicated, standalone notebook; never combine domains in one notebook.
4. **USUBJID is immutable and consistent** - all SDTM domains must use the same USUBJID derivation rule; confirm pre-projection and enforce via pre-flight check.
5. **No NULL Required variables** - all CDISC SDTM Req variables must be populated; any NULL is a validation error that halts submission.
6. **Dates must be ISO 8601 and in-range** - all dates conform to YYYY-MM-DD; all event dates fall within the study timeline (STUDYSTRTDT to STUDYENDT); confirm pre-export.
7. **Codelists are immutable** - every submission value must resolve to a valid CDISC CT or custom codelist entry; no free-text values in codelist-governed variables.
8. **Row uniqueness** - within each SDTM domain, key uniqueness is enforced (e.g. AE: (USUBJID, AESEQ); LB: (USUBJID, LBTEST, LBDT); confirm pre-export.
9. **Define-XML metadata is required** - before declaring submission-ready, a Define-XML 2.1 document must exist (FDA accepts 2.0 and 2.1; use 2.1 by default), referencing all variables, codelists, and derivations.
10. **Audit trail** - record in `_audit_sdtm_projection` the source SDTM IG version, Define-XML version, dataset-JSON version, projection timestamp, silver row counts and SDTM row counts per domain, so projection is reproducible.

---

## What This Skill Does Not Do

- **Does not modify silver** - silver data layers remain normalized and business-shaped.
- **Does not create gold business-logic products** (marts, KPIs, metrics) - submission projection is a separate engagement.
- **Does not perform statistical analysis or ADaM computations** (e.g. change-from-baseline, response rates) - ADaM is in scope for ADSL + basic analysis datasets; complex SAP-driven analysis is downstream.
- **Does not generate Define-XML or Dataset-JSON on its own** - these are generated as outputs during Phase 5, but the skill documents the templates and references cdisc-org specs.
- **Does not re-engineer silver data for SDTM compliance** - if silver data is fundamentally misshapen for SDTM, the skill flags the gap and halts, rather than synthesizing data.

---

## Regulatory Compliance

SDTM datasets generated by this skill must conform to:
- **CDISC SDTM Implementation Guide (SDTMIG)** - version configured in conventions.yml (SDTMIG 3.2/SDTM v1.4, SDTMIG 3.3/SDTM v1.7, or SDTMIG 3.4/SDTM v2.0; documented in Define-XML).
- **FDA CDISC Submission Standards** - as of the submission date (FDA accepts SDTMIG 3.2 and later).
- **Define-XML 2.1** - for metadata documentation (FDA accepts 2.0 and 2.1; use 2.1 by default).
- **Dataset-JSON** - per CDISC DataExchange spec (v1.1 or v2.0).

All outputs are auditable (source mapping, transformation rules, versions) for regulatory inspection.

