# SDTM Domain-Specific Projection Rules

This document provides domain-by-domain guidance for projecting silver biomedical data into CDISC SDTM datasets.

## Overview

Each SDTM domain has specific variable requirements, derived-variable rules, and handling of repeats/nulls. This document covers the seven common domains (DM, AE, CM, LB, VS, DS, MH) and optional extended domains (PE, EX, TA).

---

## DM Domain (Demographics)

**Source:** trial_subject + subject (host-level data, one row per subject)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier; fixed per protocol |
| DOMAIN | Char(2) | Req | literal 'DM' | Always 'DM' |
| USUBJID | Char(12) | Req | subject.demographic.unique_subject_identifier | Unique across the submission; must match in every domain |
| SUBJID | Char(12) | Perm | subject.demographic.subject_number | Subject identifier within the study |
| RFSTDTC | Datetime | Req | enrollment_date | Study start date for subject (ISO 8601: YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS) |
| RFENDTC | Datetime | Perm | trial_completion_date or disposition_date | Study end date for subject; optional if ongoing |
| RFXSTDTC | Datetime | Exp | first_intervention_date or enrollment_date | First intervention date for subject (often = RFSTDTC or enrollment + treatment lag) |
| RFXENDTC | Datetime | Perm | last_intervention_date | Last intervention date for subject |
| RFICDTC | Datetime | Exp | icf_date | Informed consent date |
| DTHDTC | Datetime | Perm | date_of_death | Date of death (if applicable); NULL if subject alive |
| DTHFLG | Char(1) | Perm | 'Y' if DTHDTC non-null else 'N' | Death flag |
| AGE | Num | Req | FLOOR(DATEDIFF(day, date_of_birth, RFSTDTC) / 365.25) | Age at enrollment in years |
| AGEU | Char(6) | Req | age_unit_codelist_term_id -> codelist_term.submission_value (AGEU, C66781) | Age unit: DAYS, HOURS, MONTHS, WEEKS or YEARS |
| SEX | Char(8) | Req | sex_codelist_term_id -> codelist_term.submission_value (SEX, C66731) | Sex: F, INTERSEX, M or U |
| RACE | Char(40) | Req | race_codelist_term_id -> codelist_term.submission_value | Text values (for example WHITE); check whether the CT package in use carries RACE (C74457) or only RACEC (C128689, Race As Collected) and map accordingly |
| ETHNIC | Char(40) | Perm | ethnicity_codelist_term_id -> codelist_term.submission_value | Text values (for example HISPANIC OR LATINO); check whether the CT package in use carries ETHNIC (C66790) or only ETHNICC (C128690) |
| ARMCD | Char(20) | Perm | arm_id or arm_code | Treatment-arm code (usually short, e.g., ARM001) |
| ARM | Char(200) | Perm | arm.arm_name | Treatment-arm description (e.g., "Treatment A: 100mg") |
| ACTARMCD | Char(20) | Perm | actual_treatment_arm_id | Actual arm received (may differ from randomized ARM if subject switched) |
| ACTARM | Char(200) | Perm | actual_treatment_arm.label | Actual arm description |
| COUNTRY | Char(3) | Perm | country; ISO 3166-1 alpha-3 code | Country of site (ISO code, e.g., USA, GBR, JPN) |
| SITEID | Char(10) | Perm | site_id | Site identifier |
| SITEGRP | Char(100) | Perm | site_region or country_group | Site grouping (optional, for analysis) |

**Derivation rules:**
- **USUBJID**: Typically derived as CONCAT(site_id, '-', subject_number). Must be unique and immutable.
- **AGE**: Compute as FLOOR(DATEDIFF(day, date_of_birth, RFSTDTC) / 365.25) to handle leap years.
- **SEX/RACE/ETHNIC**: Recode from silver values to CDISC CT submission values using codelist_term mappings.
- **RFSTDTC, RFENDTC**: Must be ISO 8601 datetime; include time if available, otherwise YYYY-MM-DD.
- **RFXSTDTC/RFXENDTC**: If not available in silver, derive as enrollment_date +/- lag (document assumption in Define-XML).

