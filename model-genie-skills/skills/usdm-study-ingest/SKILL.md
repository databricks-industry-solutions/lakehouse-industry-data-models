---
name: usdm-study-ingest
description: Ingest CDISC USDM (Unified Study Definitions Model) study definitions in DDF JSON format into the clinical_trials model's study domain. Use when loading a clinical protocol from USDM source to populate study_version, study_design, arm, epoch, study_cell, study_element, schedule_timeline, scheduled_activity_instance, encounter, activity, biomedical_concept, study_identifier, governance_date, population, cohort, study_intervention, intercurrent_event and estimand products. Also useful for prototyping study hierarchies, validating the schema against DDF-RA v4, and binding USDM class implementations to model products via metadata tags. Read-only on source, write to study domain products only. Not for bronze ingestion or general ETL - use etl-development-framework. Not for SDTM projection - use cdisc-submission-projection.
---

# USDM Study Ingest Skill

> **Prerequisites:** This skill works against a Databricks workspace with the clinical_trials v2 model (or v1 with vibe-generated v2 metamodel). It reads CDISC DDF reference architecture v4 JSON study definitions from a source location (workspace volume or Git-based artifact store) and writes to the study domain. Load `autonomous-validation` alongside this skill to govern execution discipline and batch validation (not automatic; load explicitly).

## Overview

This skill provides guidance for ingesting clinical study definitions authored in the CDISC Unified Study Definitions Model (USDM) format into the normalized study products of the clinical_trials model. USDM is a data-driven specification for the clinical study protocol, aligned to ICH M11 (the structured clinical study protocol template) and the regulatory submission pathway; ingesting it as structured metadata populates the study domain and establishes the single source of truth for protocol structure that all downstream biomedical, operational and submission data trace back to.

**What this skill produces:**
- **Study domain ETL notebook** - a loader that parses DDF v4 JSON study definitions using the `usdm` Python package, validates against the JSON schema, maps USDM classes to study domain products, and emits MERGE/INSERT statements to land the protocol structure (study versions, arms, epochs, elements, interventions, objectives, endpoints, estimands, intercurrent events, populations, cohorts, eligibility criteria, visits, activities, encounters, governance dates, study identifiers).
- **USDM-to-products mapping reference** - a cross-reference table describing how each USDM class and attribute (StudyVersion, StudyDesign, StudyArm, StudyEpoch, StudyCell, StudyElement, ScheduleTimeline, ScheduledActivityInstance, Encounter, Activity, BiomedicalConcept, StudyIdentifier, GovernanceDate, Population, Cohort, StudyIntervention, Estimand, IntercurrentEvent, Objective, Endpoint, EligibilityCriterion) lands in the model's products and columns, including resolution of nested and referenced structures.
- **Validation report** - checks that the JSON conforms to DDF-RA v4 schema, all StudyVersion, StudyArm, StudyEpoch IDs resolve uniquely within the study, all StudyCell and StudyElement references are valid, and all FK constraints are satisfiable before writing.
- **Reconciliation notebook** - compares the study protocol loaded to a prior load (if any exists), flags changes in structure (new arms, removed epochs, design modifications) and captures changes in metadata (sponsor, study title, protocol version).
- **Study metadata registry** - a `_audit_usdm_ingest` table recording the USDM package version, DDF-RA schema version, load timestamp, source file path/hash, and row counts per product so protocol loads are reproducible and auditable.
- **docs/commentary/usdm-study-ingest-improvement-recommendations.md** - emitted at closeout (skill-improvement recommendations, following `autonomous-validation/commentary-protocol.md`).

**Scope:** USDM JSON study definitions in DDF reference architecture v4 format (free, published by cdisc-org). Parses and validates using the `usdm` Python package (pip install usdm). Writes to study domain products only - does not modify biomedical data collection products (subject, trial_subject, adverse_event, etc.) or the SDTM submission layer. Handles multi-version studies (same protocol, iterative refinements) with a study_version surrogate key and historical tracking. Licensed dictionaries (MedDRA, WHODrug, SNOMED) are never downloaded or embedded; references to them are populated from DDF as-is.

