-- Metric views for domain: compliance | Business: Clinical_Trials | Version: 17 | Generated on: 2026-11-20 10:03:07

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`compliance_audit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Audit execution and outcome metrics tracking audit performance, finding severity distribution, and CAPA requirements across audit types and organizational units."
  source: "`clinical_trials_ecm`.`compliance`.`audit`"
  dimensions:
    - name: "Audit Type"
      display_name: "Audit Type"
      expr: audit_type
      comment: "Type of audit conducted (e.g., GCP, site qualification, vendor)"
    - name: "Audit Category"
      display_name: "Audit Category"
      expr: audit_category
      comment: "Category classification of the audit"
    - name: "Audit Status"
      display_name: "Audit Status"
      expr: audit_status
      comment: "Current status of the audit (planned, in progress, completed, closed)"
    - name: "Outcome"
      display_name: "Audit Outcome"
      expr: outcome
      comment: "Overall audit outcome (e.g., acceptable, needs improvement, unacceptable)"
    - name: "Risk Tier"
      display_name: "Risk Tier"
      expr: risk_tier
      comment: "Risk tier assigned to the audit (high, medium, low)"
    - name: "Regulatory Authority"
      display_name: "Regulatory Authority"
      expr: regulatory_authority
      comment: "Regulatory authority overseeing the audit"
    - name: "Audit Year"
      display_name: "Audit Year"
      expr: DATE_TRUNC('year', actual_start_date)
      comment: "Year the audit was started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Audit Quarter"
      display_name: "Audit Quarter"
      expr: DATE_TRUNC('quarter', actual_start_date)
      comment: "Quarter the audit was started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Audit Month"
      display_name: "Audit Month"
      expr: DATE_TRUNC('month', actual_start_date)
      comment: "Month the audit was started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "CAPA Required Flag"
      display_name: "CAPA Required"
      expr: capa_required
      comment: "Whether corrective and preventive action is required"
  measures:
    - name: "Total Audits"
      display_name: "Total Audits"
      expr: COUNT(audit_id)
      comment: "Total number of audits conducted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Critical Findings"
      display_name: "Total Critical Findings"
      expr: SUM(CAST(critical_finding_count AS DOUBLE))
      comment: "Sum of all critical findings across audits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Major Findings"
      display_name: "Total Major Findings"
      expr: SUM(CAST(major_finding_count AS DOUBLE))
      comment: "Sum of all major findings across audits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Minor Findings"
      display_name: "Total Minor Findings"
      expr: SUM(CAST(minor_finding_count AS DOUBLE))
      comment: "Sum of all minor findings across audits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Observations"
      display_name: "Total Observations"
      expr: SUM(CAST(observation_count AS DOUBLE))
      comment: "Sum of all observations across audits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Critical Findings Per Audit"
      display_name: "Avg Critical Findings Per Audit"
      expr: AVG(CAST(critical_finding_count AS DOUBLE))
      comment: "Average number of critical findings per audit"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Risk Priority Score"
      display_name: "Avg Risk Priority Score"
      expr: AVG(CAST(risk_priority_score AS DOUBLE))
      comment: "Average risk priority score across audits"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN capa_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(audit_id), 0)
      comment: "Percentage of audits requiring corrective and preventive action"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Critical Finding Rate"
      display_name: "Critical Finding Rate"
      expr: 100.0 * SUM(CAST(critical_finding_count AS DOUBLE)) / NULLIF(SUM(CAST(critical_finding_count AS DOUBLE)) + SUM(CAST(major_finding_count AS DOUBLE)) + SUM(CAST(minor_finding_count AS DOUBLE)), 0)
      comment: "Percentage of all findings that are critical severity"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`compliance_capa`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Corrective and preventive action (CAPA) effectiveness metrics tracking CAPA completion, timeliness, recurrence prevention, and regulatory impact."
  source: "`clinical_trials_ecm`.`compliance`.`compliance_capa`"
  dimensions:
    - name: "CAPA Type"
      display_name: "CAPA Type"
      expr: capa_type
      comment: "Type of CAPA (corrective, preventive, or both)"
    - name: "CAPA Status"
      display_name: "CAPA Status"
      expr: compliance_capa_status
      comment: "Current status of the CAPA (open, in progress, completed, closed)"
    - name: "Priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level of the CAPA (critical, high, medium, low)"
    - name: "Source Type"
      display_name: "Source Type"
      expr: source_type
      comment: "Source type that triggered the CAPA (audit, inspection, deviation, etc.)"
    - name: "Root Cause Category"
      display_name: "Root Cause Category"
      expr: root_cause_category
      comment: "Root cause category of the issue addressed by CAPA"
    - name: "Responsible Department"
      display_name: "Responsible Department"
      expr: responsible_department
      comment: "Department responsible for CAPA execution"
    - name: "Regulatory Reportable Flag"
      display_name: "Regulatory Reportable"
      expr: regulatory_reportable_flag
      comment: "Whether the CAPA is reportable to regulatory authorities"
    - name: "Recurrence Flag"
      display_name: "Recurrence"
      expr: recurrence_flag
      comment: "Whether this CAPA addresses a recurring issue"
    - name: "Subject Safety Impact Flag"
      display_name: "Subject Safety Impact"
      expr: subject_safety_impact_flag
      comment: "Whether the issue impacts subject safety"
    - name: "Data Integrity Impact Flag"
      display_name: "Data Integrity Impact"
      expr: data_integrity_impact_flag
      comment: "Whether the issue impacts data integrity"
    - name: "CAPA Year"
      display_name: "CAPA Year"
      expr: DATE_TRUNC('year', initiation_date)
      comment: "Year the CAPA was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "CAPA Quarter"
      display_name: "CAPA Quarter"
      expr: DATE_TRUNC('quarter', initiation_date)
      comment: "Quarter the CAPA was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "CAPA Month"
      display_name: "CAPA Month"
      expr: DATE_TRUNC('month', initiation_date)
      comment: "Month the CAPA was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total CAPAs"
      display_name: "Total CAPAs"
      expr: COUNT(compliance_capa_id)
      comment: "Total number of corrective and preventive actions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "On-Time Completion Rate"
      display_name: "On-Time Completion Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN actual_completion_date <= target_completion_date THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN actual_completion_date IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of completed CAPAs finished on or before target date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Complete"
      display_name: "Avg Days to Complete"
      expr: AVG(DATEDIFF(actual_completion_date, initiation_date))
      comment: "Average number of days from CAPA initiation to completion"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Recurrence Rate"
      display_name: "Recurrence Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN recurrence_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(compliance_capa_id), 0)
      comment: "Percentage of CAPAs addressing recurring issues"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Effectiveness Check Pass Rate"
      display_name: "Effectiveness Check Pass Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN effectiveness_check_result = 'Effective' THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN effectiveness_check_result IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of effectiveness checks that passed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Subject Safety Impact Rate"
      display_name: "Subject Safety Impact Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN subject_safety_impact_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(compliance_capa_id), 0)
      comment: "Percentage of CAPAs with subject safety impact"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Reportable Rate"
      display_name: "Regulatory Reportable Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN regulatory_reportable_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(compliance_capa_id), 0)
      comment: "Percentage of CAPAs requiring regulatory reporting"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`compliance_ethics_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Ethics committee submission and approval metrics tracking submission cycle time, approval rates, and regulatory compliance across IRB/IEC submissions."
  source: "`clinical_trials_ecm`.`compliance`.`ethics_submission`"
  dimensions:
    - name: "Submission Type"
      display_name: "Submission Type"
      expr: submission_type
      comment: "Type of ethics submission (initial, amendment, continuing review, SAE report)"
    - name: "Submission Category"
      display_name: "Submission Category"
      expr: submission_category
      comment: "Category of the submission"
    - name: "Submission Status"
      display_name: "Submission Status"
      expr: submission_status
      comment: "Current status of the submission (submitted, under review, approved, rejected)"
    - name: "Decision Outcome"
      display_name: "Decision Outcome"
      expr: decision_outcome
      comment: "Final decision outcome (approved, approved with conditions, deferred, rejected)"
    - name: "Review Type"
      display_name: "Review Type"
      expr: review_type
      comment: "Type of review (full board, expedited, exempt)"
    - name: "Submission Country"
      display_name: "Submission Country"
      expr: submission_country
      comment: "Country where the submission was made"
    - name: "Regulatory Authority"
      display_name: "Regulatory Authority"
      expr: regulatory_authority
      comment: "Regulatory authority overseeing the submission"
    - name: "Submission Year"
      display_name: "Submission Year"
      expr: DATE_TRUNC('year', submission_date)
      comment: "Year the submission was made"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Quarter"
      display_name: "Submission Quarter"
      expr: DATE_TRUNC('quarter', submission_date)
      comment: "Quarter the submission was made"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Month"
      display_name: "Submission Month"
      expr: DATE_TRUNC('month', submission_date)
      comment: "Month the submission was made"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Submissions"
      display_name: "Total Submissions"
      expr: COUNT(ethics_submission_id)
      comment: "Total number of ethics committee submissions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Approval Rate"
      display_name: "Approval Rate"
      expr: 100.0 * SUM(CASE WHEN decision_outcome IN ('Approved', 'Approved with conditions') THEN 1 ELSE 0 END) / NULLIF(SUM(CAST(CASE WHEN decision_outcome IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of submissions approved (with or without conditions)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "First-Pass Approval Rate"
      display_name: "First-Pass Approval Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN decision_outcome = 'Approved' THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN decision_outcome IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of submissions approved without conditions on first review"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Decision"
      display_name: "Avg Days to Decision"
      expr: AVG(DATEDIFF(decision_date, submission_date))
      comment: "Average number of days from submission to decision"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days to Response"
      display_name: "Avg Days to Response"
      expr: AVG(DATEDIFF(response_submitted_date, submission_date))
      comment: "Average number of days from submission to response submission"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "On-Time Response Rate"
      display_name: "On-Time Response Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN response_submitted_date <= response_due_date THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN response_submitted_date IS NOT NULL AND response_due_date IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of responses submitted on or before due date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Waiver Granted Rate"
      display_name: "Waiver Granted Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN waiver_granted = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(ethics_submission_id), 0)
      comment: "Percentage of submissions granted a waiver"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`compliance_inspection_finding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory inspection finding metrics tracking finding severity, closure performance, repeat findings, and CAPA effectiveness across inspections."
  source: "`clinical_trials_ecm`.`compliance`.`inspection_finding`"
  dimensions:
    - name: "Finding Category"
      display_name: "Finding Category"
      expr: finding_category
      comment: "Category of the inspection finding"
    - name: "Finding Classification"
      display_name: "Finding Classification"
      expr: finding_classification
      comment: "Classification of the finding (critical, major, minor, observation)"
    - name: "Finding Status"
      display_name: "Finding Status"
      expr: finding_status
      comment: "Current status of the finding (open, under review, closed)"
    - name: "Root Cause Category"
      display_name: "Root Cause Category"
      expr: root_cause_category
      comment: "Root cause category of the finding"
    - name: "Affected Process Area"
      display_name: "Affected Process Area"
      expr: affected_process_area
      comment: "Process area affected by the finding"
    - name: "Data Integrity Impact"
      display_name: "Data Integrity Impact"
      expr: data_integrity_impact
      comment: "Impact of finding on data integrity (none, low, medium, high)"
    - name: "Subject Safety Impact"
      display_name: "Subject Safety Impact"
      expr: subject_safety_impact
      comment: "Impact of finding on subject safety (none, low, medium, high)"
    - name: "Repeat Finding Flag"
      display_name: "Repeat Finding"
      expr: repeat_finding
      comment: "Whether this is a repeat finding from a prior inspection"
    - name: "CAPA Required Flag"
      display_name: "CAPA Required"
      expr: capa_required
      comment: "Whether corrective and preventive action is required"
    - name: "Authority"
      display_name: "Authority"
      expr: authority
      comment: "Regulatory authority conducting the inspection"
    - name: "Finding Year"
      display_name: "Finding Year"
      expr: DATE_TRUNC('year', finding_date)
      comment: "Year the finding was identified"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Finding Quarter"
      display_name: "Finding Quarter"
      expr: DATE_TRUNC('quarter', finding_date)
      comment: "Quarter the finding was identified"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Finding Month"
      display_name: "Finding Month"
      expr: DATE_TRUNC('month', finding_date)
      comment: "Month the finding was identified"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Findings"
      display_name: "Total Findings"
      expr: COUNT(inspection_finding_id)
      comment: "Total number of inspection findings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Affected Subjects"
      display_name: "Total Affected Subjects"
      expr: SUM(CAST(affected_subject_count AS DOUBLE))
      comment: "Total number of subjects affected by findings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Repeat Finding Rate"
      display_name: "Repeat Finding Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN repeat_finding = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(inspection_finding_id), 0)
      comment: "Percentage of findings that are repeat occurrences"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN capa_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(inspection_finding_id), 0)
      comment: "Percentage of findings requiring corrective and preventive action"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Closure"
      display_name: "Avg Days to Closure"
      expr: AVG(DATEDIFF(closure_date, finding_date))
      comment: "Average number of days from finding identification to closure"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "On-Time Response Rate"
      display_name: "On-Time Response Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN response_submitted_date <= response_due_date THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN response_submitted_date IS NOT NULL AND response_due_date IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of responses submitted on or before due date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Response"
      display_name: "Avg Days to Response"
      expr: AVG(DATEDIFF(response_submitted_date, finding_date))
      comment: "Average number of days from finding identification to response submission"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`compliance_protocol_deviation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Protocol deviation tracking metrics measuring deviation frequency, severity, regulatory impact, and resolution performance across studies and sites."
  source: "`clinical_trials_ecm`.`compliance`.`protocol_deviation`"
  dimensions:
    - name: "Deviation Category"
      display_name: "Deviation Category"
      expr: deviation_category
      comment: "Category of protocol deviation (e.g., inclusion/exclusion, informed consent, dosing)"
    - name: "Deviation Type"
      display_name: "Deviation Type"
      expr: deviation_type
      comment: "Type of protocol deviation"
    - name: "Deviation Status"
      display_name: "Deviation Status"
      expr: deviation_status
      comment: "Current status of the deviation (open, under review, closed)"
    - name: "Root Cause Category"
      display_name: "Root Cause Category"
      expr: root_cause_category
      comment: "Root cause category of the deviation"
    - name: "Data Integrity Impact"
      display_name: "Data Integrity Impact"
      expr: data_integrity_impact
      comment: "Impact of deviation on data integrity (none, low, medium, high)"
    - name: "IRB Reporting Required Flag"
      display_name: "IRB Reporting Required"
      expr: irb_iec_reporting_required
      comment: "Whether IRB/IEC reporting is required for this deviation"
    - name: "Regulatory Reporting Required Flag"
      display_name: "Regulatory Reporting Required"
      expr: regulatory_reporting_required
      comment: "Whether regulatory authority reporting is required"
    - name: "Repeat Deviation Flag"
      display_name: "Repeat Deviation"
      expr: repeat_deviation_flag
      comment: "Whether this is a repeat deviation"
    - name: "PP Exclusion Flag"
      display_name: "Per-Protocol Exclusion"
      expr: subject_excluded_from_pp_flag
      comment: "Whether subject is excluded from per-protocol analysis set"
    - name: "Deviation Year"
      display_name: "Deviation Year"
      expr: DATE_TRUNC('year', occurrence_date)
      comment: "Year the deviation occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Deviation Quarter"
      display_name: "Deviation Quarter"
      expr: DATE_TRUNC('quarter', occurrence_date)
      comment: "Quarter the deviation occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Deviation Month"
      display_name: "Deviation Month"
      expr: DATE_TRUNC('month', occurrence_date)
      comment: "Month the deviation occurred"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Deviations"
      display_name: "Total Deviations"
      expr: COUNT(protocol_deviation_id)
      comment: "Total number of protocol deviations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Repeat Deviation Rate"
      display_name: "Repeat Deviation Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN repeat_deviation_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(protocol_deviation_id), 0)
      comment: "Percentage of deviations that are repeat occurrences"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "IRB Reportable Rate"
      display_name: "IRB Reportable Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN irb_iec_reporting_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(protocol_deviation_id), 0)
      comment: "Percentage of deviations requiring IRB/IEC reporting"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Reportable Rate"
      display_name: "Regulatory Reportable Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN regulatory_reporting_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(protocol_deviation_id), 0)
      comment: "Percentage of deviations requiring regulatory authority reporting"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "PP Exclusion Rate"
      display_name: "Per-Protocol Exclusion Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN subject_excluded_from_pp_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(protocol_deviation_id), 0)
      comment: "Percentage of deviations resulting in per-protocol analysis set exclusion"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Resolution"
      display_name: "Avg Days to Resolution"
      expr: AVG(DATEDIFF(resolution_date, occurrence_date))
      comment: "Average number of days from deviation occurrence to resolution"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days to Detection"
      display_name: "Avg Days to Detection"
      expr: AVG(DATEDIFF(discovery_date, occurrence_date))
      comment: "Average number of days from deviation occurrence to detection"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`compliance_risk_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Risk assessment and mitigation effectiveness metrics tracking inherent vs residual risk, control effectiveness, and remediation performance."
  source: "`clinical_trials_ecm`.`compliance`.`risk_assessment`"
  dimensions:
    - name: "Risk Category"
      display_name: "Risk Category"
      expr: risk_category
      comment: "Category of risk being assessed"
    - name: "Risk Subcategory"
      display_name: "Risk Subcategory"
      expr: risk_subcategory
      comment: "Subcategory of the risk"
    - name: "Assessment Status"
      display_name: "Assessment Status"
      expr: assessment_status
      comment: "Current status of the risk assessment (draft, approved, under review)"
    - name: "Inherent Risk Rating"
      display_name: "Inherent Risk Rating"
      expr: inherent_risk_rating
      comment: "Inherent risk rating before controls (critical, high, medium, low)"
    - name: "Residual Risk Rating"
      display_name: "Residual Risk Rating"
      expr: residual_risk_rating
      comment: "Residual risk rating after controls (critical, high, medium, low)"
    - name: "Risk Acceptance Decision"
      display_name: "Risk Acceptance Decision"
      expr: risk_acceptance_decision
      comment: "Decision on risk acceptance (accepted, mitigate, transfer, avoid)"
    - name: "Remediation Status"
      display_name: "Remediation Status"
      expr: remediation_status
      comment: "Status of risk remediation activities"
    - name: "CAPA Required Flag"
      display_name: "CAPA Required"
      expr: capa_required_flag
      comment: "Whether corrective and preventive action is required"
    - name: "Subject Safety Impact Flag"
      display_name: "Subject Safety Impact"
      expr: subject_safety_impact_flag
      comment: "Whether the risk impacts subject safety"
    - name: "Data Integrity Impact Flag"
      display_name: "Data Integrity Impact"
      expr: data_integrity_impact_flag
      comment: "Whether the risk impacts data integrity"
    - name: "Assessment Year"
      display_name: "Assessment Year"
      expr: DATE_TRUNC('year', assessment_date)
      comment: "Year the risk assessment was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Quarter"
      display_name: "Assessment Quarter"
      expr: DATE_TRUNC('quarter', assessment_date)
      comment: "Quarter the risk assessment was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month the risk assessment was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Risk Assessments"
      display_name: "Total Risk Assessments"
      expr: COUNT(risk_assessment_id)
      comment: "Total number of risk assessments performed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Inherent Risk Score"
      display_name: "Avg Inherent Risk Score"
      expr: AVG(CAST(inherent_risk_score AS DOUBLE))
      comment: "Average inherent risk score before controls"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Residual Risk Score"
      display_name: "Avg Residual Risk Score"
      expr: AVG(CAST(residual_risk_score AS DOUBLE))
      comment: "Average residual risk score after controls"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Risk Reduction"
      display_name: "Avg Risk Reduction"
      expr: AVG(CAST(inherent_risk_score AS DOUBLE) - CAST(residual_risk_score AS DOUBLE))
      comment: "Average reduction in risk score from inherent to residual"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Risk Mitigation Effectiveness"
      display_name: "Risk Mitigation Effectiveness"
      expr: 100.0 * AVG((CAST(inherent_risk_score AS DOUBLE) - CAST(residual_risk_score AS DOUBLE)) / NULLIF(CAST(inherent_risk_score AS DOUBLE), 0))
      comment: "Average percentage reduction in risk score from controls"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "High Residual Risk Rate"
      display_name: "High Residual Risk Rate"
      expr: 100.0 * SUM(CASE WHEN residual_risk_rating IN ('Critical', 'High') THEN 1 ELSE 0 END) / NULLIF(COUNT(risk_assessment_id), 0)
      comment: "Percentage of assessments with high or critical residual risk"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Subject Safety Impact Rate"
      display_name: "Subject Safety Impact Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN subject_safety_impact_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(risk_assessment_id), 0)
      comment: "Percentage of risk assessments with subject safety impact"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Next Review"
      display_name: "Avg Days to Next Review"
      expr: AVG(DATEDIFF(next_review_date, assessment_date))
      comment: "Average number of days until next scheduled risk review"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`compliance_sop_training_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "SOP training compliance metrics tracking training completion rates, timeliness, assessment performance, and currency across staff and SOPs."
  source: "`clinical_trials_ecm`.`compliance`.`sop_training_record`"
  dimensions:
    - name: "Training Status"
      display_name: "Training Status"
      expr: training_status
      comment: "Current status of the training record (scheduled, in progress, completed, expired)"
    - name: "Training Type"
      display_name: "Training Type"
      expr: training_type
      comment: "Type of training (initial, refresher, retraining)"
    - name: "Training Method"
      display_name: "Training Method"
      expr: training_method
      comment: "Method of training delivery (classroom, online, read-and-sign)"
    - name: "SOP Category"
      display_name: "SOP Category"
      expr: sop_category
      comment: "Category of the SOP being trained on"
    - name: "Staff Role"
      display_name: "Staff Role"
      expr: staff_role
      comment: "Role of the staff member being trained"
    - name: "Department"
      display_name: "Department"
      expr: department
      comment: "Department of the staff member"
    - name: "Assessment Passed Flag"
      display_name: "Assessment Passed"
      expr: assessment_passed
      comment: "Whether the training assessment was passed"
    - name: "Current Version Flag"
      display_name: "Current Version Training"
      expr: is_current_version_training
      comment: "Whether this training is for the current SOP version"
    - name: "Completion Year"
      display_name: "Completion Year"
      expr: DATE_TRUNC('year', completion_date)
      comment: "Year the training was completed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Completion Quarter"
      display_name: "Completion Quarter"
      expr: DATE_TRUNC('quarter', completion_date)
      comment: "Quarter the training was completed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Completion Month"
      display_name: "Completion Month"
      expr: DATE_TRUNC('month', completion_date)
      comment: "Month the training was completed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Training Records"
      display_name: "Total Training Records"
      expr: COUNT(sop_training_record_id)
      comment: "Total number of SOP training records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Completion Rate"
      display_name: "Completion Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN training_status = 'Completed' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(sop_training_record_id), 0)
      comment: "Percentage of training records completed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "On-Time Completion Rate"
      display_name: "On-Time Completion Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN completion_date <= due_date THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN completion_date IS NOT NULL AND due_date IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of training completed on or before due date"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Assessment Pass Rate"
      display_name: "Assessment Pass Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN assessment_passed = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN assessment_passed IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0)
      comment: "Percentage of training assessments passed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Assessment Score"
      display_name: "Avg Assessment Score"
      expr: AVG(CAST(assessment_score AS DOUBLE))
      comment: "Average assessment score across all training records"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Training Duration Hours"
      display_name: "Avg Training Duration (Hours)"
      expr: AVG(CAST(training_duration_minutes AS DOUBLE)) / 60.0
      comment: "Average training duration in hours"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Current Version Training Rate"
      display_name: "Current Version Training Rate"
      expr: 100.0 * SUM(CAST(CASE WHEN is_current_version_training = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(sop_training_record_id), 0)
      comment: "Percentage of training records for current SOP versions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Attempt Number"
      display_name: "Avg Attempt Number"
      expr: AVG(CAST(attempt_number AS DOUBLE))
      comment: "Average number of attempts to pass training assessment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`compliance_training_plan`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Training plan KPIs tracking training curriculum volume, GCP compliance requirements, recertification burden, and training effectiveness — critical for workforce qualification and inspection readiness"
  source: "`clinical_trials_ecm`.`compliance`.`training_plan`"
  dimensions:
    - name: "Plan Type"
      display_name: "Plan Type"
      expr: plan_type
      comment: "Type of training plan (e.g., GCP, protocol-specific, system, therapeutic area)"
    - name: "Training Plan Status"
      display_name: "Training Plan Status"
      expr: training_plan_status
      comment: "Current status of the training plan (e.g., active, retired, under review)"
    - name: "Target Audience"
      display_name: "Target Audience"
      expr: target_audience
      comment: "Target audience for the training (e.g., investigators, coordinators, monitors, data managers)"
    - name: "Training Modality"
      display_name: "Training Modality"
      expr: training_modality
      comment: "Delivery modality (e.g., online, in-person, blended)"
    - name: "Therapeutic Area"
      display_name: "Therapeutic Area"
      expr: therapeutic_area
      comment: "Therapeutic area the training applies to (if applicable)"
    - name: "Regulatory Framework"
      display_name: "Regulatory Framework"
      expr: regulatory_framework
      comment: "Regulatory framework the training addresses (e.g., ICH-GCP, FDA 21 CFR Part 11, GDPR)"
    - name: "GCP Compliance Required"
      display_name: "GCP Compliance Required"
      expr: CASE WHEN gcp_compliance_required = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the training is required for GCP compliance"
    - name: "Sponsor Required"
      display_name: "Sponsor Required"
      expr: CASE WHEN sponsor_required = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the training is required by the sponsor"
    - name: "Inspection Readiness Flag"
      display_name: "Inspection Readiness Flag"
      expr: CASE WHEN inspection_readiness_flag = TRUE THEN 'Yes' ELSE 'No' END
      comment: "Whether the training is critical for inspection readiness"
    - name: "Effective From Year"
      display_name: "Effective From Year"
      expr: DATE_TRUNC('year', effective_from_date)
      comment: "Year the training plan became effective"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Effective From Quarter"
      display_name: "Effective From Quarter"
      expr: DATE_TRUNC('quarter', effective_from_date)
      comment: "Quarter the training plan became effective"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Effective From Month"
      display_name: "Effective From Month"
      expr: DATE_TRUNC('month', effective_from_date)
      comment: "Month the training plan became effective"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Training Plans"
      display_name: "Total Training Plans"
      expr: COUNT(training_plan_id)
      comment: "Total count of training plans — primary volume KPI for training curriculum scope"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Training Plans"
      display_name: "Active Training Plans"
      expr: COUNT(CASE WHEN training_plan_status = 'Active' THEN training_plan_id END)
      comment: "Count of active training plans — current training curriculum size KPI"
      format:
        type: number
        decimal_places:
          type: all
    - name: "GCP Required Training Plans"
      display_name: "GCP Required Training Plans"
      expr: COUNT(CASE WHEN gcp_compliance_required = TRUE THEN training_plan_id END)
      comment: "Count of training plans required for GCP compliance — regulatory training burden KPI"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Inspection Critical Training Plans"
      display_name: "Inspection Critical Training Plans"
      expr: COUNT(CASE WHEN inspection_readiness_flag = TRUE THEN training_plan_id END)
      comment: "Count of training plans critical for inspection readiness — inspection preparedness KPI"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Training Hours"
      display_name: "Total Training Hours"
      expr: SUM(CAST(total_training_hours AS DOUBLE))
      comment: "Total training hours across all plans — training time investment KPI"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Training Hours Per Plan"
      display_name: "Avg Training Hours Per Plan"
      expr: AVG(CAST(total_training_hours AS DOUBLE))
      comment: "Average training hours per plan — training complexity indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Total Modules"
      display_name: "Total Modules"
      expr: SUM(CAST(number_of_modules AS DOUBLE))
      comment: "Total count of training modules across all plans — training content volume KPI"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Modules Per Plan"
      display_name: "Avg Modules Per Plan"
      expr: AVG(CAST(number_of_modules AS DOUBLE))
      comment: "Average modules per training plan — training granularity indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Passing Score Threshold"
      display_name: "Avg Passing Score Threshold"
      expr: AVG(CAST(passing_score_percent AS DOUBLE))
      comment: "Average passing score threshold across plans — training rigor indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Recertification Interval Months"
      display_name: "Avg Recertification Interval Months"
      expr: AVG(CAST(recertification_interval_months AS DOUBLE))
      comment: "Average recertification interval in months — training refresh burden KPI"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Plans Requiring Recertification"
      display_name: "Plans Requiring Recertification"
      expr: COUNT(CASE WHEN recertification_interval_months IS NOT NULL THEN training_plan_id END)
      comment: "Count of training plans requiring recertification — ongoing training burden KPI"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Recertification Requirement Rate"
      display_name: "Recertification Requirement Rate"
      expr: ROUND(100.0 * COUNT(CASE WHEN recertification_interval_months IS NOT NULL THEN training_plan_id END) / NULLIF(COUNT(training_plan_id), 0), 2)
      comment: "Percentage of training plans requiring recertification — training maintenance scope KPI"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