---

## AE Domain (Adverse Events)

**Source:** adverse_event (one row per adverse event)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier |
| DOMAIN | Char(2) | Req | literal 'AE' | Always 'AE' |
| USUBJID | Char(12) | Req | trial_subject_id (must match DM) | Subject identifier |
| AESEQ | Num | Req | ROW_NUMBER() OVER (PARTITION BY trial_subject_id ORDER BY ae_start_date, ae_id) | Sequence number for adverse events within subject |
| AETERM | Char(200) | Req | ae_term | Verbatim adverse-event term from source (eCRF or medical record) |
| AEDECOD | Char(200) | Exp | ae_term_coded or derived from silver ae_meddra_pt if available; NULL if customer has not coded | Coded adverse-event term (MedDRA PT code from silver or post-load mapping) |
| AESOC | Char(200) | Exp | (derived from MedDRA hierarchy) | System Organ Class (MedDRA SOC) |
| AEHLT | Char(200) | Perm | (derived from MedDRA hierarchy) | High Level Term (MedDRA HLT) |
| AEPT | Char(200) | Perm | (derived from MedDRA hierarchy) | Preferred Term (MedDRA PT) |
| AELLT | Char(200) | Perm | (derived from MedDRA hierarchy) | Lowest Level Term (MedDRA LLT) |
| AEREL | Char(3) | Perm | ae_relationship; recode to CDISC CT (REMOTE/UNLIKELY/POSSIBLE/PROBABLE/DEFINITE) | Relationship to study treatment |
| AESEV | Char(8) | Exp | adverse_severity_codelist_term_id -> codelist_term.submission_value (AESEV, C66769) | Severity: MILD, MODERATE or SEVERE |
| AEOUT | Char(40) | Exp | adverse_outcome_codelist_term_id -> codelist_term.submission_value (OUT, C66768) | FATAL, NOT RECOVERED/NOT RESOLVED, RECOVERED/RESOLVED, RECOVERED/RESOLVED WITH SEQUELAE, RECOVERING/RESOLVING or UNKNOWN |
| AEACN | Char(20) | Perm | adverse_action_taken_codelist_term_id -> codelist_term.submission_value (ACN, C66767) | DOSE INCREASED, DOSE NOT CHANGED, DOSE RATE REDUCED, DOSE REDUCED, DRUG INTERRUPTED, DRUG WITHDRAWN, NOT APPLICABLE or UNKNOWN |
| AEDT | Date | Req | ae_start_date; ISO 8601 | Adverse-event start date (YYYY-MM-DD) |
| AESTDY | Num | Exp | DATEDIFF(day, RFSTDTC, AEDT) + 1 | Day of adverse-event start relative to enrollment (1-based, Day 1 = enrollment day) |
| AEENDT | Date | Perm | ae_end_date; ISO 8601 or NULL | Adverse-event end date; NULL if ongoing |
| AEENDTC | Char(19) | Perm | CONCAT(AEENDT, 'T00:00:00') if AEENDT exists | Adverse-event end datetime (ISO 8601) |
| AEENDDY | Num | Perm | DATEDIFF(day, RFSTDTC, AEENDT) + 1 if AEENDT non-null | Day of adverse-event end relative to enrollment |
| AESTTM | Char(8) | Perm | ae_start_time | Start time (HH:MM:SS) if recorded |
| AEENDTM | Char(8) | Perm | ae_end_time | End time (HH:MM:SS) if recorded |
| AEONGO | Char(1) | Perm | 'Y' if AEENDT is NULL else 'N' | Ongoing adverse event flag |
| AEACNDEV | Char(1) | Perm | 'Y' if action_taken differs from protocol, else 'N' | Protocol deviation (action not per protocol) |
| AEPATT | Char(20) | Perm | ae_pattern; recode to CDISC CT (CONTINUOUS/INTERMITTENT/RECURRENT/SINGLE EVENT) | Adverse-event pattern |
| AERETC | Char(1) | Perm | 'Y' if ae_recurred after resolution, else 'N' | Adverse event recurrent flag |

