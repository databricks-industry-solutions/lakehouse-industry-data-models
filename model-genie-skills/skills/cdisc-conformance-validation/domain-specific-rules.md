# Domain-Specific CDISC CORE Rules

This document catalogs common CDISC CORE rule violations by domain, along with severity, applicability, and remediation guidance.

## Overview

CDISC CORE rules enforce the SDTM Implementation Guide and regulatory submission standards. The open-source subset (cdisc-open-rules) includes ~50+ rules; this document highlights the most common domain-specific violations.

---

## AE Domain Rules

### Rule AE-001: Required AETERM Missing

- **Severity:** Error
- **Description:** Adverse-event term (AETERM) is required but missing.
- **Remediation:** Obtain the adverse-event term from the clinical record or investigator notes. If unrecoverable, escalate to medical monitor.

### Rule AE-002: Invalid AESEV Value

- **Severity:** Error
- **Description:** AESEV value is not in the valid CDISC CT (expected: 1=Mild, 2=Moderate, 3=Severe, or equivalent text).
- **Remediation:** Recode AESEV to valid CDISC CT values. Common mappings: "Mild"->1, "Moderate"->2, "Severe"->3.

### Rule AE-003: AESTDY Out of Range

- **Severity:** Warning
- **Description:** AESTDY (day of adverse event start) is less than 1 (before enrollment) or after RFENDTC (after study end or follow-up window).
- **Remediation:** Verify AEDT (adverse-event date) against RFSTDTC (enrollment date) and RFENDTC (study end date). If AEDT is outside the valid range, it may be a protocol deviation or data entry error. Document the reason or exclude the event if unverifiable.

### Rule AE-004: Missing AEDECOD Without MedDRA Mapping

- **Severity:** Warning
- **Description:** AEDECOD (coded adverse-event term, typically MedDRA PT) is missing or NULL.
- **Remediation:** After MedDRA is loaded (if licensed), map AETERM to MedDRA PT. Until then, document as deferred. This is not a submission blocker for initial safety data but is required for coded submission.

### Rule AE-005: Invalid AEREL Value

- **Severity:** Warning
- **Description:** AEREL (relationship to study treatment) is not in valid CDISC CT (expected: REMOTE, UNLIKELY, POSSIBLE, PROBABLE, DEFINITE, UNKNOWN).
- **Remediation:** Recode AEREL to valid CDISC CT values.

### Rule AE-006: AESEQ Not Unique Within Subject

- **Severity:** Error
- **Description:** Multiple rows have the same USUBJID and AESEQ.
- **Remediation:** Recompute AESEQ as ROW_NUMBER() OVER (PARTITION BY USUBJID ORDER BY AEDT, AESEQ).

---

## LB Domain Rules

### Rule LB-001: Required LBTEST Missing

- **Severity:** Error
- **Description:** Lab test (LBTEST or LBTESTCD) is required but missing.
- **Remediation:** Obtain lab test name from source system. Map to SDTM LB test code.

### Rule LB-002: Invalid LBTEST Code

- **Severity:** Error
- **Description:** LBTEST does not match a valid CDISC LB test codelist or is ambiguous.
- **Remediation:** Map the lab test to a valid CDISC LB test code (consult SDTM IG or Define-XML for valid codes).

### Rule LB-003: LBDT Out of Study Range

- **Severity:** Warning
- **Description:** LBDT (lab date) is outside the study period or an acceptable follow-up grace window.
- **Remediation:** Verify LBDTC (lab collection date) is within RFSTDTC (enrollment) to RFENDTC (study end) + grace period. If outside, document as a follow-up visit or exclude if unverifiable.

### Rule LB-004: Missing LBORRES or LBSTRESC

- **Severity:** Warning
- **Description:** Neither the original result (LBORRES) nor the standardized result (LBSTRESC) is present.
- **Remediation:** Obtain lab value from source system. Ensure at least LBORRES is populated; LBSTRESC should be standardized if possible.

### Rule LB-005: LBSTRESN Outside Reference Range Without Indication

- **Severity:** Info
- **Description:** Lab result is outside the reference range, but LBNRIND is not set.
- **Remediation:** Calculate LBNRIND based on LBSTRESN vs. LBSTNRLO/LBSTNRHI ('L' if low, 'H' if high, 'N' if normal, 'U' if undefined).

### Rule LB-006: LBSEQ Not Unique Within Subject and Test

- **Severity:** Error
- **Description:** Duplicate USUBJID + LBTEST + LBDTC combinations have the same LBSEQ.
- **Remediation:** Recompute LBSEQ as ROW_NUMBER() OVER (PARTITION BY USUBJID, LBTEST ORDER BY LBDTC, LBSEQ).

### Rule LB-007: Unit Mismatch Between LBORRESU and LBSTRESU

- **Severity:** Warning
- **Description:** Units differ between original (LBORRESU) and standardized (LBSTRESU), but no unit-conversion documentation.
- **Remediation:** Document unit conversion logic in Define-XML. Confirm LBSTRESC value is correctly converted (e.g., mg/100mL -> mg/dL).

---

## VS Domain Rules

### Rule VS-001: Required VSTEST Missing

- **Severity:** Error
- **Description:** Vital-sign test (VSTEST or VSTESTCD) is required but missing.
- **Remediation:** Obtain vital-sign test name (BP, HR, Temperature, etc.).

### Rule VS-002: VSDT Out of Study Range

