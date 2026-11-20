---
name: cdisc-conformance-validation
description: Run CDISC CORE validation rules against projected SDTM datasets to validate submission conformance and land findings in a _validation_cdisc_core metadata table. Use when validating SDTM domain datasets for FDA/EMA submission - runs the CDISC-published open rules from cdisc-open-rules repository, flags business-logic violations, and generates a scorecard and audit trail. Also compares to SDTM Implementation Guide (IG) metadata. Read-only on SDTM, write to _validation_cdisc_core and scorecard only. Not for silver validation (use domain-model-validation) or dataset projection (use cdisc-submission-projection).
---

# CDISC Conformance Validation Skill

> **Prerequisites:** This skill works against CDISC SDTM datasets projected into a Databricks workspace (typically in a gold/submission layer). It reads the SDTM domain tables and runs conformance checks via the CDISC CORE rules engine (`cdisc-rules-engine` from cdisc-org). Load `autonomous-validation` alongside this skill to govern execution discipline and batch validation (not automatic; load explicitly).
>
> **API Key Note:** Full SDTMIG metadata through CDISC Library requires an API key (not free). This skill describes behavior with and without the key: without it, conformance is limited to the open rules in cdisc-open-rules (sufficient for most checks); with it, additional metadata-driven validations are available (optional, gated).

## Overview