**Derivation rules:**
- **AESEQ**: Row number per subject, ordered by AEDT then by ae_id for consistency.
- **AESTDY**: 1-based day count from RFSTDTC. Formula: DATEDIFF(day, RFSTDTC, AEDT) + 1. Day 1 = enrollment day.
- **AEDECOD + MedDRA hierarchy**: Project from silver if the customer has already coded adverse events to MedDRA (e.g., silver has ae_meddra_pt column). If not yet coded, AEDECOD is NULL and must be populated after MedDRA load (document in Define-XML as a derivation). AESOC/AEHLT/AEPT/AELLT are derived from the MedDRA hierarchy post-load.
- **Recoding (AEREL, AEOUT, AEACN)**: Use codelist_term mappings from cdisc-terminology-load.
- **AEONGO**: Derived as 'Y' if AEENDT is NULL (ongoing), else 'N'.

---

## CM Domain (Concomitant Medications)

**Source:** concomitant_medication (one row per medication per subject per period)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier |
| DOMAIN | Char(2) | Req | literal 'CM' | Always 'CM' |
| USUBJID | Char(12) | Req | trial_subject_id | Subject identifier |
| CMSEQ | Num | Req | ROW_NUMBER() OVER (PARTITION BY trial_subject_id ORDER BY cm_start_date, cm_id) | Sequence number |
| CMTRT | Char(200) | Req | medication_name | Medication treatment name (verbatim) |
| CMINDC | Char(200) | Perm | indication | Indication for medication |
| CMCLAS | Char(20) | Perm | drug_class; recode to CDISC CT or WHO-Drug ATC | Drug classification (ATC code if available) |
| CMROUTE | Char(40) | Perm | route_codelist_term_id -> codelist_term.submission_value (ROUTE, C66729) | Route, for example ORAL, INTRAVENOUS, SUBCUTANEOUS |
| CMDOSE | Num | Perm | dose_value | Dose amount |
| CMDOSU | Char(20) | Perm | dose_unit_codelist_term_id -> codelist_term.submission_value (UNIT, C71620) | Dose unit, for example mg, mL (UNIT values are case-sensitive) |
| CMFREQ | Char(20) | Perm | frequency; recode to CDISC CT (QD, BID, TID, QID, etc.) | Dosing frequency |
| CMSTDTC | Char(19) | Perm | cm_start_date; ISO 8601 | Medication start date (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS) |
| CMSTDY | Num | Perm | DATEDIFF(day, RFSTDTC, CMSTDTC) + 1 | Day of medication start relative to enrollment |
| CMENDTC | Char(19) | Perm | cm_end_date; ISO 8601 or NULL | Medication end date; NULL if ongoing |
| CMENDY | Num | Perm | DATEDIFF(day, RFSTDTC, CMENDTC) + 1 if CMENDTC non-null | Day of medication end relative to enrollment |
| CMDUR | Char(10) | Perm | DATEDIFF(day, CMSTDTC, CMENDTC) or NULL | Duration of medication in days |
| CMONGO | Char(1) | Perm | 'Y' if CMENDTC is NULL else 'N' | Ongoing medication flag |

**Derivation rules:**
- **CMSEQ**: Row number per subject, ordered by CMSTDTC then CMID.
- **CMROUTE/CMDOSU/CMFREQ**: Recode to CDISC CT (or WHO-Drug if licensed).
- **CMSTDY/CMENDY**: 1-based day count from RFSTDTC (enrollment date).
- **CMDUR**: Compute as DATEDIFF(day, CMSTDTC, CMENDTC) if both dates present; NULL otherwise.

---

## LB Domain (Laboratory Results)

