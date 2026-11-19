# NCI EVS CDISC Controlled Terminology Ingest

This document describes how to fetch the CDISC Controlled Terminology from NCI EVS (free, quarterly packages) and load it into the clinical_trials v2 model's `datamanagement.codelist` and `datamanagement.codelist_term` products. The model already creates both tables; this guide loads them and never creates its own copies.

## The two target tables

`codelist` holds one row per CDISC codelist; `codelist_term` holds one row per term of a codelist. Every Controlled Terminology foreign key in the model (for example `subject.demographic.sex_codelist_term_id` or `safety.adverse_event.adverse_severity_codelist_term_id`) points at `codelist_term.codelist_term_id`.

| Table | Column | Type | Loaded from (NCI EVS file column) |
|---|---|---|---|
| codelist | codelist_id | BIGINT | `xxhash64(Code, package_version)` |
| codelist | cdisc_standard_id | BIGINT | the `cdisc_standard` row of the package (for example SDTM) |
| codelist | nci_codelist_code | STRING | `Code` |
| codelist | short_name | STRING | `CDISC Submission Value` |
| codelist | codelist_name | STRING | `Codelist Name` |
| codelist | codelist_description | STRING | `CDISC Definition` |
| codelist | extensibility_flag | BOOLEAN | `Codelist Extensible (Yes/No)` = `Yes` |
| codelist | package_version | STRING | the package release date, for example `2026-09-25` |
| codelist_term | codelist_term_id | BIGINT | `xxhash64(Codelist Code, Code, package_version)` |
| codelist_term | codelist_id | BIGINT | `xxhash64(Codelist Code, package_version)` |
| codelist_term | nci_concept_code | STRING | `Code` |
| codelist_term | submission_value | STRING | `CDISC Submission Value` |
| codelist_term | preferred_term | STRING | `NCI Preferred Term` |
| codelist_term | decoded_value | STRING | `NCI Preferred Term` (override per sponsor convention if needed) |
| codelist_term | synonyms | STRING | `CDISC Synonym(s)` |
| codelist_term | definition | STRING | `CDISC Definition` |

The keys are deterministic, so a reload of the same package is idempotent. A term's key includes its codelist code because one NCI term can belong to several codelists (for example C17998 Unknown is in SEX and in other codelists). The package version is part of every key, so several packages can be loaded side by side and older collected data keeps resolving to the terms that were current when it was collected.

## Step 1: Obtain the NCI EVS CDISC CT package

NCI EVS publishes each quarterly package at https://evs.nci.nih.gov/ftp1/CDISC/SDTM/ as `SDTM Terminology.txt` (tab-delimited), with the same content as `.xls`, `.odm.xml`, `.pdf` and `.html`. Older packages are under `Archive/`. Use the `.txt` file: one header row, then one row per codelist and one row per term.

Its columns are:

| Column | On a codelist row | On a term row |
|---|---|---|
| Code | the codelist's C-code | the term's C-code |
| Codelist Code | empty | the C-code of the codelist the term belongs to |
| Codelist Extensible (Yes/No) | Yes or No | empty |
| Codelist Name | codelist name | codelist name |
| CDISC Submission Value | codelist short name (for example SEX) | submission value (for example M) |
| CDISC Synonym(s) | synonyms | synonyms |
| CDISC Definition | definition | definition |
| NCI Preferred Term | preferred term | preferred term |

Copy the file to a Unity Catalog volume and record the package release date and a SHA-256 of the file for the audit trail. A customer may supply the file instead; check it has the same header row.

## Step 2: Stage the file

```sql
CREATE OR REPLACE TEMPORARY VIEW ct_raw AS
SELECT *
FROM read_files(
  '{volume_path}/SDTM Terminology.txt',
  format => 'csv',
  sep => '\t',
  header => true,
  inferSchema => false
);

-- Sanity check: codelist rows have no Codelist Code, term rows do.
SELECT
  count_if(`Codelist Code` IS NULL OR `Codelist Code` = '') AS codelists,
  count_if(`Codelist Code` IS NOT NULL AND `Codelist Code` <> '') AS terms
FROM ct_raw;
```

## Step 3: Load `codelist`

```sql
MERGE INTO {catalog}.datamanagement.codelist AS t
USING (
  SELECT
    xxhash64(`Code`, '{package_version}')            AS codelist_id,
    {cdisc_standard_id}                              AS cdisc_standard_id,
    `Code`                                           AS nci_codelist_code,
    `CDISC Submission Value`                         AS short_name,
    `Codelist Name`                                  AS codelist_name,
    `CDISC Definition`                               AS codelist_description,
    `Codelist Extensible (Yes/No)` = 'Yes'           AS extensibility_flag,
    '{package_version}'                              AS package_version
  FROM ct_raw
  WHERE `Codelist Code` IS NULL OR `Codelist Code` = ''
) AS s
ON t.codelist_id = s.codelist_id
WHEN MATCHED THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;
```

`{cdisc_standard_id}` is the `datamanagement.cdisc_standard` row for the standard the package is published for (SDTM for `SDTM Terminology.txt`); insert that row first if it does not exist.

## Step 4: Load `codelist_term`