---

## When to Load This Skill

Load when:
- A clinical study protocol is available in CDISC USDM JSON format (DDF-RA v4) and needs to be loaded into the study domain
- Prototyping or validating a study hierarchy (arms, epochs, elements, timelines, activities, encounters)
- Establishing the study-design single source of truth before biomedical-data ingestion
- Comparing iterative protocol updates (protocol version changes, structural refinements)
- Binding study metadata to USDM class/attribute references for submission audit trail
- Auditing the protocol structure before submission-data collection begins
- Re-loading a protocol after a schema update or package version upgrade

Do NOT load for:
- General JSON parsing or schema validation unrelated to a clinical study protocol
- SDTM/ADaM dataset generation - use `cdisc-submission-projection` instead
- Biomedical data ingestion (adverse events, labs, visits as data collection) - use `etl-development-framework`
- Editing study definitions in place - load the updated DDF JSON and re-run this skill
- Mapping study data to controlled terminology - use `cdisc-terminology-load` for dictionaries, then reference in the data layer

---

## Execution Model

### Phase 0 - Setup & Validation

1. **Locate the study domain schema** - resolve the study domain's products from the `_metamodel` tables; query `information_schema` to confirm `study_version`, `study_design`, `arm`, `epoch`, `study_cell`, `study_element`, `schedule_timeline`, `scheduled_activity_instance`, `encounter`, `activity`, `biomedical_concept`, `study_identifier`, `governance_date`, `population`, `cohort`, `study_intervention`, `estimand`, `intercurrent_event`, `objective`, `endpoint`, `eligibility_criterion` tables exist and are empty or have historical rows.
2. **Retrieve the DDF v4 JSON study definition** - typically provided as a file in a workspace volume or Git artifact store. Record the source path, file hash and package version.
3. **Validate JSON schema** - validate the input against the pinned DDF-RA v4 USDM JSON schema (cdisc-org/DDF-RA) and confirm compliance; halt if schema errors exist and report them plainly.
4. **Ensure unique StudyVersion, StudyArm, StudyEpoch, StudyCell, StudyElement IDs** - query the existing study products to check for ID collisions; if a study_version_id already exists, decide whether to insert a new version (append) or replace (merge). This is a HITL gate - surface the choice and record the disposition.

### Phase 1 - Map USDM Classes to Products

For each USDM class, map its attributes to the study domain products:

| USDM Class | Target Product | Key Attributes | Notes |
|---|---|---|---|
| StudyVersion | `study_version` | studyVersionId, version, title, rationale, sponsorName, briefSummary | Surrogate PK from vibe model; record USDM class/version in metadata tag |
| StudyDesign | (joins `study_design`) | designType (interventional/observational), masterProtocolType | Enum; linked from study_version |
| StudyArm | `arm` | studyArmId, armType, label | Linked to study_version_id; enumerate all arms before populating cells |
| StudyEpoch | `epoch` | studyEpochId, epochType, label, description | Linked to study_version_id; enumerate all epochs before populating cells |
| StudyCell | `study_cell` | (composite of arm_id + epoch_id) | Cell is the cross-product of arm x epoch; cardinality = # arms x # epochs |
| StudyElement | `study_element` | studyElementId, elementType, label, description | Linked to study_cell; describes what happens in a cell (e.g. treatment, washout, follow-up) |
| ScheduleTimeline | `schedule_timeline` | timelineId, description | Linked to study_element; defines when activities occur |
| ScheduledActivityInstance | `scheduled_activity_instance` | activityId, timelineId, activityType, plannedActivityStartRelativeToEpoch, plannedActivityEndRelativeToEpoch | Linked to timeline; captures the planned occurrence of activities (assessments, treatments, visits) |
| Encounter | `encounter` | encounterId, label, type | Protocol-level planned encounters (study visits, treatment visits); linked to schedule_timeline |
| Activity | `activity` | activityId, label, activityType, description | Represents what is done during a visit (assessment, treatment, lab); linked to encounter |
| BiomedicalConcept | `biomedical_concept` | biomedicalConceptId, conceptType, label, definition | Generic holder for measured/assessed concepts referenced by objectives, endpoints, assessments |
| StudyIdentifier | `study_identifier` | studyIdentifierId, identifierValue, organizationIdentifier, studyIdentifierType | Registry identifiers (NCT, EU CT number, IND, EUDRA) and their issuing org; linked to study_version_id |
| GovernanceDate | `governance_date` | dateId, dateValue, dateType, description | Protocol version dates (submission, approval, effective, amendment dates) |
| Population | `population` | populationId, label, description | Study-level population definition (e.g. "all enrolled subjects"); linked to study_version_id |
| Cohort | `cohort` | cohortId, label, description, populationId | Subgroup of population (e.g. "males age 18-65"); may be nested; linked to population_id |
| StudyIntervention | `study_intervention` | interventionId, interventionType, label, description | Study-level intervention definition (drug, device, procedure); linked to study_version_id |
| Estimand | `estimand` | estimandId, label, description, populationId, analysisSetId | SAP link; captures analysis target population, treatment, intercurrent-event strategy |
| IntercurrentEvent | `intercurrent_event` | intercurrentEventId, description, intercurrentEventType, populationId | Events after trial start that affect estimand strategy (death, permanent withdrawal, major protocol violation) |
| Objective | `objective` | objectiveId, label, description, objectiveType | Trial objective (primary/secondary/exploratory) linked to endpoints |
| Endpoint | `endpoint` | endpointId, label, description, endpointType, variableId | Trial endpoint (primary/secondary/exploratory); references biomedical_concept(s) |
| EligibilityCriterion | `eligibility_criterion` | criterionId, label, description, criterionType | Inclusion/exclusion criteria linked to population_id |

### Phase 2 - Load USDM Data

1. **Parse DDF JSON** - use the usdm package to deserialize the JSON into USDM model classes (specific class names depend on the package version; consult the usdm README or source).
2. **Flatten and denormalize** - for nested structures (e.g. arms within design, elements within cells, activities within timelines), flatten into rows and resolve FKs.
3. **Resolve all references** - ensure every arm references a valid study_version, every element references a valid cell (which itself references valid arm + epoch), every activity references a valid encounter/timeline.
4. **Build foreign-key graph** - construct a dependency DAG (study_version -> arms -> cells -> elements -> activities; study_version -> populations -> cohorts; study_version -> interventions; estimand -> intercurrent_event). Topologically sort to determine load order (no circular deps allowed).
5. **Stage into merge-ready temp tables** - deduplicate on natural keys (study_version_id, arm_id within version, etc.) and MERGE or INSERT into study domain products. Use Type-1 SCD if study_version_id exists (update metadata), Type-2 if this is a new version.
6. **Record audit trail** - insert into `_audit_usdm_ingest` the source file path, DDF-RA version, package version, load timestamp, and row counts.

### Phase 3 - Validate & Reconcile

1. **Post-load FK validation** - query each foreign key to ensure no orphans (e.g. every study_cell references valid arm + epoch).
2. **Cardinality checks** - confirm # study_cells = # study_arms x # study_epochs; confirm # scheduled_activity_instances >= # encounters.
3. **Unique constraint enforcement** - confirm study_version_id, arm_id, epoch_id, study_element_id, encounter_id, activity_id are unique within their scope (study_version).
4. **Enumeration exhaustiveness** - confirm all protocol-level enums (designType, armType, epochType, activityType, objectiveType, interventionType, criterionType) map to valid CDISC CT codelists (populate from `codelist` product after `cdisc-terminology-load` runs).
5. **Reconciliation to prior load** (if exists) - run a diff between current and prior load: flag new arms/epochs/elements, removed arms/epochs/elements, changes in metadata (title, brief summary, sponsor). Write to `reconciliation_notebook.md`.
6. **Emit scorecard** - row count per product, # unique versions, # unique arms/epochs/cells/elements, integrity score (0-100% based on FK/uniqueness checks).