**Source:** lab_result (one row per lab test per subject per visit)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier |
| DOMAIN | Char(2) | Req | literal 'LB' | Always 'LB' |
| USUBJID | Char(12) | Req | trial_subject_id | Subject identifier |
| LBSEQ | Num | Req | ROW_NUMBER() OVER (PARTITION BY trial_subject_id ORDER BY lab_date, lab_test_code, lab_id) | Sequence number |
| LBTEST | Char(8) | Req | lab_test_code; map to SDTM LB test code | Lab test (abbreviated code, e.g., 'HEMATOCRIT') |
| LBTESTCD | Char(8) | Req | lab_test_code | Lab test code (same as LBTEST in SDTM) |
| LBDTC | Char(19) | Req | lab_collection_date; ISO 8601 | Lab collection date (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS) |
| LBDY | Num | Exp | DATEDIFF(day, RFSTDTC, LBDTC) + 1 | Day of lab collection relative to enrollment |
| LBORRES | Char(10) | Exp | lab_value | Original lab result (may be text, numeric, or range) |
| LBSTRESC | Char(10) | Exp | lab_value_standardized | Standardized result (numeric if possible, after unit conversion) |
| LBSTRESN | Num | Exp | lab_value_numeric | Numeric result (parsed from LBSTRESC) |
| LBORRESU | Char(10) | Exp | lab_unit; recode to CDISC CT standard unit | Original result unit |
| LBSTRESU | Char(10) | Exp | standard_unit; recode to CDISC CT | Standardized unit (e.g., all mg/dL, not mg/100mL) |
| LBREF | Char(20) | Perm | reference_range_text | Reference range (e.g., "70-100") |
| LBREFTXT | Char(20) | Perm | reference_range_text | Reference range text |
| LBSTNRLO | Num | Perm | reference_low | Reference range lower bound |
| LBSTNRHI | Num | Perm | reference_high | Reference range upper bound |
| LBLOINC | Char(10) | Perm | loinc_code | LOINC code for the test (if available) |
| LBNRIND | Char(1) | Perm | 'N' if within normal range, 'L' if low, 'H' if high, 'U' if undefined | Reference-range indicator |

**Derivation rules:**
- **LBSEQ**: Row number per subject, ordered by LBDTC then lab_test_code.
- **LBDY**: 1-based day count from RFSTDTC.
- **LBSTRESC/LBSTRESN/LBSTRESU**: Standardize unit (e.g., if silver has mg/100mL and CDISC standard is mg/dL, convert). Leave LBORRES as verbatim.
- **LBNRIND**: Compare LBSTRESN to LBSTNRLO / LBSTNRHI; if result < low, 'L'; if > high, 'H'; if in range, 'N'; if undefined, 'U'.
- **LBLOINC**: Optional; link if available.

---

## VS Domain (Vital Signs)

**Source:** vital_signs (one row per vital-sign measurement per subject per visit)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier |
| DOMAIN | Char(2) | Req | literal 'VS' | Always 'VS' |
| USUBJID | Char(12) | Req | trial_subject_id | Subject identifier |
| VSSEQ | Num | Req | ROW_NUMBER() OVER (PARTITION BY trial_subject_id ORDER BY vs_date, vs_test, vs_id) | Sequence number |
| VSTEST | Char(20) | Req | vital_test; map to CDISC (BP=Blood Pressure, HR=Heart Rate, TEMP=Temperature, RR=Respiratory Rate) | Vital-sign test type |
| VSTESTCD | Char(8) | Req | vital_test_code | Vital-sign test code (e.g., 'SYSBP', 'DIABP', 'PULSE', 'TEMP') |
| VSDTC | Char(19) | Req | vs_date; ISO 8601 | Vital-sign measurement date (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS) |
| VSDY | Num | Exp | DATEDIFF(day, RFSTDTC, VSDTC) + 1 | Day of vital-sign measurement relative to enrollment |
| VSTIME | Char(8) | Perm | vs_time | Measurement time (HH:MM:SS) |
| VSORRES | Char(10) | Exp | vs_value | Original vital-sign result |
| VSSTRESC | Char(10) | Exp | vs_value_standardized | Standardized result (after unit conversion if needed) |
| VSSTRESN | Num | Exp | vs_value_numeric | Numeric result |
| VSORRESU | Char(10) | Exp | vs_unit; recode to CDISC CT (mmHg for BP, bpm for HR, C or F for temp) | Original unit |
| VSSTRESU | Char(10) | Exp | standard_unit | Standardized unit (e.g., all mmHg, all bpm, all C) |
| VSLOC | Char(20) | Perm | measurement_location (e.g., LEFT_ARM, RIGHT_ARM) | Anatomical location (if applicable, e.g., for BP) |
| VSPOS | Char(20) | Perm | body_position; recode to CDISC CT (SITTING, STANDING, SUPINE, etc.) | Body position during measurement |
| VSBPMETHOD | Char(20) | Perm | bp_measurement_method; recode to CDISC CT if applicable | BP measurement method (automated, manual, etc.) |

