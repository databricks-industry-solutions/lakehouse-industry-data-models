-- Metric views for domain: datamanagement | Business: Clinical_Trials | Version: 17 | Generated on: 2026-11-20 10:03:07

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_data_quality_alcoa`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ALCOA+ data integrity compliance metrics tracking attributability, legibility, contemporaneousness, originality, and accuracy of clinical trial data entries across all EDC systems and source data verification activities."
  source: "`clinical_trials_ecm`.`datamanagement`.`alcoa_audit_entry`"
  dimensions:
    - name: "Action Type"
      display_name: "Audit Action Type"
      expr: action_type
      comment: "Type of data action audited (CREATE, UPDATE, DELETE, VERIFY, LOCK, UNLOCK, SIGN)"
    - name: "ALCOA Overall Status"
      display_name: "ALCOA+ Compliance Status"
      expr: alcoa_overall_status
      comment: "Overall ALCOA+ compliance status for the audited entry (COMPLIANT, NON_COMPLIANT, PARTIAL, UNDER_REVIEW)"
    - name: "SDV Status"
      display_name: "Source Data Verification Status"
      expr: sdv_status
      comment: "Source data verification status (NOT_REQUIRED, PENDING, VERIFIED, DISCREPANCY_FOUND)"
    - name: "User Role"
      display_name: "User Role"
      expr: user_role
      comment: "Role of the user who performed the audited action (CRA, DATA_MANAGER, INVESTIGATOR, COORDINATOR)"
    - name: "EDC System"
      display_name: "EDC System Name"
      expr: edc_system_name
      comment: "Electronic data capture system where the action occurred (RAVE, INFORM, VEEVA_VAULT)"
    - name: "Event Month"
      display_name: "Event Month"
      expr: DATE_TRUNC('month', event_timestamp)
      comment: "Month when the audited event occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Event Quarter"
      display_name: "Event Quarter"
      expr: DATE_TRUNC('quarter', event_timestamp)
      comment: "Quarter when the audited event occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Event Year"
      display_name: "Event Year"
      expr: DATE_TRUNC('year', event_timestamp)
      comment: "Year when the audited event occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Audit Entries"
      display_name: "Total Audit Entries"
      expr: COUNT(1)
      comment: "Total number of ALCOA+ audit trail entries recorded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ALCOA Compliant Entries"
      display_name: "ALCOA+ Compliant Entries"
      expr: SUM(CAST(CASE WHEN is_accurate = TRUE AND is_attributable = TRUE AND is_contemporaneous = TRUE AND is_legible = TRUE AND is_original = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of audit entries meeting all five core ALCOA principles (Attributable, Legible, Contemporaneous, Original, Accurate)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ALCOA Plus Compliant Entries"
      display_name: "ALCOA+ Compliant Entries (Full)"
      expr: SUM(CAST(CASE WHEN is_accurate = TRUE AND is_attributable = TRUE AND is_contemporaneous = TRUE AND is_legible = TRUE AND is_original = TRUE AND is_complete = TRUE AND is_consistent = TRUE AND is_enduring = TRUE AND is_available = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of audit entries meeting all nine ALCOA+ principles including Complete, Consistent, Enduring, and Available"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ALCOA Compliance Rate"
      display_name: "ALCOA Compliance Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_accurate = TRUE AND is_attributable = TRUE AND is_contemporaneous = TRUE AND is_legible = TRUE AND is_original = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of audit entries meeting all five core ALCOA principles — critical regulatory compliance KPI for Part 11 and GCP inspections"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "ALCOA Plus Compliance Rate"
      display_name: "ALCOA+ Compliance Rate (Full)"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_accurate = TRUE AND is_attributable = TRUE AND is_contemporaneous = TRUE AND is_legible = TRUE AND is_original = TRUE AND is_complete = TRUE AND is_consistent = TRUE AND is_enduring = TRUE AND is_available = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of audit entries meeting all nine ALCOA+ principles — gold standard for data integrity in regulated clinical trials"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Data Entry Lag Minutes"
      display_name: "Average Data Entry Lag (Minutes)"
      expr: AVG(CAST(data_entry_lag_minutes AS DOUBLE))
      comment: "Average time lag in minutes between event occurrence and data entry — measures contemporaneousness and data freshness"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Non Attributable Entries"
      display_name: "Non-Attributable Entries"
      expr: SUM(CAST(CASE WHEN is_attributable = FALSE THEN 1 ELSE 0 END AS INT))
      comment: "Count of entries failing attributability (missing or invalid user signature/timestamp) — critical Part 11 violation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Non Contemporaneous Entries"
      display_name: "Non-Contemporaneous Entries"
      expr: SUM(CAST(CASE WHEN is_contemporaneous = FALSE THEN 1 ELSE 0 END AS INT))
      comment: "Count of entries failing contemporaneousness (excessive lag between event and recording) — GCP compliance risk"
      format:
        type: number
        decimal_places:
          type: all
    - name: "SDV Required Entries"
      display_name: "SDV Required Entries"
      expr: SUM(CASE WHEN sdv_status IN ('PENDING', 'VERIFIED', 'DISCREPANCY_FOUND') THEN 1 ELSE 0 END)
      comment: "Count of entries requiring source data verification per monitoring plan"
      format:
        type: number
        decimal_places:
          type: all
    - name: "SDV Completion Rate"
      display_name: "SDV Completion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN sdv_status = 'VERIFIED' THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CASE WHEN sdv_status IN ('PENDING', 'VERIFIED', 'DISCREPANCY_FOUND') THEN 1 ELSE 0 END), 0), 2)
      comment: "Percentage of required source data verification activities completed — operational monitoring KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_coding_assignment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Medical coding productivity and quality KPIs tracking coding completion, approval rates, autocoding performance, and recoding frequency across MedDRA and WHODrug dictionaries."
  source: "`clinical_trials_ecm`.`datamanagement`.`coding_assignment`"
  dimensions:
    - name: "Coding Status"
      display_name: "Coding Status"
      expr: coding_status
      comment: "Current status of the coding assignment (Pending, Coded, Approved, Rejected)"
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the coding assignment"
    - name: "Coding Method"
      display_name: "Coding Method"
      expr: coding_method
      comment: "Method used for coding (Manual, Autocoding, Hybrid)"
    - name: "Coding Dictionary"
      display_name: "Coding Dictionary"
      expr: coding_dictionary
      comment: "Dictionary used for coding (MedDRA, WHODrug, LOINC)"
    - name: "Coding Domain"
      display_name: "Coding Domain"
      expr: coding_domain
      comment: "CDISC domain being coded (AE, CM, MH, etc.)"
    - name: "Is Primary SOC"
      display_name: "Primary SOC"
      expr: is_primary_soc
      comment: "Flag indicating whether this is the primary system organ class assignment"
    - name: "Is Serious AE"
      display_name: "Serious AE"
      expr: is_serious_ae
      comment: "Flag indicating whether the coded term is a serious adverse event"
    - name: "Coding Flag"
      display_name: "Coding Flag"
      expr: coding_flag
      comment: "General coding flag for special handling"
    - name: "Coding Month"
      display_name: "Coding Month"
      expr: DATE_TRUNC('month', coding_date)
      comment: "Month when the coding was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Approval Month"
      display_name: "Approval Month"
      expr: DATE_TRUNC('month', approval_date)
      comment: "Month when the coding was approved"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Coding Assignments"
      display_name: "Total Coding Assignments"
      expr: COUNT(1)
      comment: "Total number of coding assignments processed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Coded Assignments"
      display_name: "Coded Assignments"
      expr: COUNT(CASE WHEN coding_status IN ('Coded', 'Approved') THEN 1 END)
      comment: "Count of assignments that have been coded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Assignments"
      display_name: "Approved Assignments"
      expr: COUNT(CASE WHEN approval_status = 'Approved' THEN 1 END)
      comment: "Count of coding assignments approved by medical reviewer"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Autocoded Assignments"
      display_name: "Autocoded Assignments"
      expr: COUNT(CASE WHEN coding_method = 'Autocoding' THEN 1 END)
      comment: "Count of assignments coded automatically, efficiency metric"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Manual Coded Assignments"
      display_name: "Manual Coded Assignments"
      expr: COUNT(CASE WHEN coding_method = 'Manual' THEN 1 END)
      comment: "Count of assignments requiring manual coding"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Recoded Assignments"
      display_name: "Recoded Assignments"
      expr: COUNT(CASE WHEN prior_assigned_code IS NOT NULL THEN 1 END)
      comment: "Count of assignments that were recoded, quality indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Serious AE Assignments"
      display_name: "Serious AE Assignments"
      expr: COUNT(CASE WHEN is_serious_ae = TRUE THEN 1 END)
      comment: "Count of serious adverse event coding assignments, safety metric"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Autocoding Confidence"
      display_name: "Avg Autocoding Confidence"
      expr: AVG(CAST(autocoding_confidence_score AS DOUBLE))
      comment: "Average confidence score for autocoded assignments, quality metric"
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Coding Completion Rate"
      display_name: "Coding Completion Rate"
      expr: COUNT(CASE WHEN coding_status IN ('Coded', 'Approved') THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of assignments coded, productivity metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Approval Rate"
      display_name: "Approval Rate"
      expr: COUNT(CASE WHEN approval_status = 'Approved' THEN 1 END) * 100.0 / NULLIF(COUNT(CASE WHEN coding_status IN ('Coded', 'Approved') THEN 1 END), 0)
      comment: "Percentage of coded assignments approved, quality metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Autocoding Rate"
      display_name: "Autocoding Rate"
      expr: COUNT(CASE WHEN coding_method = 'Autocoding' THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of assignments autocoded, automation efficiency metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Recoding Rate"
      display_name: "Recoding Rate"
      expr: COUNT(CASE WHEN prior_assigned_code IS NOT NULL THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of assignments requiring recoding, quality indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Serious AE Rate"
      display_name: "Serious AE Rate"
      expr: COUNT(CASE WHEN is_serious_ae = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of assignments classified as serious AE, safety metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_coding_quality`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Medical coding quality and efficiency metrics tracking coding assignment accuracy, approval rates, recoding frequency, and dictionary version compliance for adverse events, medications, and medical history across all clinical trials."
  source: "`clinical_trials_ecm`.`datamanagement`.`coding_assignment`"
  dimensions:
    - name: "Coding Domain"
      display_name: "Coding Domain"
      expr: coding_domain
      comment: "Clinical domain being coded (ADVERSE_EVENT, CONCOMITANT_MEDICATION, MEDICAL_HISTORY, INDICATION)"
    - name: "Coding Dictionary"
      display_name: "Coding Dictionary"
      expr: coding_dictionary
      comment: "Medical coding dictionary used (MEDDRA, WHODRUG, ICD10, SNOMED_CT)"
    - name: "Dictionary Version"
      display_name: "Dictionary Version"
      expr: dictionary_version
      comment: "Version of the coding dictionary used (e.g., MedDRA 25.1, WHODrug B3 2023Q2)"
    - name: "Coding Method"
      display_name: "Coding Method"
      expr: coding_method
      comment: "Method used for coding (MANUAL, AUTOCODING, HYBRID)"
    - name: "Coding Status"
      display_name: "Coding Status"
      expr: coding_status
      comment: "Current status of the coding assignment (PENDING, CODED, APPROVED, REJECTED, RECODED)"
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the coding assignment (PENDING_APPROVAL, APPROVED, REJECTED, CONDITIONAL_APPROVAL)"
    - name: "Is Primary SOC"
      display_name: "Primary System Organ Class"
      expr: CASE WHEN is_primary_soc = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the coded term is assigned to the primary System Organ Class (MedDRA)"
    - name: "Is Serious AE"
      display_name: "Serious Adverse Event"
      expr: CASE WHEN is_serious_ae = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the coded adverse event is classified as serious"
    - name: "Coding Month"
      display_name: "Coding Month"
      expr: DATE_TRUNC('month', coding_date)
      comment: "Month when the coding was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Coding Quarter"
      display_name: "Coding Quarter"
      expr: DATE_TRUNC('quarter', coding_date)
      comment: "Quarter when the coding was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Coding Year"
      display_name: "Coding Year"
      expr: DATE_TRUNC('year', coding_date)
      comment: "Year when the coding was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Coding Assignments"
      display_name: "Total Coding Assignments"
      expr: COUNT(1)
      comment: "Total number of medical coding assignments performed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approved Codings"
      display_name: "Approved Coding Assignments"
      expr: SUM(CAST(CASE WHEN approval_status = 'APPROVED' THEN 1 ELSE 0 END AS INT))
      comment: "Count of coding assignments approved by medical reviewer — coding quality indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Coding Approval Rate"
      display_name: "Coding Approval Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN approval_status = 'APPROVED' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of coding assignments approved on first submission — coding accuracy and coder training effectiveness KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rejected Codings"
      display_name: "Rejected Coding Assignments"
      expr: SUM(CAST(CASE WHEN approval_status = 'REJECTED' THEN 1 ELSE 0 END AS INT))
      comment: "Count of coding assignments rejected by medical reviewer — quality issue indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Coding Rejection Rate"
      display_name: "Coding Rejection Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN approval_status = 'REJECTED' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of coding assignments rejected — inverse quality metric requiring coder retraining"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Autocoded Assignments"
      display_name: "Autocoded Assignments"
      expr: SUM(CAST(CASE WHEN coding_method = 'AUTOCODING' THEN 1 ELSE 0 END AS INT))
      comment: "Count of coding assignments performed by autocoding engine — automation efficiency indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Autocoding Rate"
      display_name: "Autocoding Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN coding_method = 'AUTOCODING' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of coding assignments performed by autocoding — automation efficiency and cost reduction KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Autocoding Confidence"
      display_name: "Average Autocoding Confidence Score"
      expr: AVG(CAST(autocoding_confidence_score AS DOUBLE))
      comment: "Average confidence score of autocoding assignments (0.0-1.0) — autocoding quality and reliability indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 3
    - name: "Recoded Assignments"
      display_name: "Recoded Assignments"
      expr: SUM(CAST(CASE WHEN prior_assigned_code IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of coding assignments that were recoded after initial assignment — coding quality issue indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Recoding Rate"
      display_name: "Recoding Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN prior_assigned_code IS NOT NULL THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of coding assignments requiring recoding — coding accuracy and consistency KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Serious AE Codings"
      display_name: "Serious Adverse Event Codings"
      expr: SUM(CAST(CASE WHEN is_serious_ae = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of coding assignments for serious adverse events — regulatory priority indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Serious AE Rate"
      display_name: "Serious Adverse Event Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_serious_ae = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN coding_domain = 'ADVERSE_EVENT' THEN 1 ELSE 0 END AS INT)), 0), 2)
      comment: "Percentage of adverse event codings classified as serious — safety signal indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Primary SOC Assignments"
      display_name: "Primary SOC Assignments"
      expr: SUM(CAST(CASE WHEN is_primary_soc = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of MedDRA coding assignments with primary System Organ Class designation"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_data_entry_productivity`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Data entry session productivity and efficiency metrics tracking session duration, field entry rates, error rates, and data entry quality across all EDC systems and clinical trial sites."
  source: "`clinical_trials_ecm`.`datamanagement`.`data_entry_session`"
  dimensions:
    - name: "Session Status"
      display_name: "Data Entry Session Status"
      expr: data_entry_session_status
      comment: "Status of the data entry session (IN_PROGRESS, COMPLETED, ABANDONED, TIMED_OUT)"
    - name: "Session Type"
      display_name: "Session Type"
      expr: session_type
      comment: "Type of data entry session (INITIAL_ENTRY, DOUBLE_DATA_ENTRY, CORRECTION, QUERY_RESPONSE)"
    - name: "Entry Method"
      display_name: "Entry Method"
      expr: entry_method
      comment: "Method of data entry (MANUAL, IMPORT, API, MOBILE)"
    - name: "User Role"
      display_name: "User Role"
      expr: user_role
      comment: "Role of the user performing data entry (CRA, DATA_MANAGER, SITE_COORDINATOR, INVESTIGATOR)"
    - name: "Is Double Data Entry"
      display_name: "Double Data Entry"
      expr: CASE WHEN is_double_data_entry = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the session is part of double data entry quality control process"
    - name: "Is Locked"
      display_name: "Session Locked"
      expr: CASE WHEN is_locked = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the data entry session has been locked"
    - name: "Is SDV"
      display_name: "Source Data Verified"
      expr: CASE WHEN is_source_data_verified = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the session data has been source data verified"
    - name: "Protocol Deviation Flag"
      display_name: "Protocol Deviation Detected"
      expr: CASE WHEN protocol_deviation_flag = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether a protocol deviation was detected during data entry"
    - name: "Start Month"
      display_name: "Session Start Month"
      expr: DATE_TRUNC('month', start_timestamp)
      comment: "Month when the data entry session started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Start Quarter"
      display_name: "Session Start Quarter"
      expr: DATE_TRUNC('quarter', start_timestamp)
      comment: "Quarter when the data entry session started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Start Year"
      display_name: "Session Start Year"
      expr: DATE_TRUNC('year', start_timestamp)
      comment: "Year when the data entry session started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Sessions"
      display_name: "Total Data Entry Sessions"
      expr: COUNT(1)
      comment: "Total number of data entry sessions initiated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Sessions"
      display_name: "Completed Sessions"
      expr: SUM(CAST(CASE WHEN data_entry_session_status = 'COMPLETED' THEN 1 ELSE 0 END AS INT))
      comment: "Count of data entry sessions successfully completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Session Completion Rate"
      display_name: "Session Completion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN data_entry_session_status = 'COMPLETED' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of data entry sessions successfully completed — user experience and system usability KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Session Duration Minutes"
      display_name: "Average Session Duration (Minutes)"
      expr: AVG(CAST(duration_seconds AS DOUBLE)) / 60.0
      comment: "Average duration of data entry sessions in minutes — productivity and efficiency indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Fields Entered"
      display_name: "Total Fields Entered"
      expr: SUM(CAST(fields_entered_count AS DOUBLE))
      comment: "Total number of fields entered across all sessions — data entry volume metric"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Fields Per Session"
      display_name: "Average Fields Per Session"
      expr: AVG(CAST(fields_entered_count AS DOUBLE))
      comment: "Average number of fields entered per session — session complexity indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Fields Per Minute"
      display_name: "Fields Entered Per Minute"
      expr: SUM(CAST(fields_entered_count AS DOUBLE)) / NULLIF(SUM(CAST(duration_seconds AS DOUBLE)) / 60.0, 0)
      comment: "Average number of fields entered per minute — data entry productivity KPI"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Fields With Errors"
      display_name: "Total Fields With Errors"
      expr: SUM(CAST(fields_with_errors_count AS DOUBLE))
      comment: "Total number of fields with validation errors — data quality indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Field Error Rate"
      display_name: "Field Error Rate"
      expr: ROUND(100.0 * SUM(CAST(fields_with_errors_count AS DOUBLE)) / NULLIF(SUM(CAST(fields_entered_count AS DOUBLE)), 0), 2)
      comment: "Percentage of entered fields with validation errors — data entry quality and training effectiveness KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Queries Generated"
      display_name: "Total Queries Generated"
      expr: SUM(CAST(queries_generated_count AS DOUBLE))
      comment: "Total number of data queries generated during data entry sessions — data quality issue volume"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Query Generation Rate"
      display_name: "Query Generation Rate"
      expr: ROUND(100.0 * SUM(CAST(queries_generated_count AS DOUBLE)) / NULLIF(SUM(CAST(fields_entered_count AS DOUBLE)), 0), 2)
      comment: "Percentage of entered fields generating queries — data quality and site training KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Save Count"
      display_name: "Average Save Count Per Session"
      expr: AVG(CAST(save_count AS DOUBLE))
      comment: "Average number of saves per session — user behavior and system interaction pattern"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Double Data Entry Sessions"
      display_name: "Double Data Entry Sessions"
      expr: SUM(CAST(CASE WHEN is_double_data_entry = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of sessions using double data entry quality control — quality assurance effort"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Double Data Entry Rate"
      display_name: "Double Data Entry Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_double_data_entry = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sessions using double data entry — quality control coverage metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Protocol Deviation Sessions"
      display_name: "Sessions With Protocol Deviations"
      expr: SUM(CAST(CASE WHEN protocol_deviation_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of sessions where protocol deviations were detected — compliance risk indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Protocol Deviation Rate"
      display_name: "Protocol Deviation Detection Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN protocol_deviation_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sessions detecting protocol deviations — protocol compliance monitoring KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_data_entry_session`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Data entry productivity and quality KPIs tracking session duration, field entry rates, error rates, and query generation across EDC operations."
  source: "`clinical_trials_ecm`.`datamanagement`.`data_entry_session`"
  dimensions:
    - name: "Session Status"
      display_name: "Session Status"
      expr: data_entry_session_status
      comment: "Current status of the data entry session"
    - name: "Session Type"
      display_name: "Session Type"
      expr: session_type
      comment: "Type of data entry session (Initial, Update, Correction, Review)"
    - name: "Entry Method"
      display_name: "Entry Method"
      expr: entry_method
      comment: "Method used for data entry (Manual, Import, API, Mobile)"
    - name: "Is Double Data Entry"
      display_name: "Double Data Entry"
      expr: is_double_data_entry
      comment: "Flag indicating whether double data entry was performed for quality assurance"
    - name: "Is Locked"
      display_name: "Locked"
      expr: is_locked
      comment: "Flag indicating whether the session data is locked"
    - name: "Is Source Data Verified"
      display_name: "SDV Complete"
      expr: is_source_data_verified
      comment: "Flag indicating whether source data verification was completed"
    - name: "Protocol Deviation Flag"
      display_name: "Protocol Deviation"
      expr: protocol_deviation_flag
      comment: "Flag indicating whether a protocol deviation was detected during entry"
    - name: "Start Month"
      display_name: "Start Month"
      expr: DATE_TRUNC('month', start_timestamp)
      comment: "Month when the data entry session started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Start Year"
      display_name: "Start Year"
      expr: DATE_TRUNC('year', start_timestamp)
      comment: "Year when the data entry session started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Sessions"
      display_name: "Total Sessions"
      expr: COUNT(1)
      comment: "Total number of data entry sessions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completed Sessions"
      display_name: "Completed Sessions"
      expr: COUNT(CASE WHEN end_timestamp IS NOT NULL THEN 1 END)
      comment: "Count of sessions that have been completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Fields Entered"
      display_name: "Total Fields Entered"
      expr: SUM(CAST(fields_entered_count AS DOUBLE))
      comment: "Total number of fields entered across all sessions, productivity metric"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Fields With Errors"
      display_name: "Total Fields With Errors"
      expr: SUM(CAST(fields_with_errors_count AS DOUBLE))
      comment: "Total number of fields with validation errors, quality metric"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Queries Generated"
      display_name: "Total Queries Generated"
      expr: SUM(CAST(queries_generated_count AS DOUBLE))
      comment: "Total number of queries generated during data entry, quality indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Fields Per Session"
      display_name: "Avg Fields Per Session"
      expr: AVG(CAST(fields_entered_count AS DOUBLE))
      comment: "Average number of fields entered per session, productivity benchmark"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Session Duration Minutes"
      display_name: "Avg Session Duration (min)"
      expr: AVG(CAST(duration_seconds AS DOUBLE)) / 60.0
      comment: "Average session duration in minutes, efficiency metric"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Field Error Rate"
      display_name: "Field Error Rate"
      expr: SUM(CAST(fields_with_errors_count AS DOUBLE)) * 100.0 / NULLIF(SUM(CAST(fields_entered_count AS DOUBLE)), 0)
      comment: "Percentage of fields with errors, key data quality metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Query Generation Rate"
      display_name: "Query Generation Rate"
      expr: SUM(CAST(queries_generated_count AS DOUBLE)) * 100.0 / NULLIF(SUM(CAST(fields_entered_count AS DOUBLE)), 0)
      comment: "Percentage of fields generating queries, data quality indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Fields Per Minute"
      display_name: "Fields Per Minute"
      expr: SUM(CAST(fields_entered_count AS DOUBLE)) / NULLIF(SUM(CAST(duration_seconds AS DOUBLE)) / 60.0, 0)
      comment: "Average fields entered per minute, productivity rate"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Double Entry Sessions"
      display_name: "Double Entry Sessions"
      expr: COUNT(CASE WHEN is_double_data_entry = TRUE THEN 1 END)
      comment: "Count of sessions using double data entry for quality assurance"
      format:
        type: number
        decimal_places:
          type: all
    - name: "SDV Completion Rate"
      display_name: "SDV Completion Rate"
      expr: COUNT(CASE WHEN is_source_data_verified = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of sessions with completed source data verification"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Protocol Deviation Rate"
      display_name: "Protocol Deviation Rate"
      expr: COUNT(CASE WHEN protocol_deviation_flag = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of sessions flagging protocol deviations, compliance metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_discrepancy_query`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Data quality and query management KPIs tracking discrepancy resolution performance, cycle times, and escalation rates across clinical data management operations."
  source: "`clinical_trials_ecm`.`datamanagement`.`discrepancy_query`"
  dimensions:
    - name: "Query Status"
      display_name: "Query Status"
      expr: query_status
      comment: "Current status of the discrepancy query (Open, Closed, Cancelled, Responded)"
    - name: "Query Type"
      display_name: "Query Type"
      expr: query_type
      comment: "Classification of query type (Manual, Automatic, Protocol Deviation, Safety)"
    - name: "Query Category"
      display_name: "Query Category"
      expr: query_category
      comment: "Business category of the discrepancy query"
    - name: "Priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level of the query (High, Medium, Low, Critical)"
    - name: "Is Safety Related"
      display_name: "Safety Related"
      expr: is_safety_related
      comment: "Flag indicating whether the query relates to patient safety"
    - name: "Is DBL Blocking"
      display_name: "DBL Blocking"
      expr: is_dbl_blocking
      comment: "Flag indicating whether the query blocks database lock"
    - name: "Is Escalated"
      display_name: "Escalated"
      expr: is_escalated
      comment: "Flag indicating whether the query has been escalated"
    - name: "Raised Month"
      display_name: "Raised Month"
      expr: DATE_TRUNC('month', raised_timestamp)
      comment: "Month when the query was raised, for time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Closed Month"
      display_name: "Closed Month"
      expr: DATE_TRUNC('month', closed_timestamp)
      comment: "Month when the query was closed, for resolution trend analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Raised Year"
      display_name: "Raised Year"
      expr: DATE_TRUNC('year', raised_timestamp)
      comment: "Year when the query was raised"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Queries"
      display_name: "Total Queries"
      expr: COUNT(1)
      comment: "Total number of discrepancy queries raised"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Queries"
      display_name: "Open Queries"
      expr: COUNT(CASE WHEN query_status IN ('Open', 'Responded') THEN 1 END)
      comment: "Count of queries currently open or awaiting closure"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Closed Queries"
      display_name: "Closed Queries"
      expr: COUNT(CASE WHEN query_status = 'Closed' THEN 1 END)
      comment: "Count of queries successfully closed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Queries"
      display_name: "Safety Queries"
      expr: COUNT(CASE WHEN is_safety_related = TRUE THEN 1 END)
      comment: "Count of queries flagged as safety-related, requiring expedited resolution"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DBL Blocking Queries"
      display_name: "DBL Blocking Queries"
      expr: COUNT(CASE WHEN is_dbl_blocking = TRUE THEN 1 END)
      comment: "Count of queries blocking database lock, critical for study timelines"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalated Queries"
      display_name: "Escalated Queries"
      expr: COUNT(CASE WHEN is_escalated = TRUE THEN 1 END)
      comment: "Count of queries escalated due to delayed resolution"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Days Open"
      display_name: "Avg Days Open"
      expr: AVG(CAST(days_open AS DOUBLE))
      comment: "Average number of days queries remain open, key cycle time metric"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Resolution Cycle Days"
      display_name: "Avg Resolution Cycle Days"
      expr: AVG(CAST(resolution_cycle_days AS DOUBLE))
      comment: "Average days from datamanagement.query raised to closure, measuring resolution efficiency"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Response Cycle Days"
      display_name: "Avg Response Cycle Days"
      expr: AVG(CAST(response_cycle_days AS DOUBLE))
      comment: "Average days from datamanagement.query raised to first response, measuring site responsiveness"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Reopen Count"
      display_name: "Total Reopen Count"
      expr: SUM(CAST(reopen_count AS DOUBLE))
      comment: "Total number of times queries were reopened, indicating data quality issues"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Reopen Count"
      display_name: "Avg Reopen Count"
      expr: AVG(CAST(reopen_count AS DOUBLE))
      comment: "Average number of times a query is reopened, quality indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Rate"
      display_name: "Escalation Rate"
      expr: COUNT(CASE WHEN is_escalated = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of queries escalated, indicating resolution bottlenecks"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Safety Query Rate"
      display_name: "Safety Query Rate"
      expr: COUNT(CASE WHEN is_safety_related = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of queries related to safety, risk indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "DBL Blocking Rate"
      display_name: "DBL Blocking Rate"
      expr: COUNT(CASE WHEN is_dbl_blocking = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of queries blocking database lock, timeline risk metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_query_management`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Data discrepancy query lifecycle and resolution performance metrics tracking query volume, aging, resolution cycle time, and escalation rates across all clinical trial sites and data domains."
  source: "`clinical_trials_ecm`.`datamanagement`.`discrepancy_query`"
  dimensions:
    - name: "Query Status"
      display_name: "Query Status"
      expr: query_status
      comment: "Current status of the data query (OPEN, ANSWERED, CLOSED, CANCELLED, ESCALATED)"
    - name: "Query Type"
      display_name: "Query Type"
      expr: query_type
      comment: "Type of data discrepancy query (MISSING_DATA, INCONSISTENT_DATA, OUT_OF_RANGE, PROTOCOL_DEVIATION, CODING_QUERY)"
    - name: "Query Category"
      display_name: "Query Category"
      expr: query_category
      comment: "Business category of the query (SAFETY, EFFICACY, DEMOGRAPHICS, LAB, CONMED, AE)"
    - name: "Priority"
      display_name: "Query Priority"
      expr: priority
      comment: "Priority level of the query (CRITICAL, HIGH, MEDIUM, LOW)"
    - name: "Is Safety Related"
      display_name: "Safety-Related Query"
      expr: CASE WHEN is_safety_related = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the query relates to safety data (adverse events, serious adverse events)"
    - name: "Is DBL Blocking"
      display_name: "Database Lock Blocking"
      expr: CASE WHEN is_dbl_blocking = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the query blocks database lock and final analysis"
    - name: "Is Escalated"
      display_name: "Escalated Query"
      expr: CASE WHEN is_escalated = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the query has been escalated due to aging or complexity"
    - name: "Raised Month"
      display_name: "Query Raised Month"
      expr: DATE_TRUNC('month', raised_timestamp)
      comment: "Month when the query was raised"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Raised Quarter"
      display_name: "Query Raised Quarter"
      expr: DATE_TRUNC('quarter', raised_timestamp)
      comment: "Quarter when the query was raised"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Raised Year"
      display_name: "Query Raised Year"
      expr: DATE_TRUNC('year', raised_timestamp)
      comment: "Year when the query was raised"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Queries"
      display_name: "Total Queries"
      expr: COUNT(1)
      comment: "Total number of data discrepancy queries raised"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Queries"
      display_name: "Open Queries"
      expr: SUM(CAST(CASE WHEN query_status = 'OPEN' THEN 1 ELSE 0 END AS INT))
      comment: "Count of queries currently open and awaiting site response — operational workload indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Closed Queries"
      display_name: "Closed Queries"
      expr: SUM(CAST(CASE WHEN query_status = 'CLOSED' THEN 1 ELSE 0 END AS INT))
      comment: "Count of queries successfully closed after resolution"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Query Closure Rate"
      display_name: "Query Closure Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN query_status = 'CLOSED' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of queries successfully closed — data quality resolution effectiveness KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days Open"
      display_name: "Average Days Open"
      expr: AVG(CAST(days_open AS DOUBLE))
      comment: "Average number of days queries remain open — query aging and site responsiveness KPI"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Resolution Cycle Days"
      display_name: "Average Resolution Cycle (Days)"
      expr: AVG(CAST(resolution_cycle_days AS DOUBLE))
      comment: "Average number of days from datamanagement.query raised to query closed — end-to-end resolution efficiency KPI"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Response Cycle Days"
      display_name: "Average Response Cycle (Days)"
      expr: AVG(CAST(response_cycle_days AS DOUBLE))
      comment: "Average number of days from datamanagement.query raised to first site response — site engagement KPI"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Safety Queries"
      display_name: "Safety-Related Queries"
      expr: SUM(CAST(CASE WHEN is_safety_related = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of queries related to safety data — regulatory priority indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DBL Blocking Queries"
      display_name: "Database Lock Blocking Queries"
      expr: SUM(CAST(CASE WHEN is_dbl_blocking = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of queries blocking database lock — critical path to study completion"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalated Queries"
      display_name: "Escalated Queries"
      expr: SUM(CAST(CASE WHEN is_escalated = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of queries escalated due to aging or complexity — quality risk indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalation Rate"
      display_name: "Query Escalation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_escalated = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of queries requiring escalation — site performance and data quality risk KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Reopen Count"
      display_name: "Average Reopen Count"
      expr: AVG(CAST(reopen_count AS DOUBLE))
      comment: "Average number of times queries are reopened — query quality and clarity indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Queries With Reopens"
      display_name: "Queries With Reopens"
      expr: SUM(CAST(CASE WHEN reopen_count > 0 THEN 1 ELSE 0 END AS INT))
      comment: "Count of queries reopened at least once — indicates initial resolution inadequacy"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Reopen Rate"
      display_name: "Query Reopen Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN reopen_count > 0 THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of queries requiring reopening — query clarity and site training effectiveness KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_reconciliation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Data reconciliation and quality assurance KPIs tracking discrepancy detection, resolution rates, and reconciliation cycle performance across clinical data systems."
  source: "`clinical_trials_ecm`.`datamanagement`.`reconciliation`"
  dimensions:
    - name: "Reconciliation Status"
      display_name: "Reconciliation Status"
      expr: reconciliation_status
      comment: "Current status of the reconciliation process"
    - name: "Reconciliation Type"
      display_name: "Reconciliation Type"
      expr: reconciliation_type
      comment: "Type of reconciliation (EDC-to-CTMS, Lab-to-EDC, IRT-to-EDC, Safety-to-EDC)"
    - name: "Reconciliation Method"
      display_name: "Method"
      expr: method
      comment: "Method used for reconciliation (Automated, Manual, Hybrid)"
    - name: "Reconciliation Scope"
      display_name: "Scope"
      expr: scope
      comment: "Scope of the reconciliation (Study-wide, Site-specific, Subject-specific)"
    - name: "Escalation Required"
      display_name: "Escalation Required"
      expr: escalation_required
      comment: "Flag indicating whether escalation is required due to critical discrepancies"
    - name: "DBL Required"
      display_name: "DBL Required"
      expr: dbl_required
      comment: "Flag indicating whether database lock is required before reconciliation"
    - name: "Signoff Status"
      display_name: "Signoff Status"
      expr: signoff_status
      comment: "Status of reconciliation signoff (Pending, Approved, Rejected)"
    - name: "Reconciliation Month"
      display_name: "Reconciliation Month"
      expr: DATE_TRUNC('month', reconciliation_date)
      comment: "Month when the reconciliation was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Reconciliation Year"
      display_name: "Reconciliation Year"
      expr: DATE_TRUNC('year', reconciliation_date)
      comment: "Year when the reconciliation was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Reconciliations"
      display_name: "Total Reconciliations"
      expr: COUNT(1)
      comment: "Total number of reconciliation processes executed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Records Compared"
      display_name: "Total Records Compared"
      expr: SUM(CAST(total_records_compared AS DOUBLE))
      comment: "Total number of records compared across all reconciliations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Discrepancies"
      display_name: "Total Discrepancies"
      expr: SUM(CAST(discrepancy_count AS DOUBLE))
      comment: "Total number of discrepancies identified, key quality metric"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Discrepancies"
      display_name: "Critical Discrepancies"
      expr: SUM(CAST(critical_discrepancy_count AS DOUBLE))
      comment: "Total number of critical discrepancies requiring immediate action"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Resolved Discrepancies"
      display_name: "Resolved Discrepancies"
      expr: SUM(CAST(resolved_count AS DOUBLE))
      comment: "Total number of discrepancies successfully resolved"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Outstanding Discrepancies"
      display_name: "Outstanding Discrepancies"
      expr: SUM(CAST(outstanding_count AS DOUBLE))
      comment: "Total number of discrepancies still outstanding, risk indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Waived Discrepancies"
      display_name: "Waived Discrepancies"
      expr: SUM(CAST(waived_count AS DOUBLE))
      comment: "Total number of discrepancies waived after review"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Discrepancy Rate"
      display_name: "Avg Discrepancy Rate"
      expr: AVG(CAST(discrepancy_rate_pct AS DOUBLE))
      comment: "Average discrepancy rate as percentage of records compared, quality benchmark"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Overall Discrepancy Rate"
      display_name: "Overall Discrepancy Rate"
      expr: SUM(CAST(discrepancy_count AS DOUBLE)) * 100.0 / NULLIF(SUM(CAST(total_records_compared AS DOUBLE)), 0)
      comment: "Overall discrepancy rate across all reconciliations, system quality metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Resolution Rate"
      display_name: "Resolution Rate"
      expr: SUM(CAST(resolved_count AS DOUBLE)) * 100.0 / NULLIF(SUM(CAST(discrepancy_count AS DOUBLE)), 0)
      comment: "Percentage of discrepancies resolved, effectiveness metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Critical Discrepancy Rate"
      display_name: "Critical Discrepancy Rate"
      expr: SUM(CAST(critical_discrepancy_count AS DOUBLE)) * 100.0 / NULLIF(SUM(CAST(discrepancy_count AS DOUBLE)), 0)
      comment: "Percentage of discrepancies classified as critical, risk severity metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Rate"
      display_name: "Escalation Rate"
      expr: COUNT(CASE WHEN escalation_required = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of reconciliations requiring escalation, issue severity indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Signoff Completion Rate"
      display_name: "Signoff Completion Rate"
      expr: COUNT(CASE WHEN signoff_status = 'Approved' THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of reconciliations with approved signoff, completion metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_sdtm_dataset`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "SDTM dataset production and quality KPIs tracking dataset generation, validation status, record counts, and regulatory submission readiness."
  source: "`clinical_trials_ecm`.`datamanagement`.`sdtm_dataset`"
  dimensions:
    - name: "Dataset Status"
      display_name: "Dataset Status"
      expr: dataset_status
      comment: "Current status of the SDTM dataset (Draft, QC In Progress, QC Complete, Submission Ready)"
    - name: "Dataset Name"
      display_name: "Dataset Name"
      expr: dataset_name
      comment: "Name of the SDTM dataset (DM, AE, CM, LB, VS, etc.)"
    - name: "Domain Class"
      display_name: "Domain Class"
      expr: domain_class
      comment: "CDISC domain class (Events, Interventions, Findings, Special Purpose)"
    - name: "QC Status"
      display_name: "QC Status"
      expr: qc_status
      comment: "Quality control status of the dataset"
    - name: "Pinnacle21 Validation Status"
      display_name: "Pinnacle21 Status"
      expr: pinnacle21_validation_status
      comment: "Validation status from datamanagement.Pinnacle21 compliance check"
    - name: "Is Submission Ready"
      display_name: "Submission Ready"
      expr: is_submission_ready
      comment: "Flag indicating whether the dataset is ready for regulatory submission"
    - name: "Is Split Dataset"
      display_name: "Split Dataset"
      expr: is_split_dataset
      comment: "Flag indicating whether the dataset is split across multiple files"
    - name: "SUPPQUAL Included"
      display_name: "SUPPQUAL Included"
      expr: suppqual_included
      comment: "Flag indicating whether supplemental qualifiers are included"
    - name: "Generation Month"
      display_name: "Generation Month"
      expr: DATE_TRUNC('month', generation_date)
      comment: "Month when the dataset was generated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Datasets"
      display_name: "Total Datasets"
      expr: COUNT(1)
      comment: "Total number of SDTM datasets produced"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Submission Ready Datasets"
      display_name: "Submission Ready Datasets"
      expr: COUNT(CASE WHEN is_submission_ready = TRUE THEN 1 END)
      comment: "Count of datasets ready for regulatory submission, readiness metric"
      format:
        type: number
        decimal_places:
          type: all
    - name: "QC Complete Datasets"
      display_name: "QC Complete Datasets"
      expr: COUNT(CASE WHEN qc_status = 'Complete' THEN 1 END)
      comment: "Count of datasets with completed quality control"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Records"
      display_name: "Total Records"
      expr: SUM(CAST(record_count AS DOUBLE))
      comment: "Total number of records across all SDTM datasets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects"
      display_name: "Total Subjects"
      expr: SUM(CAST(subject_count AS DOUBLE))
      comment: "Total number of subjects represented across datasets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Variables"
      display_name: "Total Variables"
      expr: SUM(CAST(variable_count AS DOUBLE))
      comment: "Total number of variables across all datasets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total File Size KB"
      display_name: "Total File Size (KB)"
      expr: SUM(CAST(xpt_file_size_kb AS DOUBLE))
      comment: "Total file size of all XPT datasets in kilobytes"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Records Per Dataset"
      display_name: "Avg Records Per Dataset"
      expr: AVG(CAST(record_count AS DOUBLE))
      comment: "Average number of records per dataset"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Variables Per Dataset"
      display_name: "Avg Variables Per Dataset"
      expr: AVG(CAST(variable_count AS DOUBLE))
      comment: "Average number of variables per dataset"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Pinnacle21 Errors"
      display_name: "Total P21 Errors"
      expr: SUM(CAST(pinnacle21_error_count AS DOUBLE))
      comment: "Total number of errors identified by Pinnacle21 validation, quality metric"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Pinnacle21 Warnings"
      display_name: "Total P21 Warnings"
      expr: SUM(CAST(pinnacle21_warning_count AS DOUBLE))
      comment: "Total number of warnings identified by Pinnacle21 validation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Submission Readiness Rate"
      display_name: "Submission Readiness Rate"
      expr: COUNT(CASE WHEN is_submission_ready = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of datasets ready for submission, regulatory readiness metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "QC Completion Rate"
      display_name: "QC Completion Rate"
      expr: COUNT(CASE WHEN qc_status = 'Complete' THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of datasets with completed QC, quality assurance metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Errors Per Dataset"
      display_name: "Avg Errors Per Dataset"
      expr: AVG(CAST(pinnacle21_error_count AS DOUBLE))
      comment: "Average number of Pinnacle21 errors per dataset, quality benchmark"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_sdtm_dataset_quality`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "CDISC SDTM dataset quality, validation, and submission readiness metrics tracking Pinnacle 21 validation results, dataset completeness, and regulatory submission status across all study domains."
  source: "`clinical_trials_ecm`.`datamanagement`.`sdtm_dataset`"
  dimensions:
    - name: "Dataset Name"
      display_name: "SDTM Dataset Name"
      expr: dataset_name
      comment: "CDISC SDTM dataset name (DM, AE, CM, LB, VS, etc.)"
    - name: "Domain Class"
      display_name: "SDTM Domain Class"
      expr: domain_class
      comment: "CDISC domain class (EVENTS, INTERVENTIONS, FINDINGS, SPECIAL_PURPOSE, TRIAL_DESIGN)"
    - name: "Dataset Status"
      display_name: "Dataset Status"
      expr: dataset_status
      comment: "Current status of the SDTM dataset (IN_PROGRESS, QC_REVIEW, VALIDATED, SUBMISSION_READY, SUBMITTED)"
    - name: "QC Status"
      display_name: "QC Status"
      expr: qc_status
      comment: "Quality control status (NOT_STARTED, IN_PROGRESS, PASSED, FAILED, CONDITIONAL_PASS)"
    - name: "Pinnacle21 Validation Status"
      display_name: "Pinnacle 21 Validation Status"
      expr: pinnacle21_validation_status
      comment: "Pinnacle 21 validation result (NOT_RUN, PASSED, PASSED_WITH_WARNINGS, FAILED)"
    - name: "Is Submission Ready"
      display_name: "Submission Ready"
      expr: CASE WHEN is_submission_ready = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the dataset is ready for regulatory submission"
    - name: "SDTM IG Version"
      display_name: "SDTM IG Version"
      expr: sdtm_ig_version
      comment: "CDISC SDTM Implementation Guide version (3.2, 3.3, 3.4)"
    - name: "Generation Month"
      display_name: "Dataset Generation Month"
      expr: DATE_TRUNC('month', generation_date)
      comment: "Month when the dataset was generated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Generation Quarter"
      display_name: "Dataset Generation Quarter"
      expr: DATE_TRUNC('quarter', generation_date)
      comment: "Quarter when the dataset was generated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Generation Year"
      display_name: "Dataset Generation Year"
      expr: DATE_TRUNC('year', generation_date)
      comment: "Year when the dataset was generated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Datasets"
      display_name: "Total SDTM Datasets"
      expr: COUNT(1)
      comment: "Total number of SDTM datasets generated for the study"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Submission Ready Datasets"
      display_name: "Submission-Ready Datasets"
      expr: SUM(CAST(CASE WHEN is_submission_ready = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of datasets validated and ready for regulatory submission — submission readiness KPI"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Submission Readiness Rate"
      display_name: "Submission Readiness Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_submission_ready = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of datasets ready for regulatory submission — critical path to NDA/BLA filing"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Records"
      display_name: "Total SDTM Records"
      expr: SUM(CAST(record_count AS DOUBLE))
      comment: "Total number of records across all SDTM datasets — data volume indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects"
      display_name: "Total Subjects in SDTM"
      expr: SUM(CAST(subject_count AS DOUBLE))
      comment: "Total number of unique subjects represented across SDTM datasets"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Variables"
      display_name: "Total SDTM Variables"
      expr: SUM(CAST(variable_count AS DOUBLE))
      comment: "Total number of variables across all SDTM datasets — dataset complexity indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Variables Per Dataset"
      display_name: "Average Variables Per Dataset"
      expr: AVG(CAST(variable_count AS DOUBLE))
      comment: "Average number of variables per SDTM dataset — dataset complexity metric"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total XPT File Size KB"
      display_name: "Total XPT File Size (KB)"
      expr: SUM(CAST(xpt_file_size_kb AS DOUBLE))
      comment: "Total size of all SAS transport (XPT) files in kilobytes — submission package size"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Pinnacle21 Passed Datasets"
      display_name: "Pinnacle 21 Passed Datasets"
      expr: SUM(CAST(CASE WHEN pinnacle21_validation_status = 'PASSED' THEN 1 ELSE 0 END AS INT))
      comment: "Count of datasets passing Pinnacle 21 validation with no errors or warnings — regulatory quality KPI"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Pinnacle21 Pass Rate"
      display_name: "Pinnacle 21 Pass Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN pinnacle21_validation_status = 'PASSED' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of datasets passing Pinnacle 21 validation — CDISC conformance and submission quality KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total Pinnacle21 Errors"
      display_name: "Total Pinnacle 21 Errors"
      expr: SUM(CAST(pinnacle21_error_count AS DOUBLE))
      comment: "Total number of Pinnacle 21 validation errors across all datasets — submission blocker count"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Pinnacle21 Warnings"
      display_name: "Total Pinnacle 21 Warnings"
      expr: SUM(CAST(pinnacle21_warning_count AS DOUBLE))
      comment: "Total number of Pinnacle 21 validation warnings across all datasets — quality improvement opportunities"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Pinnacle21 Errors Per Dataset"
      display_name: "Average Pinnacle 21 Errors Per Dataset"
      expr: AVG(CAST(pinnacle21_error_count AS DOUBLE))
      comment: "Average number of Pinnacle 21 errors per dataset — dataset quality indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Datasets With Errors"
      display_name: "Datasets With Pinnacle 21 Errors"
      expr: SUM(CAST(CASE WHEN pinnacle21_error_count > 0 THEN 1 ELSE 0 END AS INT))
      comment: "Count of datasets with at least one Pinnacle 21 error — submission blockers requiring remediation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Error Rate"
      display_name: "Dataset Error Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN pinnacle21_error_count > 0 THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of datasets with Pinnacle 21 errors — inverse quality metric for submission readiness"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "QC Passed Datasets"
      display_name: "QC Passed Datasets"
      expr: SUM(CAST(CASE WHEN qc_status = 'PASSED' THEN 1 ELSE 0 END AS INT))
      comment: "Count of datasets passing internal quality control review"
      format:
        type: number
        decimal_places:
          type: all
    - name: "QC Pass Rate"
      display_name: "QC Pass Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN qc_status = 'PASSED' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of datasets passing internal QC — internal quality assurance KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_validation_rule`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Edit check and validation rule effectiveness KPIs tracking rule deployment, activation status, and query generation performance across EDC systems."
  source: "`clinical_trials_ecm`.`datamanagement`.`validation_rule`"
  dimensions:
    - name: "Rule Status"
      display_name: "Rule Status"
      expr: rule_status
      comment: "Current status of the validation rule (Active, Inactive, Draft, Retired)"
    - name: "Rule Type"
      display_name: "Rule Type"
      expr: rule_type
      comment: "Type of validation rule (Range Check, Consistency Check, Mandatory Field, Cross-Form)"
    - name: "Rule Category"
      display_name: "Rule Category"
      expr: rule_category
      comment: "Business category of the validation rule"
    - name: "Severity Level"
      display_name: "Severity Level"
      expr: severity_level
      comment: "Severity level of the validation rule (Error, Warning, Info)"
    - name: "Generates Query"
      display_name: "Generates Query"
      expr: generates_query
      comment: "Flag indicating whether the rule automatically generates a query on failure"
    - name: "Is Mandatory"
      display_name: "Mandatory"
      expr: is_mandatory
      comment: "Flag indicating whether the rule is mandatory for data submission"
    - name: "Is CDISC Compliant"
      display_name: "CDISC Compliant"
      expr: is_cdisc_compliant
      comment: "Flag indicating whether the rule enforces CDISC compliance"
    - name: "CDISC Domain"
      display_name: "CDISC Domain"
      expr: cdisc_domain
      comment: "CDISC domain the rule applies to (DM, AE, CM, LB, etc.)"
    - name: "Activation Month"
      display_name: "Activation Month"
      expr: DATE_TRUNC('month', activation_date)
      comment: "Month when the validation rule was activated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Rules"
      display_name: "Total Rules"
      expr: COUNT(1)
      comment: "Total number of validation rules defined"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Rules"
      display_name: "Active Rules"
      expr: COUNT(CASE WHEN rule_status = 'Active' THEN 1 END)
      comment: "Count of validation rules currently active in production"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Mandatory Rules"
      display_name: "Mandatory Rules"
      expr: COUNT(CASE WHEN is_mandatory = TRUE THEN 1 END)
      comment: "Count of mandatory validation rules required for submission"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Query Generating Rules"
      display_name: "Query Generating Rules"
      expr: COUNT(CASE WHEN generates_query = TRUE THEN 1 END)
      comment: "Count of rules that automatically generate queries on failure"
      format:
        type: number
        decimal_places:
          type: all
    - name: "CDISC Compliant Rules"
      display_name: "CDISC Compliant Rules"
      expr: COUNT(CASE WHEN is_cdisc_compliant = TRUE THEN 1 END)
      comment: "Count of rules enforcing CDISC compliance standards"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Error Level Rules"
      display_name: "Error Level Rules"
      expr: COUNT(CASE WHEN severity_level = 'Error' THEN 1 END)
      comment: "Count of rules with error severity, blocking data submission"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Warning Level Rules"
      display_name: "Warning Level Rules"
      expr: COUNT(CASE WHEN severity_level = 'Warning' THEN 1 END)
      comment: "Count of rules with warning severity, requiring review but not blocking"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Rule Activation Rate"
      display_name: "Rule Activation Rate"
      expr: COUNT(CASE WHEN rule_status = 'Active' THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of rules currently active, deployment effectiveness metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Mandatory Rule Coverage"
      display_name: "Mandatory Rule Coverage"
      expr: COUNT(CASE WHEN is_mandatory = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of rules that are mandatory, compliance coverage metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CDISC Compliance Coverage"
      display_name: "CDISC Compliance Coverage"
      expr: COUNT(CASE WHEN is_cdisc_compliant = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of rules enforcing CDISC standards, regulatory readiness metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`datamanagement`.`datamanagement_validation_rule_effectiveness`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "EDC validation rule effectiveness and coverage metrics tracking rule activation status, query generation rates, and CDISC compliance across all clinical trial data collection forms and fields."
  source: "`clinical_trials_ecm`.`datamanagement`.`validation_rule`"
  dimensions:
    - name: "Rule Type"
      display_name: "Validation Rule Type"
      expr: rule_type
      comment: "Type of validation rule (RANGE_CHECK, CONSISTENCY_CHECK, REQUIRED_FIELD, CROSS_FORM, PROTOCOL_LOGIC)"
    - name: "Rule Category"
      display_name: "Rule Category"
      expr: rule_category
      comment: "Business category of the validation rule (SAFETY, EFFICACY, DEMOGRAPHICS, LAB, PROTOCOL_COMPLIANCE)"
    - name: "Rule Status"
      display_name: "Rule Status"
      expr: rule_status
      comment: "Current status of the validation rule (ACTIVE, INACTIVE, DRAFT, RETIRED, SUSPENDED)"
    - name: "Severity Level"
      display_name: "Severity Level"
      expr: severity_level
      comment: "Severity level of the validation rule (ERROR, WARNING, INFO)"
    - name: "Generates Query"
      display_name: "Generates Query"
      expr: CASE WHEN generates_query = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the validation rule automatically generates a data query when triggered"
    - name: "Is Mandatory"
      display_name: "Mandatory Rule"
      expr: CASE WHEN is_mandatory = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the validation rule is mandatory per protocol or regulatory requirement"
    - name: "Is CDISC Compliant"
      display_name: "CDISC Compliant"
      expr: CASE WHEN is_cdisc_compliant = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the validation rule aligns with CDISC standards and implementation guides"
    - name: "CDISC Domain"
      display_name: "CDISC Domain"
      expr: cdisc_domain
      comment: "CDISC SDTM domain the validation rule applies to (DM, AE, CM, LB, VS, etc.)"
    - name: "Activation Month"
      display_name: "Rule Activation Month"
      expr: DATE_TRUNC('month', activation_date)
      comment: "Month when the validation rule was activated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Activation Quarter"
      display_name: "Rule Activation Quarter"
      expr: DATE_TRUNC('quarter', activation_date)
      comment: "Quarter when the validation rule was activated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Activation Year"
      display_name: "Rule Activation Year"
      expr: DATE_TRUNC('year', activation_date)
      comment: "Year when the validation rule was activated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Validation Rules"
      display_name: "Total Validation Rules"
      expr: COUNT(1)
      comment: "Total number of validation rules defined in the EDC system"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Rules"
      display_name: "Active Validation Rules"
      expr: SUM(CAST(CASE WHEN rule_status = 'ACTIVE' THEN 1 ELSE 0 END AS INT))
      comment: "Count of validation rules currently active and enforcing data quality — operational coverage indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Rule Activation Rate"
      display_name: "Rule Activation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN rule_status = 'ACTIVE' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of validation rules currently active — data quality control coverage KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Query Generating Rules"
      display_name: "Query-Generating Rules"
      expr: SUM(CAST(CASE WHEN generates_query = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of validation rules configured to automatically generate data queries when triggered"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Query Generation Rate"
      display_name: "Query Generation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN generates_query = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of validation rules configured to generate queries — automated quality control coverage"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Mandatory Rules"
      display_name: "Mandatory Validation Rules"
      expr: SUM(CAST(CASE WHEN is_mandatory = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of validation rules required by protocol or regulatory standards — compliance baseline"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Mandatory Rule Coverage"
      display_name: "Mandatory Rule Coverage"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_mandatory = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of validation rules that are mandatory — regulatory compliance coverage indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CDISC Compliant Rules"
      display_name: "CDISC Compliant Rules"
      expr: SUM(CAST(CASE WHEN is_cdisc_compliant = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of validation rules aligned with CDISC standards — standards conformance indicator"
      format:
        type: number
        decimal_places:
          type: all
    - name: "CDISC Compliance Rate"
      display_name: "CDISC Compliance Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_cdisc_compliant = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of validation rules compliant with CDISC standards — submission readiness and standards alignment KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Error Severity Rules"
      display_name: "Error-Severity Rules"
      expr: SUM(CAST(CASE WHEN severity_level = 'ERROR' THEN 1 ELSE 0 END AS INT))
      comment: "Count of validation rules with ERROR severity — data entry blocking rules"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Warning Severity Rules"
      display_name: "Warning-Severity Rules"
      expr: SUM(CAST(CASE WHEN severity_level = 'WARNING' THEN 1 ELSE 0 END AS INT))
      comment: "Count of validation rules with WARNING severity — soft validation rules"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Error Rule Ratio"
      display_name: "Error Rule Ratio"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN severity_level = 'ERROR' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of validation rules with ERROR severity — strictness of data quality enforcement"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Safety Rules"
      display_name: "Safety-Related Rules"
      expr: SUM(CAST(CASE WHEN rule_category = 'SAFETY' THEN 1 ELSE 0 END AS INT))
      comment: "Count of validation rules governing safety data collection — regulatory priority coverage"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Rule Coverage"
      display_name: "Safety Rule Coverage"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN rule_category = 'SAFETY' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of validation rules focused on safety data — safety data quality prioritization indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`datamanagement_alcoa_audit_entry`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "ALCOA+ data integrity and audit trail KPIs tracking compliance with regulatory data quality principles (Attributable, Legible, Contemporaneous, Original, Accurate) across clinical data lifecycle."
  source: "`clinical_trials_ecm`.`data`.`alcoa_audit_entry`"
  dimensions:
    - name: "Action Type"
      display_name: "Action Type"
      expr: action_type
      comment: "Type of action performed (Create, Update, Delete, Review, Approve, Lock)"
    - name: "ALCOA Overall Status"
      display_name: "ALCOA Overall Status"
      expr: alcoa_overall_status
      comment: "Overall ALCOA+ compliance status (Compliant, Non-Compliant, Partial)"
    - name: "User Role"
      display_name: "User Role"
      expr: user_role
      comment: "Role of the user who performed the action (CRA, Data Manager, Investigator, Monitor)"
    - name: "SDV Status"
      display_name: "SDV Status"
      expr: sdv_status
      comment: "Source data verification status (Not Required, Pending, Completed, Failed)"
    - name: "DBL Flag"
      display_name: "Database Lock Flag"
      expr: dbl_flag
      comment: "Flag indicating whether the record is included in database lock"
      format:
        type: boolean
    - name: "Is Accurate"
      display_name: "Accurate"
      expr: is_accurate
      comment: "ALCOA principle: Data is free from errors and conforms to protocol"
      format:
        type: boolean
    - name: "Is Attributable"
      display_name: "Attributable"
      expr: is_attributable
      comment: "ALCOA principle: Data can be traced to the individual who generated it"
      format:
        type: boolean
    - name: "Is Contemporaneous"
      display_name: "Contemporaneous"
      expr: is_contemporaneous
      comment: "ALCOA principle: Data was recorded at the time the activity occurred"
      format:
        type: boolean
    - name: "Is Original"
      display_name: "Original"
      expr: is_original
      comment: "ALCOA principle: Data is the original record or a certified true copy"
      format:
        type: boolean
    - name: "Is Legible"
      display_name: "Legible"
      expr: is_legible
      comment: "ALCOA principle: Data is readable and understandable"
      format:
        type: boolean
    - name: "Is Complete"
      display_name: "Complete"
      expr: is_complete
      comment: "ALCOA+ principle: Data includes all required information"
      format:
        type: boolean
    - name: "Is Consistent"
      display_name: "Consistent"
      expr: is_consistent
      comment: "ALCOA+ principle: Data is internally consistent and coherent"
      format:
        type: boolean
    - name: "Is Enduring"
      display_name: "Enduring"
      expr: is_enduring
      comment: "ALCOA+ principle: Data is preserved and retrievable throughout retention period"
      format:
        type: boolean
    - name: "Is Available"
      display_name: "Available"
      expr: is_available
      comment: "ALCOA+ principle: Data is readily available for review and inspection"
      format:
        type: boolean
    - name: "Event Month"
      display_name: "Event Month"
      expr: DATE_TRUNC('month', event_timestamp)
      comment: "Month when the audit event occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Event Quarter"
      display_name: "Event Quarter"
      expr: DATE_TRUNC('quarter', event_timestamp)
      comment: "Quarter when the audit event occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Event Year"
      display_name: "Event Year"
      expr: DATE_TRUNC('year', event_timestamp)
      comment: "Year when the audit event occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Audit Entries"
      display_name: "Total Audit Entries"
      expr: COUNT(alcoa_audit_entry_id)
      comment: "Total number of audit trail entries recorded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "ALCOA Compliant Entries"
      display_name: "ALCOA Compliant Entries"
      expr: COUNT(CASE WHEN alcoa_overall_status = 'Compliant' THEN alcoa_audit_entry_id END)
      comment: "Number of audit entries fully compliant with ALCOA+ principles"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Accurate Entries"
      display_name: "Accurate Entries"
      expr: COUNT(CASE WHEN is_accurate = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Accurate principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Attributable Entries"
      display_name: "Attributable Entries"
      expr: COUNT(CASE WHEN is_attributable = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Attributable principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Contemporaneous Entries"
      display_name: "Contemporaneous Entries"
      expr: COUNT(CASE WHEN is_contemporaneous = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Contemporaneous principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Original Entries"
      display_name: "Original Entries"
      expr: COUNT(CASE WHEN is_original = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Original principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Legible Entries"
      display_name: "Legible Entries"
      expr: COUNT(CASE WHEN is_legible = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Legible principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Complete Entries"
      display_name: "Complete Entries"
      expr: COUNT(CASE WHEN is_complete = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Complete principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Consistent Entries"
      display_name: "Consistent Entries"
      expr: COUNT(CASE WHEN is_consistent = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Consistent principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Enduring Entries"
      display_name: "Enduring Entries"
      expr: COUNT(CASE WHEN is_enduring = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Enduring principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Available Entries"
      display_name: "Available Entries"
      expr: COUNT(CASE WHEN is_available = TRUE THEN alcoa_audit_entry_id END)
      comment: "Number of entries meeting the Available principle"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Data Entry Lag Minutes"
      display_name: "Avg Data Entry Lag Minutes"
      expr: AVG(CAST(data_entry_lag_minutes AS DOUBLE))
      comment: "Average time lag between event occurrence and data entry in minutes"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "ALCOA Compliance Rate"
      display_name: "ALCOA Compliance Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN alcoa_overall_status = 'Compliant' THEN alcoa_audit_entry_id END) / NULLIF(COUNT(alcoa_audit_entry_id), 0), 2)
      comment: "Percentage of audit entries fully compliant with ALCOA+ principles"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Accurate Rate"
      display_name: "Accurate Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_accurate = TRUE THEN alcoa_audit_entry_id END) / NULLIF(COUNT(alcoa_audit_entry_id), 0), 2)
      comment: "Percentage of entries meeting the Accurate principle"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Attributable Rate"
      display_name: "Attributable Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_attributable = TRUE THEN alcoa_audit_entry_id END) / NULLIF(COUNT(alcoa_audit_entry_id), 0), 2)
      comment: "Percentage of entries meeting the Attributable principle"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Contemporaneous Rate"
      display_name: "Contemporaneous Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_contemporaneous = TRUE THEN alcoa_audit_entry_id END) / NULLIF(COUNT(alcoa_audit_entry_id), 0), 2)
      comment: "Percentage of entries meeting the Contemporaneous principle"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Complete Rate"
      display_name: "Complete Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN is_complete = TRUE THEN alcoa_audit_entry_id END) / NULLIF(COUNT(alcoa_audit_entry_id), 0), 2)
      comment: "Percentage of entries meeting the Complete principle"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
