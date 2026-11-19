---
name: cdisc-terminology-load
description: Load CDISC Controlled Terminology from NCI EVS (free) and LOINC into the clinical_trials model's codelist/codelist_term and terminology products. Use when populating reference data for study-design enums (arm type, epoch type, objective type, etc.), SDTM domain/variable codelists for submission, data-collection enum columns (sex, race, route of administration, etc.), and domain hierarchies (MedDRA, WHO-Drug, SNOMED CT - customer-supplied files only). Handles package versioning, SCD, and consistency with the suite's conventions. Read-only on source files, write to terminology products only. Not for data ingestion or ontology reasoning - use cdisc-submission-projection for SDTM mapping.
---

# CDISC Terminology Load Skill

> **Prerequisites:** This skill works against a Databricks workspace with the clinical_trials v2 model (or v1 with vibe-generated v2 metamodel). It reads CDISC Controlled Terminology from NCI EVS (quarterly packages, free) and LOINC (free), and customer-supplied licensed dictionaries (MedDRA, WHO-Drug, SNOMED CT). Load `autonomous-validation` alongside this skill to govern execution discipline and batch validation (not automatic; load explicitly).

## Overview

This skill provides guidance for loading CDISC Controlled Terminology and clinical coding dictionaries into the clinical_trials model's terminology products. CDISC Controlled Terminology is the submission-aligned enumeration of valid values for clinical data (e.g. sex, race, adverse event outcome, study arm type); NCI EVS (free) and LOINC (free) are the canonical, versioned sources. Licensed dictionaries (MedDRA, WHO-Drug, SNOMED CT) are ingested from customer-supplied files only, never downloaded. Terminology is loaded in layers: CDISC CT first (NCI EVS + LOINC), then optional licensed layers (if customer supplies them), with full audit trail and SCD handling for version upgrades.

**What this skill produces:**
- **CDISC Controlled Terminology ETL notebook** - loader that fetches or accepts the quarterly NCI EVS CDISC CT package (or customer-supplied Excel/text files), parses LOINC CSV, validates structure, and populates `codelist` and `codelist_term` products with NCI C-codes, submission values, synonyms, extensibility flags, and package/version metadata.
- **Licensed dictionary reference loaders** (optional) - guidance for loading MedDRA (SOC, HLGT, HLT, PT, LLT, SMQ hierarchy), WHO-Drug Global (drug record, preferred name, ATC hierarchy), and SNOMED CT from customer-supplied files only (never downloaded). Free dictionaries (CTCAE from NCI, ICD-10-CM from US, WHO ICD-10) are loaded if provided.
- **Terminology products (structured)** - `codelist` (one row per CDISC or dictionary codelist/scheme), `codelist_term` (one row per valid value with NCI C-code, synonyms, extensibility), plus `code_system` and `code_system_version` for all dictionaries (MedDRA, WHO-Drug, SNOMED, LOINC, CTCAE, ICD-10).
- **Package versioning** - each CDISC CT package loads under its own `package_version` (part of every codelist and term key), so a new quarterly package sits next to the earlier ones and data collected under an older package keeps resolving to its terms.
- **Crosswalk registry** - for each terminology product (CDISC CT, MedDRA, WHO-Drug, etc.), record which study or SDTM variable uses it, so data stewards can assess impact of terminology updates.
- **Validation report** - checks that all required CDISC CT codelists are present, all referenced LOINC codes resolve, all MedDRA PTs are unique within HLGT, WHO-Drug hierarchy is acyclic, SNOMED CT relationships are bidirectional (where applicable).
- **docs/commentary/cdisc-terminology-load-improvement-recommendations.md** - emitted at closeout (skill-improvement recommendations, following `autonomous-validation/commentary-protocol.md`).

**Scope:** CDISC Controlled Terminology from NCI EVS (free quarterly packages) and LOINC (free). Licensed dictionaries (MedDRA, WHO-Drug, SNOMED CT) are customer-supplied only and never downloaded. Free dictionaries (CTCAE from NCI, ICD-10-CM from US public domain, WHO ICD-10) are loaded if customer provides them. Full versioning and audit trail to support CDISC submission audits. Handles SCD (slowly changing dimensions) - terminology versions are tracked with effective/end dates or version flags.

---

## When to Load This Skill