**Derivation rules:**
- **VSSEQ**: Row number per subject, ordered by VSDTC then vital_test.
- **VSDY**: 1-based day count from RFSTDTC.
- **VSSTRESU**: Standardize units (all temperature in Celsius, all BP in mmHg, all HR in bpm).
- **VSLOC**: Relevant for blood pressure; standardize per CDISC CT.
- **VSPOS**: Standardize body position per CDISC CT (SITTING, STANDING, SUPINE, etc.).

---

## DS Domain (Disposition)

**Source:** disposition (one row per disposition event per subject OR one row per subject if DS is subject-level)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier |
| DOMAIN | Char(2) | Req | literal 'DS' | Always 'DS' |
| USUBJID | Char(12) | Req | trial_subject_id | Subject identifier |
| DSSEQ | Num | Req | 1 if DS is subject-level; else ROW_NUMBER() for event-level | Sequence number |
| DSSTDTC | Char(19) | Req | disposition_date or enrollment_date if disposition_date is null | Disposition start date (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS) |
| DSDY | Num | Exp | DATEDIFF(day, RFSTDTC, DSSTDTC) + 1 | Day of disposition event relative to enrollment |
| DSTERM | Char(30) | Exp | disposition_event; recode to CDISC CT (Completed, Withdrawn by Subject, Withdrawn by Investigator, Lost to Follow-Up, Deceased, Screen Failure) | Disposition event term |
| DSDECOD | Char(30) | Exp | (same as DSTERM, or mapped from codelist if differs) | Disposition event decoded |
| DSCAT | Char(30) | Perm | 'DISPOSITION' (fixed) | Category |
| DSSTDY | Num | Perm | DATEDIFF(day, RFSTDTC, DSSTDTC) + 1 if known | Day of disposition event |
| DSREASDTC | Char(19) | Perm | withdrawal_reason | Reason for disposition (e.g., "Adverse Event", "Inadequate Response") |
| DSREAS | Char(30) | Perm | withdrawal_reason; recode to CDISC CT | Disposition reason |

**Derivation rules:**
- **DSSTDTC**: Typically the date the subject exited the study or completed it. If missing, use enrollment date + study duration.
- **DSTERM/DSREAS**: Recode to CDISC CT (Completed, Withdrawn, etc.).
- **DSSEQ**: If DS is event-level (e.g., multiple disposition events per subject), sequence them; if subject-level (one row per subject), DSSEQ = 1.

---

## MH Domain (Medical History)

**Source:** medical_history (one row per medical history condition per subject)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier |
| DOMAIN | Char(2) | Req | literal 'MH' | Always 'MH' |
| USUBJID | Char(12) | Req | trial_subject_id | Subject identifier |
| MHSEQ | Num | Req | ROW_NUMBER() OVER (PARTITION BY trial_subject_id ORDER BY mh_onset_date, mh_condition, mh_id) | Sequence number |
| MHTERM | Char(200) | Req | condition_name | Verbatim medical history term |
| MHDECOD | Char(200) | Exp | (populated via MedDRA mapping post-load) | Medical history decoded (MedDRA PT) |
| MHSOC | Char(200) | Exp | (derived from MedDRA) | System Organ Class |
| MHBODSYS | Char(200) | Perm | body_system | Body system or organ class |
| MHENRTPT | Char(3) | Perm | 'Y' if condition was present at enrollment, else 'N' | Condition present at enrollment flag |
| MHSTDTC | Char(19) | Perm | condition_onset_date | Condition onset date (if known) |
| MHENDTC | Char(19) | Perm | condition_resolution_date | Condition resolution date (if resolved) |
| MHENSTS | Char(20) | Perm | condition_status; recode (UNKNOWN/RECOVERING/RESOLVED/ONGOING) | Condition status |