---

## Reference Files

| File | Content |
|---|---|
| `usdm-ddf-mapping.md` | **Mapping table** - every USDM class, its attributes, target product, and column mapping; version aligned to DDF-RA v4 and the clinical_trials v2 vibe model |
| `phase-0-schema-setup.md` | Setup queries: resolve study domain products from `_metamodel`, confirm empty or historical state, check for study_version_id collisions |

---

## Critical Rules (Always Apply)

1. **Validate DDF-RA v4 schema before loading** - use the usdm package (via pip) to validate the input JSON against the DDF-RA v4 JSON schema; halt and report any schema errors plainly.
2. **Unique study_version_id within study** - decide at HITL gate whether to append a new version or replace the existing one; record the disposition in the manifest.
3. **Topological sort required** - do not attempt to load in arbitrary order; study_version must precede all dependent entities, and arms/epochs must precede cells.
4. **No orphaned foreign keys** - every arm/epoch/cell/element/activity must reference valid parent(s); confirm pre-insertion with a FK check; halt and report orphans.
5. **Resolve all USDM references** - nested structures (arms inside design, elements inside cells) must be fully dereferenced; circular references are errors.
6. **Metadata tags on products** - record USDM class, DDF-RA version and package version as column or table tags for audit trail and reproducibility.
7. **No hardcoded schema names** - all study domain product names must be resolved from `_metamodel` or `information_schema`, never assumed.
8. **Type-1 SCD for protocol updates** - if study_version_id already exists, update metadata fields; do not create duplicate versions for the same version_id.
9. **Load order gate** - confirm all dependencies are satisfied before MERGE/INSERT; use the topological sort as the mandatory load sequence.
10. **Audit trail every load** - record in `_audit_usdm_ingest` the source, schema versions, package version, timestamp and row counts so future loads are repeatable.

---

## Handling Licensed Dictionaries

MedDRA, WHODrug and SNOMED CT are licensed by the customer. This skill does not download, embed or validate content from these dictionaries. When USDM references them (e.g. in study_element descriptions that mention a MedDRA PT or a route of administration that is a WHODrug code):

- **Capture references as-is** - store the reference term / code / description verbatim from the USDM JSON.
- **Do not validate against the dictionary** - wait for the customer to run `cdisc-terminology-load` with their licensed content.
- **Tag for downstream reconciliation** - mark any study element or description that references a licensed concept with a note (e.g. `_references_meddra`, `_references_whodrug`) so a later step can validate the reference after the dictionary is loaded.

---

## Binding to clinical_trials v2 Products (Via _metamodel)

The skill must resolve all product names from the model's `_metamodel` tables, not assume hardcoded names. When querying the metamodel to discover the study domain:

```sql
SELECT product, description, vibe_class 
FROM {metamodel_schema}.vibe_metamodel_product 
WHERE domain = 'study' AND version = (SELECT MAX(version) FROM {metamodel_schema}.vibe_metamodel_product WHERE domain = 'study')
```

If the metamodel is missing a study product (e.g. `study_cell` or `intercurrent_event` in v1), the skill must:
1. Report the gap plainly: "study_cell product not found in metamodel."
2. Offer two paths: (a) defer the load until the model is updated, or (b) run the vibe-model agent to extend the model to v2, then re-run this skill.
3. Never synthesize a product definition; always halt and surface the gap.

---

## What This Skill Does Not Do

- **Does not modify existing biomedical data** (adverse events, labs, visits as observations). The study domain is protocol metadata only.
- **Does not generate SDTM or ADaM datasets** - see `cdisc-submission-projection` for that.
- **Does not validate biomedical data against the protocol** (e.g. checking that collected visits conform to schedule_timeline). That happens downstream during data-quality validation.
- **Does not download or embed MedDRA, WHODrug or SNOMED CT content** - see "Handling Licensed Dictionaries" above.
- **Does not edit the study protocol in place** - re-run with an updated DDF JSON.