Load when:
- Populating study-design enums (arm type, epoch type, objective type, endpoint type, intervention type, visit type, activity type, etc.) from CDISC Controlled Terminology
- Preparing for SDTM submission (all SDTM domain and variable codelists must be in place before projection)
- Setting up reference data for data-entry validation (e.g. sex, race, route of administration, dose units)
- Ingesting MedDRA or WHO-Drug to support adverse-event and concomitant-medication coding
- Updating terminology to a newer CDISC CT package version (quarterly releases from NCI EVS)
- Auditing data against terminology versions at the time of collection (e.g. which MedDRA version was current when this lab result was recorded)
- Creating a crosswalk between study enums and submission codelists

Do NOT load for:
- General reference-data ingestion unrelated to CDISC standards
- Ad-hoc enumeration management (use simple lookup tables instead)
- Ontology reasoning or hierarchical searches (terminology is reference data, not reasoning engine)
- Biomedical data ingestion (use `etl-development-framework`)
- SDTM projection or submission format generation (use `cdisc-submission-projection`)

---

## Execution Model

### Phase 0 - Setup & Package Discovery

1. **Locate the terminology products** - resolve `datamanagement.codelist`, `datamanagement.codelist_term`, `terminology.code_system` and `terminology.code_system_version` from `_metamodel` tables; confirm they exist, and list the CDISC CT package versions already loaded.
2. **Identify the source packages** - determine which packages to load:
   - **CDISC CT from NCI EVS (free)** - quarterly Excel/XML files from NCI EVS (https://evs.nci.nih.gov); latest version is the default unless a specific quarter is requested.
   - **LOINC (free)** - CSV download from LOINC.org; latest version is the default.
   - **Licensed dictionaries** - ask the user whether to load MedDRA / WHO-Drug / SNOMED CT; if yes, confirm the source file location (workspace volume path or Git artifact store); if no, skip.
3. **Resolve versioning** - for each package, record the release date, version code (e.g. NCI EVS Q4 2024, MedDRA v28.1, LOINC 2.77). This is a HITL gate - confirm package choices before proceeding.
4. **Check for collisions** - query `codelist` by `package_version` to detect whether this exact package is already loaded; if yes, the load is a no-op (the keys are deterministic, so the MERGE is idempotent). A different package loads side by side under its own `package_version`, so data collected under an older package keeps resolving to its terms. Record the disposition.

### Phase 1 - Fetch and Parse CDISC CT (NCI EVS)

1. **Obtain the NCI EVS CDISC CT package** - either download `SDTM Terminology.txt` (tab-delimited) from https://evs.nci.nih.gov/ftp1/CDISC/SDTM/ or accept a customer-supplied copy with the same header row. Document the source URL, package release date and file SHA-256.
2. **Parse the package** - the file has one row per codelist (empty `Codelist Code`) and one row per term. Extract:
   - **Codelists** - e.g. C66731 (SEX), C66781 (AGEU), C99079 (EPOCH), C66737 (TPHASE). For each codelist, record the NCI C-code, short name, codelist name, definition and extensibility (Yes/No).
   - **Codelist terms** - e.g. within C66731 (SEX), the terms F, INTERSEX, M and U. For each term, record the submission value (the string used in SDTM), NCI C-code, NCI preferred term, synonyms and definition.
   - **SDTM domain abbreviations** - codelist C66734 (DOMAIN), e.g. AE (C49562), CM (C49568), DM (C49572), which feed `sdtm_domain_spec` + `sdtm_variable_spec`.
3. **Load into the model's tables** - `datamanagement.codelist` and `datamanagement.codelist_term`, with deterministic BIGINT keys; see `nci-evs-cdisc-ct-ingest.md` for the column mapping and the MERGE statements.
4. **Validate** - confirm every codelist has >= 1 term, all submission values are non-null, and submission values are unique within a codelist.

### Phase 2 - Fetch and Parse LOINC

1. **Obtain the LOINC CSV file** - download from LOINC.org (https://loinc.org/downloads/) or accept a customer-supplied copy. Document version (e.g. LOINC 2.77, released 2024-12-15).
2. **Parse the LOINC CSV** - extract the canonical LOINC code, long common name, short name, property, component, method, unit, and related attributes. Scope to active codes (status = "ACTIVE").
3. **Map to terminology products** - for each LOINC code, decide whether to:
   - Create a `codelist` entry (if LOINC is used for collection/mapping in this study or submission).
   - OR reference it as a `biomedical_concept` in the study domain (if it identifies a clinical concept without a CDISC submission codelist).
   - Most commonly, LOINC is used for lab result variable names (`cdash_loinc_code`, `sdtm_loinc_reference`) - see `sdtm_variable_spec` in `cdisc-submission-projection`.

### Phase 3 - Optional: Load Licensed Dictionaries

Licensed dictionaries are provided by the customer (they own the license). The skill does NOT download or embed content. Instead:

#### MedDRA (if customer supplies)

1. **Verify license** - ask the user to confirm they have a valid MedDRA license.
2. **Accept the customer file** - expect a delimited file (tab or comma-separated) with the MedDRA hierarchy:
   - **Structure columns:** SOC_Code, SOC_Term, HLGT_Code, HLGT_Term, HLT_Code, HLT_Term, PT_Code, PT_Term, LLT_Code, LLT_Term, Preferred_Name, etc.
   - Validate that codes are unique within their level (all PT_Codes are unique, all LLT_Codes are unique, etc.).
3. **Normalize into terminology products** - insert into `code_system` (name='MedDRA', version=customer-supplied version), then into `code_system_version` (version_id, version_code, release_date). For each hierarchy level (SOC, HLGT, HLT, PT, LLT, SMQ), insert into a hierarchy table (not shown here; design per customer's use case). Record SMQ relationships if present.
4. **Type-2 SCD** - if MedDRA version changes, mark old codes as expired (end_date = load date, current_version_flag = false) and insert new codes (effective_date = load date, current_version_flag = true).

#### WHO-Drug Global (if customer supplies)

1. **Verify license** - ask the user to confirm they have a valid WHO-Drug license.
2. **Accept the customer file** - expect WHO-Drug database dump or CSV with:
   - **Drug record:** Drug Record Number, Preferred Name, ATC Classification Level 1-4, Route of Administration, Dose Form, Strength, etc.
   - Validate drug-record uniqueness and ATC hierarchy acyclicity.
3. **Normalize into terminology products** - insert into `code_system` (name='WHO-Drug', version), `code_system_version`, and hierarchy tables. Map WHO-Drug routes of administration to CDISC CT route equivalents where they exist.

#### SNOMED CT (if customer supplies)

1. **Verify license** - ask the user to confirm they have a valid SNOMED CT license.
2. **Accept the customer file** - expect the SNOMED CT release file (typically RF2 format) with concepts, descriptions, and relationships. Validate concept uniqueness and relationship acyclicity (where applicable).
3. **Normalize into terminology products** - scope to clinically relevant concepts (e.g. clinical findings, disorders, procedures, substances) used in the study. Insert into `code_system`, `code_system_version`, and hierarchy tables as needed.

#### CTCAE (Cancer Therapy Evaluation Criteria, if used - Free/Public)

1. **Source** - CTCAE is freely available from the National Cancer Institute. Download from NCI or accept customer copy.
2. **Parse CTCAE hierarchy** - extract adverse-event categories (e.g. Cardiac, Dermatology, Gastrointestinal) and severity grades (Grade 1-5). For each category x severity, record the definition.
3. **Normalize into terminology products** - insert into `code_system` (name='CTCAE', version), then hierarchy.

#### ICD-10 (if used - Free/Public, varies by region)

1. **Source** - ICD-10-CM (US) is public domain; WHO ICD-10 has its own terms and licensing. Accept customer-provided files.
2. **Parse ICD-10 codes** - extract diagnosis codes and their descriptions.
3. **Normalize into terminology products** - insert into `code_system` (name='ICD-10' or 'ICD-10-CM', version), with hierarchy (ICD-10 is not deeply hierarchical; it is primarily a flat code list).

### Phase 4 - Validate & Reconcile

1. **Schema validation** - confirm all required CDISC CT codelists are present (study-design enums, SDTM domain/variable codelists, data-collection enums).
2. **Uniqueness checks** - within each codelist, confirm submission values are unique; within MedDRA, confirm PT codes are unique; within WHO-Drug, confirm Drug Record Numbers are unique.
3. **Hierarchy validation** - MedDRA: SOC -> HLGT -> HLT -> PT -> LLT must be acyclic and tree-structured (no lateral links). WHO-Drug: ATC 1 -> 2 -> 3 -> 4 must be acyclic.
4. **FK resolution** - if CDISC CT is mapped to study-design enums (e.g. arm.type_codelist_term_id references codelist_term.codelist_term_id), confirm all study values exist in codelist_term.
5. **Reconciliation to prior version** (if applicable) - if a prior terminology package exists:
   - Flag codelists/terms that were removed (may break downstream data if deprecated).
   - Flag codelists/terms that were added (new capability).
   - Flag submission-value changes (dangerous for SDTM, as it breaks variable mappings).
6. **Emit scorecard** - row count per codelist, # unique study-design enums mapped, # licensed-dictionary hierarchies loaded, integrity score (0-100%).

---

## Reference Files

| File | Content |
|---|---|
| `nci-evs-cdisc-ct-ingest.md` | How to fetch the NCI EVS CDISC CT package, parse XML/Excel, validate schema, load into codelist/codelist_term products |

---

## Critical Rules (Always Apply)

1. **NCI EVS and LOINC are free and canonical** - always fetch/accept official sources, never synthesize terminology.
2. **Never download or embed licensed dictionaries** - MedDRA, WHO-Drug, SNOMED CT content is never shipped; customers load it if licensed.
3. **Validate schema before loading** - confirm all codelists have >= 1 term, all submission values are non-null, all codes are unique within scope.
4. **Versioned loads for package upgrades** - load a new CDISC CT package under its own `package_version` and never overwrite an earlier package's rows in place; licensed dictionaries version through `terminology.code_system_version`.
5. **Audit trail on every load** - record in `_audit_terminology_load` or equivalent the source package, version, load timestamp, file hash, and row counts.
6. **No hardcoded product names** - all terminology products (codelist, codelist_term, code_system, code_system_version) must be resolved from `_metamodel` or `information_schema`, never assumed.
7. **Hierarchy validation before insert** - MedDRA and WHO-Drug hierarchies must be acyclic; confirm with topological-sort pre-check before loading.
8. **FK resolution to study/SDTM** - before declaring success, confirm that all study-design enums (arm_type, epoch_type, etc.) and SDTM variables that reference terminology have valid codelist_term entries.
9. **Submission-value immutability** - within a codelist, submission values must never change across versions (breaking change). Flag if they do and halt.
10. **Document missing dictionaries** - if a study uses MedDRA or WHO-Drug but the customer does not supply files, clearly document the gap and do not synthesize content.

---

## CDISC CT Codelist Scope (Minimum Required)

At minimum, the following CDISC CT codelists must be loaded for a clinical trial study:

**Study-design enums (from USDM):**
- C66736: StudyArmType (ACTIVE_COMPARATOR, PLACEBO, CONTROL, TREATMENT, etc.)
- C71113: EpochType (SCREENING, ENROLLMENT, TREATMENT, FOLLOW_UP, etc.)
- C74456: ObjectiveType (PRIMARY, SECONDARY, EXPLORATORY, SAFETY, etc.)
- C74457: EndpointType (PRIMARY, SECONDARY, EXPLORATORY, SAFETY, PHARMACOKINETIC, PHARMACODYNAMIC, etc.)
- C74458: InterventionType (DRUG, DEVICE, PROCEDURE, BEHAVIORAL, DIETARY_SUPPLEMENT, BIOLOGICAL, etc.)
- C96553: VisitType (SCREENING, BASELINE, TREATMENT, FOLLOW_UP, etc.)
- C71113: ActivityType (ASSESSMENT, TREATMENT, LAB_COLLECTION, ECG, VISIT, etc.)
- C66729: EncounterType (Study Visit, Telephone Visit, etc.)
- C66733: PopulationType (ENROLLED, SCREENED, RANDOMIZED, ITT, PER_PROTOCOL, SAFETY, etc.)

**SDTM domain and variable codelists:**
- C71113: Domain Names (SDTM domain names: AE, LB, VS, etc.)
- C71114-C71120+: SDTM variable-specific codelists (for each domain, the codelists referenced by SDTM variables)
  - Examples: C66780 (Sex), C66781 (Race), C66782 (Ethnicity), C66783 (Route of Administration), C66784 (Dose Form), C66785 (Units), C66786 (Adverse Event Outcome), C66787 (Adverse Event Action Taken), C66788 (Disposition Event), etc.

**Submission-related enums:**
- C66779: Study Phase (PHASE_1, PHASE_2, PHASE_3, PHASE_4, etc.)
- C66730: Study Type (INTERVENTIONAL, OBSERVATIONAL, EXPANDED_ACCESS, etc.)

---

## No Em-Dashes

This document and all produced artifacts (notebooks, reports, reference tables) must not contain em-dashes (U+2014). Use hyphens (-) or rewrite as needed.