**Derivation rules:**
- **MHSEQ**: Row number per subject.
- **MHDECOD + MHSOC**: Populated via MedDRA mapping (requires licensed MedDRA). Initially NULL; updated after MedDRA load.
- **MHENRTPT**: 'Y' if condition_onset_date is before or on enrollment date (RFSTDTC); 'N' otherwise.
- **MHENSTS**: Recode condition_status to CDISC CT values.

---

## PE Domain (Physical Exam) - Optional, if applicable

**Source:** physical_exam (one row per exam finding per subject per visit)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier |
| DOMAIN | Char(2) | Req | literal 'PE' | Always 'PE' |
| USUBJID | Char(12) | Req | trial_subject_id | Subject identifier |
| PESEQ | Num | Req | ROW_NUMBER() OVER (PARTITION BY trial_subject_id ORDER BY pe_date, pe_test, pe_id) | Sequence number |
| PETEST | Char(20) | Req | exam_type | Exam type (e.g., 'General Appearance', 'Head/Neck', 'Lungs') |
| PETESTCD | Char(8) | Req | exam_code | Exam test code |
| PEDTC | Char(19) | Req | exam_date | Exam date (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS) |
| PEDY | Num | Exp | DATEDIFF(day, RFSTDTC, PEDTC) + 1 | Day of exam relative to enrollment |
| PEORRES | Char(200) | Exp | exam_finding | Exam finding (verbatim or standardized) |
| PETEST | Char(20) | Perm | exam_finding_detail | Additional detail |

---

## EX Domain (Study Drug Exposures) - Optional, if applicable

**Source:** study_intervention (drug administrations/dispensings)

| SDTM Variable | Type | Required | Source Column | Notes |
|---|---|---|---|---|
| STUDYID | Char(12) | Req | study_version_id | Study identifier |
| DOMAIN | Char(2) | Req | literal 'EX' | Always 'EX' |
| USUBJID | Char(12) | Req | trial_subject_id | Subject identifier |
| EXSEQ | Num | Req | ROW_NUMBER() OVER (PARTITION BY trial_subject_id ORDER BY ex_date, ex_dose_number) | Sequence number |
| EXTRT | Char(30) | Req | study_drug_name | Study drug treatment name |
| EXDOSE | Num | Perm | dose_amount | Dose amount |
| EXDOSU | Char(20) | Perm | study.dosing_regimen.dose_unit_codelist_term_id -> codelist_term.submission_value (UNIT, C71620) | Dose unit, for example mg, mL (UNIT values are case-sensitive) |
| EXROUTE | Char(40) | Perm | study.dosing_regimen.route_codelist_term_id -> codelist_term.submission_value (ROUTE, C66729) | Route, for example ORAL, INTRAVENOUS, SUBCUTANEOUS |
| EXSTDTC | Char(19) | Perm | ex_start_date | Exposure start date |
| EXSTDY | Num | Perm | DATEDIFF(day, RFSTDTC, EXSTDTC) + 1 | Day of exposure start |
| EXENDTC | Char(19) | Perm | ex_end_date | Exposure end date |
| EXENDY | Num | Perm | DATEDIFF(day, RFSTDTC, EXENDTC) + 1 | Day of exposure end |

---

## Notes

- All dates are ISO 8601 format (YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS).
- Day counts (AESTDY, LBDY, VSDY, etc.) are 1-based: Day 1 = enrollment day (RFSTDTC).
- All codelist values must come from `codelist_term` (via cdisc-terminology-load or customer-supplied).
- Required (Req) variables must never be NULL; Permissible (Perm) variables may be NULL; Expected (Exp) variables should be present but are not strictly required.
- MedDRA-based variables (AEDECOD, AESOC, AEHLT, AEPT, AELLT) are populated after a separate MedDRA load (if licensed); initially NULL in this projection.