- **Severity:** Warning
- **Description:** VSDTC (vital-sign date) is outside the study period.
- **Remediation:** Verify VSDTC is within RFSTDTC to RFENDTC + grace period.

### Rule VS-003: Invalid VSPOS (Body Position)

- **Severity:** Warning
- **Description:** VSPOS (body position) is not in valid CDISC CT.
- **Remediation:** Recode VSPOS to valid CDISC CT values (SITTING, STANDING, SUPINE, LYING DOWN, etc.).

### Rule VS-004: Missing VSSTRESN for BP Measurements

- **Severity:** Warning
- **Description:** For blood-pressure measurements, VSSTRESN (numeric result) is missing.
- **Remediation:** Parse systolic and diastolic BP values and ensure both are present (typically two rows per visit: one for SYSBP, one for DIABP).

---

## DM Domain Rules

### Rule DM-001: Required USUBJID Missing

- **Severity:** Error
- **Description:** Unique subject identifier (USUBJID) is missing or NULL.
- **Remediation:** Derive USUBJID from site ID + subject number or use trial_subject_id consistently.

### Rule DM-002: USUBJID Not Unique Across Subjects

- **Severity:** Error
- **Description:** Multiple distinct subjects have the same USUBJID.
- **Remediation:** Ensure USUBJID derivation is consistent and unique (e.g., site-001-subject-001 is unique across all sites and subjects).

### Rule DM-003: Required RFSTDTC Missing

- **Severity:** Error
- **Description:** Study start date for subject (RFSTDTC) is missing.
- **Remediation:** Populate RFSTDTC with enrollment date.

### Rule DM-004: Invalid AGE

- **Severity:** Warning
- **Description:** Calculated AGE is out of expected range (e.g., <0 or >130).
- **Remediation:** Verify date-of-birth calculation. If RFSTDTC < date_of_birth, the enrollment date or birth date is incorrect.

### Rule DM-005: RFENDTC Before RFSTDTC

- **Severity:** Error
- **Description:** Study end date (RFENDTC) is before study start date (RFSTDTC).
- **Remediation:** Verify RFSTDTC and RFENDTC; RFENDTC must be >= RFSTDTC.

### Rule DM-006: Invalid SEX or RACE

- **Severity:** Error
- **Description:** SEX or RACE is not in valid CDISC CT.
- **Remediation:** Recode SEX to (M, F, U) and RACE to valid CDISC CT race values.

---

## DS Domain Rules

### Rule DS-001: Required DSSTDTC Missing

- **Severity:** Error
- **Description:** Disposition start date (DSSTDTC) is missing.
- **Remediation:** Populate DSSTDTC with the date the subject exited the study or completed it.

### Rule DS-002: Invalid DSTERM

- **Severity:** Error
- **Description:** Disposition term (DSTERM) is not in valid CDISC CT.
- **Remediation:** Recode DSTERM to valid CDISC CT values (Completed, Withdrawn by Subject, Withdrawn by Investigator, Lost to Follow-Up, Deceased, Screen Failure, etc.).

### Rule DS-003: DSSEQ Not Unique Within Subject

- **Severity:** Error
- **Description:** Duplicate USUBJID with same DSSEQ.
- **Remediation:** If DS is event-level, ensure each event has a unique DSSEQ. If DS is subject-level, DSSEQ should be 1 for all subjects.

---

## MH Domain Rules

### Rule MH-001: Required MHTERM Missing

- **Severity:** Error
- **Description:** Medical history term (MHTERM) is missing.
- **Remediation:** Obtain medical history condition name from source.

### Rule MH-002: Invalid MHENSTS

- **Severity:** Warning
- **Description:** Medical history status (MHENSTS) is not in valid CDISC CT.
- **Remediation:** Recode MHENSTS to valid values (UNKNOWN, RECOVERING, RESOLVED, ONGOING, etc.).

### Rule MH-003: MHSTDTC After MHENDTC

- **Severity:** Warning
- **Description:** Condition onset date (MHSTDTC) is after resolution date (MHENDTC).
- **Remediation:** Verify dates; MHSTDTC must be <= MHENDTC.

---

## Cross-Domain Rules

### Rule CD-001: USUBJID Inconsistency Across Domains

- **Severity:** Error
- **Description:** A USUBJID exists in AE, LB, or other domains but is not in DM.
- **Remediation:** All subjects appearing in any SDTM domain must have a row in DM. Add missing subjects to DM or remove orphaned records from other domains.

### Rule CD-002: RFSTDTC Before Any Event Date

- **Severity:** Warning
- **Description:** An event date (AEDT, LBDTC, VSDT, etc.) is before the subject's study start date (RFSTDTC).
- **Remediation:** Flag the subject/event combination; may indicate a screening visit recorded as post-enrollment or a data-entry error.

### Rule CD-003: Codelist Value Not in Loaded Terminology

- **Severity:** Warning
- **Description:** A codelist-governed variable uses a value not in the loaded codelist_term.
- **Remediation:** Ensure cdisc-terminology-load has been run and the required CDISC CT codelists are populated. Add missing codelist terms if appropriate (custom terms).

---

## Severity Levels

- **Error** - Submission blocker; must be resolved before submission handoff.
- **Warning** - Fix requested; does not block submission but indicates data quality issue.
- **Info** - Informational; no action required but worth noting.

---

## Rule Execution

When running conformance validation, use the cdisc-rules-engine to execute these rules against the projected SDTM datasets. The engine will return violations in structured format, which are then inserted into `_validation_cdisc_core` for tracking and remediation.