```sql
MERGE INTO {catalog}.datamanagement.codelist_term AS t
USING (
  SELECT
    xxhash64(`Codelist Code`, `Code`, '{package_version}') AS codelist_term_id,
    xxhash64(`Codelist Code`, '{package_version}')         AS codelist_id,
    `Code`                                                 AS nci_concept_code,
    `CDISC Submission Value`                               AS submission_value,
    `NCI Preferred Term`                                   AS preferred_term,
    `NCI Preferred Term`                                   AS decoded_value,
    `CDISC Synonym(s)`                                     AS synonyms,
    `CDISC Definition`                                     AS definition
  FROM ct_raw
  WHERE `Codelist Code` IS NOT NULL AND `Codelist Code` <> ''
) AS s
ON t.codelist_term_id = s.codelist_term_id
WHEN MATCHED THEN UPDATE SET *
WHEN NOT MATCHED THEN INSERT *;
```

## Step 5: Validate

```sql
-- Every term belongs to a loaded codelist (should return 0).
SELECT count(*) AS orphan_terms
FROM {catalog}.datamanagement.codelist_term t
LEFT JOIN {catalog}.datamanagement.codelist c USING (codelist_id)
WHERE c.codelist_id IS NULL;

-- Submission values are unique within a codelist (should return no rows).
SELECT c.short_name, t.submission_value, count(*) AS n
FROM {catalog}.datamanagement.codelist_term t
JOIN {catalog}.datamanagement.codelist c USING (codelist_id)
WHERE c.package_version = '{package_version}'
GROUP BY c.short_name, t.submission_value
HAVING count(*) > 1;

-- The codelists the model wires its foreign keys to are present, with terms.
SELECT c.short_name, c.nci_codelist_code, count(t.codelist_term_id) AS terms
FROM {catalog}.datamanagement.codelist c
LEFT JOIN {catalog}.datamanagement.codelist_term t USING (codelist_id)
WHERE c.package_version = '{package_version}'
  AND c.short_name IN ('SEX', 'AGEU', 'ROUTE', 'FRM', 'UNIT', 'OUT', 'ACN', 'AESEV', 'NCOMPLT', 'RACE', 'ETHNIC', 'RACEC', 'ETHNICC')
GROUP BY c.short_name, c.nci_codelist_code
ORDER BY c.short_name;
```

## Step 6: Record the audit trail

Record, per load, the package version, source file path, file SHA-256, row counts of `codelist` and `codelist_term` for that package version, and the load status, in an audit table of your choice (for example `{catalog}.datamanagement._terminology_load_audit`).

## Codelists the model wires to

The clinical_trials v2 model points these fields at `codelist_term`. Codes checked against the NCI EVS `SDTM Terminology.txt` package published 2026-09-25:

| Short name | NCI C-code | Codelist | Extensible | Model fields |
|---|---|---|---|---|
| SEX | C66731 | Sex | No | subject.demographic.sex_codelist_term_id |
| AGEU | C66781 | Age Unit | No | subject.demographic.age_unit_codelist_term_id |
| ROUTE | C66729 | Route of Administration Response | Yes | study.dosing_regimen.route_codelist_term_id, subject.concomitant_medication.route_codelist_term_id |
| FRM | C66726 | Dosage Form | Yes | study.dosing_regimen.dose_form_codelist_term_id, subject.concomitant_medication.dose_form_codelist_term_id |
| UNIT | C71620 | Unit | Yes | study.dosing_regimen.dose_unit_codelist_term_id, subject.concomitant_medication.dose_unit_codelist_term_id |
| OUT | C66768 | Outcome of Event | No | safety.adverse_event.adverse_outcome_codelist_term_id |
| ACN | C66767 | Action Taken with Study Treatment | No | safety.adverse_event.adverse_action_taken_codelist_term_id |
| AESEV | C66769 | Severity/Intensity Scale for Adverse Events | No | safety.adverse_event.adverse_severity_codelist_term_id |
| NCOMPLT | C66727 | Completion/Reason for Non-Completion | Yes | disposition reasons |

Race and ethnicity: the model tags `subject.demographic.race_codelist_term_id` with RACE (C74457) and `ethnicity_codelist_term_id` with ETHNIC (C66790). The 2026-09-25 `SDTM Terminology.txt` package contains no rows for C74457 or C66790; it contains the as-collected codelists RACEC (C128689, Race As Collected) and ETHNICC (C128690, Ethnicity As Collected), in line with CDISC's move to collecting detailed values and mapping them to the categories a data recipient requires. Check which race and ethnicity codelists the package you load contains, point the two fields at those terms, and record the choice; do not assume C74457 and C66790 are present.

Other codelists commonly needed for study design and SDTM metadata, from the same package: EPOCH (C99079), DOMAIN (SDTM Domain Abbreviation, C66734), TPHASE (Trial Phase Response, C66737), STYPE (Study Type Response, C99077), INTTYPE (Intervention Type Response, C99078), TCNTRL (Control Type Response, C66785), TINDTP (Trial Intent Type Response, C66736), DSCAT (Category of Disposition Event, C74558), NY (No Yes Response, C66742).

## Notes

- NCI EVS publishes CDISC CT quarterly. Load each new package with its own `package_version`; earlier packages stay queryable.
- A submission value is unique within a codelist and package; the validation in Step 5 checks it.
- Licensed dictionaries (MedDRA, WHODrug, SNOMED CT) are not part of this package; see `SKILL.md` for customer-supplied loads into the `terminology` domain.