This skill provides guidance for validating SDTM submission datasets against CDISC conformance standards. CDISC CORE (Conformance and Consistency Rules) is a rule engine that codifies the SDTM Implementation Guide and other standards into executable checks. The open-source subset (cdisc-open-rules) is free and sufficient for most submissions; the full CDISC Library metadata is available with an API key (not required). The skill runs configured rules against projected SDTM datasets, captures violations, and lands findings in a `_validation_cdisc_core` metadata table (following the suite's `domain-model-validation` conventions) with severity levels (Error, Warning, Info) and actionable remediation guidance.

**What this skill produces:**
- **CDISC CORE rules engine setup** - installation of `cdisc-rules-engine` (pip install cdisc-rules-engine), configuration of the rule set (cdisc-open-rules or optionally CDISC Library with API key), and rule execution against each SDTM domain dataset.
- **Conformance validation notebook** - for each SDTM domain (or across all), a PySpark/SQL notebook that:
  1. Loads the SDTM domain table(s).
  2. Runs CDISC CORE rules (open or full, depending on API key availability).
  3. Captures findings (violations, warnings) with row identifiers (USUBJID, AESEQ, etc.).
  4. Classifies severity (Error = submission blocker; Warning = fix requested; Info = informational).
  5. Inserts findings into `_validation_cdisc_core`.
- **_validation_cdisc_core metadata table** - structured record of every rule violation:
  - rule_id (CDISC rule code, e.g. "SDTM-001", "AE-100")
  - rule_description (what the rule checks)
  - domain (AE, LB, VS, etc.)
  - severity (Error, Warning, Info)
  - affected_rows (list of USUBJID + sequence numbers or IDs)
  - remediation_guidance (what to fix)
  - validation_timestamp
- **Submission conformance scorecard** - aggregated metrics:
  - # total rules evaluated
  - # rules passed, # failed
  - Errors (submission blockers), Warnings, Infos by domain
  - Overall conformance score (0-100%)
  - Domain-specific grades (A = no errors, B = no errors + some warnings, C = errors present)
- **Submission-readiness dashboard** - visual summary of conformance (pass/fail by domain, top violations, remediation priority).
- **Rule-to-remediation mapping** - for each rule violation, provide actionable guidance (e.g. "Missing AESTDY for record X: derive as enrollment_date - ae_date + 1").
- **CDISC Library metadata report** (if API key available) - enhanced validation using full SDTMIG variable specifications, additional cross-domain checks, and CDISC Library insights.
- **docs/commentary/cdisc-conformance-validation-improvement-recommendations.md** - emitted at closeout (skill-improvement recommendations, following `autonomous-validation/commentary-protocol.md`).

**Scope:** CDISC CORE open rules (cdisc-open-rules, free) are the baseline; full CDISC Library rules are optional if customer has API key. Validates SDTM domain datasets (AE, LB, VS, DM, DS, etc.) for FDA/EMA submission. Handles SDTMIG versions (3.2, 3.3, 3.4 with paired SDTM models) as configured in conventions.yml. Does NOT modify datasets - validation is read-only. Does NOT generate new variables; only flags missing/invalid values.

---

## When to Load This Skill

Load when:
- Validating SDTM datasets before regulatory submission
- Checking conformance of projected datasets to SDTM Implementation Guide
- Identifying submission blockers (Error-level violations) vs. warnings
- Auditing SDTM domain datasets after silver-data corrections
- Preparing submission packages for FDA/EMA
- Running pre-submission conformance gate (all Errors must be resolved before handoff to regulatory affairs)
- Comparing SDTM datasets across study sites or data-entry vendors for consistency
- Generating a conformance scorecard for submission documentation

Do NOT load for:
- General data quality validation (use `domain-model-validation`)
- Silver-layer validation (use silver domain validation)
- SDTM dataset projection or generation (use `cdisc-submission-projection`)
- Rule authoring or CDISC standard interpretation (consult CDISC Library directly)

---

## Execution Model

### Phase 0 - Setup & Configuration

1. **Locate the SDTM datasets** - query `information_schema` to confirm all projected SDTM domain tables exist (ae_dataset, lb_dataset, vs_dataset, dm_dataset, ds_dataset, etc.) and are populated.
2. **Install CDISC CORE rules engine** - install `cdisc-rules-engine` via pip (open source, free). Confirm version compatibility.
3. **Fetch the rule set**:
   - **Open rules (free)** - use cdisc-open-rules (default). This is sufficient for most submissions.
   - **Full CDISC Library rules (optional)** - if customer provides an API key to CDISC Library, fetch the full rule set. This requires:
     - API key registration with cdisc-org.
     - Confirmation that the customer has licensed CDISC Library access.
     - Environment variable or config file setup: `CDISC_LIBRARY_API_KEY`.
4. **Configure SDTMIG version** - resolve from the submission metadata or `conventions.yml` (SDTMIG 3.2, 3.3, or 3.4, paired with SDTM v1.4, v1.7, or v2.0 respectively); the rule set must match this version.
5. **Prepare the validation workspace**:
   - Ensure `_validation_cdisc_core` table exists (or create it with schema: rule_id, rule_description, domain, severity, affected_rows_json, remediation_guidance, validation_timestamp).
   - Clear any prior findings (or append if incremental revalidation).

### Phase 1 - Execute CDISC CORE Rules per Domain

For each SDTM domain (AE, LB, VS, DM, DS, etc.):

1. **Load the domain dataset** - query the SDTM domain table into a DataFrame or export as Dataset-JSON or XPT format.
2. **Run the rule set** - invoke the CDISC CORE rules engine (cdisc-rules-engine, via CLI or Python API per the package documentation) with:
   - Domain name (e.g. "AE")
   - Dataset path, format, or DataFrame
   - Rule scope (all rules for this domain, or a filtered set)
   - SDTMIG version (e.g. "3.4")
3. **Capture violations** - the engine returns a list of violations, each with:
   - Rule ID (e.g. "SDTM-001", "AE-100")
   - Rule description (what was violated)
   - Severity (Error, Warning, Info)
   - Affected rows (list of row numbers, USUBJIDs, sequence numbers, or full row identifiers)
   - Suggested remediation
4. **Write findings to _validation_cdisc_core** - insert one row per rule violation, with JSON-serialized affected_rows for later drill-down.

### Phase 2 - Domain-Specific Rule Examples

**Common CDISC CORE rule checks (not exhaustive; cdisc-open-rules has ~50+ rules):**

| Domain | Rule ID | Rule Description | Severity | Remediation |
|---|---|---|---|---|
| **AE** | AE-100 | Required AETERM missing | Error | Populate adverse-event term; if not available, exclude record |
| **AE** | AE-101 | AESTDY >= 1 (adverse event on or after enrollment) | Warning | Check ae_date vs. enrollment date; may be protocol deviation |
| **AE** | AE-102 | AESEV valid per CDISC CT | Error | Recode severity to CDISC CT values (1=Mild, 2=Moderate, 3=Severe) |
| **LB** | LB-100 | Required LBTEST missing | Error | Populate lab test name; map from silver lab code |
| **LB** | LB-101 | LBDT in study range (STUDYSTRTDT <= LBDT <= STUDYENDT) | Warning | Check lab collection date; flag if outside study or follow-up grace period |
| **LB** | LB-102 | LBORRES or LBSTRESC populated | Warning | At least one result value required; check silver for missing values |
| **VS** | VS-100 | Required VSTEST missing | Error | Populate vital-sign test name (BP, HR, Temp, etc.) |
| **VS** | VS-101 | VSDT in study range | Warning | Check vital-sign collection date |
| **DM** | DM-100 | Required USUBJID missing | Error | Cannot proceed; USUBJID is primary key |
| **DM** | DM-101 | Required RFSTDTC missing (study start date for subject) | Error | Populate enrollment date |
| **DM** | DM-102 | RFENDTC >= RFSTDTC if populated | Error | Study end date must be >= start date |
| **DS** | DS-100 | Required DSSTDTC missing | Error | Populate disposition start date |
| **DS** | DS-101 | DSTERM valid per CDISC CT (Completed, Withdrawn, etc.) | Error | Map to CDISC CT disposition terms |

### Phase 3 - Severity Classification & Remediation

Each violation is classified:

- **Error** - submission blocker; must be resolved before submission handoff. Examples: missing Required variable, value outside valid codelist, date outside study range.
- **Warning** - fix requested; does not block submission but indicates data quality issue. Examples: unexpected date, unusual value combination, potential protocol deviation.
- **Info** - informational; no action required but worth noting. Examples: new custom variable, expected pattern deviation.

For each violation, provide actionable remediation guidance:
- If missing value: "Derive from {source column}" or "Obtain from eCRF" or "Exclude record if unrecoverable".
- If invalid codelist: "Recode {old_value} to {valid_cdisc_value}" or "Confirm mapping rule".
- If date out of range: "Check source data; may be {protocol deviation | data-entry error | follow-up visit}".

### Phase 4 - Cross-Domain Validation (Optional, if CDISC Library API key available)

With CDISC Library access, run additional checks:

1. **FK consistency** - confirm every USUBJID in AE, LB, VS exists in DM (subject-level data must be present).
2. **Visit alignment** - if present, confirm AESTDY / LBDT align with expected study visit schedule.
3. **Codelist versioning** - confirm all codelist values come from the same CDISC CT package version (no mixing v2.5 and v2.6).
4. **Variable role consistency** - IDENTIFIER, QUALIFIER, TOPIC, RESULT roles must be used correctly across domains.
5. **Definition-XML alignment** - confirm all variables in the datasets match the Define-XML specification.

### Phase 5 - Scorecard & Reporting

1. **Aggregate findings**:
   - # total violations by severity (Errors, Warnings, Infos)
   - # violations by domain
   - # violations by rule category
2. **Calculate conformance score** - (# rules passed / # rules evaluated) * 100; example: 95/100 rules passed = 95%.
3. **Domain grades**:
   - **Grade A** - no Errors, 0-1 Warnings
   - **Grade B** - no Errors, 2-5 Warnings
   - **Grade C** - no Errors, >5 Warnings
   - **Grade D** - 1-5 Errors (requires rework)
   - **Grade F** - >5 Errors (submission blocker; escalate)
4. **Emit scorecard** - summary table with domains, row counts, violation counts, grades.
5. **Emit remediation roadmap** - prioritized list of violations and remediation steps, ordered by severity and domain.

### Phase 6 - Validation Completeness Check

Before declaring conformance validation complete:

1. **All domains validated** - confirm each projected SDTM domain has a conformance report (0 violations is valid; no skipped domains).
2. **CDISC CORE rule version documented** - record which rule set version was used (open-rules v{X} or CDISC Library v{Y}).
3. **Findings audit trail** - `_validation_cdisc_core` contains all violations with timestamps; no violations are discarded.
4. **Remediation accountability** - each Error-level violation has a remediation owner and target date assigned (HITL gate).

---

## Reference Files

| File | Content |
|---|---|
| `domain-specific-rules.md` | Per-domain (AE, LB, VS, DM, DS, MH, CM, PE, EX, etc.) breakdown of common CDISC CORE violations, severity, and remediation |

---

## Critical Rules (Always Apply)

1. **No dataset modification** - validation is read-only on SDTM datasets. Findings are recorded in `_validation_cdisc_core`, but the datasets are never changed by this skill (that is handled by re-projection in `cdisc-submission-projection`).
2. **All violations recorded** - no violation is suppressed or discarded. Every Error, Warning, Info is captured with full context (affected rows, remediation).
3. **Error level = submission blocker** - all Error-level violations must be resolved before submission handoff; a single unresolved Error gates conformance sign-off.
4. **CDISC CORE rules are canonical** - rule violations surface the CDISC standard interpretation; do not override or reinterpret rules without documented exception process.
5. **Remediation is traceable** - each violation has a recorded remediation action (assigned to owner, target date, status). Track in `_validation_cdisc_core` via remediation_status field.
6. **API key optional** - open-rules (free) are sufficient for most submissions. CDISC Library API key is optional; behavior is documented both with and without it.
7. **Version alignment** - CDISC CORE rule version, SDTMIG version (3.2/3.3/3.4), SDTM model version (v1.4/v1.7/v2.0), and CDISC Controlled Terminology version must be compatible and documented in conventions.yml.
8. **Audit trail** - record in `_audit_cdisc_conformance_validation` the rule-set version, validation timestamp, # datasets validated, # violations found, conformance score, and conformance sign-off status.
9. **FK resolution across domains** - USUBJID is the linking key; confirm every USUBJID in non-DM domains exists in DM before declaring conformance.
10. **No truncation** - full affected-rows list is preserved in `_validation_cdisc_core` (as JSON); no summary truncation that loses drill-down capability.

---

## Handling Missing CDISC Library API Key

If the customer does not have or does not provide a CDISC Library API key:

1. **Use open-rules only** - conform to cdisc-open-rules (free, sufficient for most submissions).
2. **Document the limitation** - in the conformance report, note that full CDISC Library metadata checks are not available. This is acceptable for most regulatory submissions.
3. **Offer upgrade path** - if the customer later obtains an API key, run conformance validation again with full rules (incremental, not re-running all checks).
4. **Scorecard notation** - flag in the conformance scorecard which rule set was used, so remediation teams know what was validated.

---

## Submission Readiness Gate

Before declaring submission-ready:

1. **All Errors resolved** - `_validation_cdisc_core` contains no unresolved Error-level violations.
2. **Warnings acknowledged** - each Warning has been reviewed and either resolved or accepted with documented justification.
3. **Scorecard signed** - a responsible party (Data Manager, Statistical Programmer, Quality Assurance) has reviewed the scorecard and approved submission.
4. **Audit trail complete** - `_audit_cdisc_conformance_validation` and `_validation_cdisc_core` are auditable and reproducible (source rule-set versions documented).

---

## What This Skill Does Not Do

- **Does not modify SDTM datasets** - validation only. Remediation requires re-projection via `cdisc-submission-projection`.
- **Does not generate new SDTM variables** - only flags missing or invalid values.
- **Does not reinterpret CDISC standards** - conformance is based on cdisc-open-rules or CDISC Library rules as-is, not custom reinterpretations.
- **Does not handle data-privacy or de-identification** - validation is business-logic focused, not privacy-focused.
- **Supports SDTMIG versions 3.2, 3.3, 3.4** (with paired SDTM v1.4, v1.7, v2.0 respectively) - configured via conventions.yml. Other SDTMIG versions require manual rule-set adaptation.

---

## Regulatory Context

CDISC CORE validation per this skill ensures SDTM datasets conform to:
- **CDISC SDTM Implementation Guide (SDTMIG 3.2, 3.3, or 3.4)** - the FDA-accepted standard (SDTMIG 3.2 or later).
- **CDISC Controlled Terminology** - standardized enumeration values.
- **Define-XML 2.1** (FDA accepts 2.0 and 2.1) - submission metadata.

Validated datasets are audit-ready for FDA/EMA review and submission.

