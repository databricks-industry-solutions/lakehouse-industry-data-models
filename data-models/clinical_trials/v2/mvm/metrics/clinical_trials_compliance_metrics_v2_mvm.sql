-- Metric views for domain: compliance | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`compliance_audit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "High‑level audit performance and outcome metrics"
  source: "`clinical_trials_mvm`.`compliance`.`audit`"
  dimensions:
    - name: "audit_type"
      display_name: "Audit Type"
      expr: audit_type
      comment: "Type of audit (e.g., GCP, SOP)"
  measures:
    - name: "total_audits"
      display_name: "Total Audits"
      expr: COUNT(1)
      comment: "Total number of audit records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "completed_audits"
      display_name: "Completed Audits"
      expr: COUNT(CASE WHEN audit_status = 'Completed' THEN 1 END)
      comment: "Number of audits with status Completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "critical_finding_sum"
      display_name: "Critical Findings Sum"
      expr: SUM(CAST(critical_finding_count AS DOUBLE))
      comment: "Sum of critical findings identified across audits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "observation_sum"
      display_name: "Observation Sum"
      expr: SUM(CAST(observation_count AS DOUBLE))
      comment: "Total number of observations recorded in audits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "major_finding_sum"
      display_name: "Major Findings Sum"
      expr: SUM(CAST(major_finding_count AS DOUBLE))
      comment: "Sum of major findings across audits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "minor_finding_sum"
      display_name: "Minor Findings Sum"
      expr: SUM(CAST(minor_finding_count AS DOUBLE))
      comment: "Sum of minor findings across audits"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`compliance_audit_finding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key effectiveness and timeliness metrics for audit findings"
  source: "`clinical_trials_mvm`.`compliance`.`audit_finding`"
  dimensions:
    - name: "finding_category"
      display_name: "Finding Category"
      expr: finding_category
      comment: "Category of the finding (e.g., Data Integrity, Safety)"
  measures:
    - name: "total_findings"
      display_name: "Total Findings"
      expr: COUNT(1)
      comment: "Total number of audit findings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "findings_requiring_capa"
      display_name: "Findings Requiring CAPA"
      expr: COUNT(CASE WHEN capa_required_flag THEN 1 END)
      comment: "Count of findings where a corrective action plan is required"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_to_close"
      display_name: "Average Days to Close"
      expr: AVG(CAST(DATEDIFF(closure_date, identified_date) AS DOUBLE))
      comment: "Average number of days between finding identification and closure"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_subjects_affected"
      display_name: "Average Subjects Affected"
      expr: AVG(CAST(subject_count_affected AS DOUBLE))
      comment: "Average number of subjects impacted per finding"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`compliance_capa`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "CAPA efficiency and priority distribution metrics"
  source: "`clinical_trials_mvm`.`compliance`.`capa`"
  dimensions:
    - name: "capa_type"
      display_name: "Capa Type"
      expr: capa_type
      comment: "Type of CAPA (e.g., Process, Documentation)"
  measures:
    - name: "total_capa"
      display_name: "Total CAPA"
      expr: COUNT(1)
      comment: "Total number of corrective action plans (CAPA) recorded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_to_completion"
      display_name: "Average Days to Completion"
      expr: AVG(CAST(DATEDIFF(actual_completion_date, initiation_date) AS DOUBLE))
      comment: "Average duration from CAPA initiation to actual completion"
      format:
        type: number
        decimal_places:
          type: all
    - name: "high_priority_capa_count"
      display_name: "High‑Priority CAPA Count"
      expr: COUNT(CASE WHEN priority = 'High' THEN 1 END)
      comment: "Number of CAPA records flagged as High priority"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`compliance_ethics_submission`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Ethics committee submission and approval metrics tracking submission cycle time, approval rates, and regulatory compliance across IRB/IEC submissions."
  source: "`clinical_trials_mvm`.`compliance`.`ethics_submission`"
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

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`compliance_inspection_finding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory inspection finding metrics tracking finding severity, closure performance, repeat findings, and CAPA effectiveness across inspections."
  source: "`clinical_trials_mvm`.`compliance`.`inspection_finding`"
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

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`compliance_protocol_deviation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Operational impact metrics for protocol deviations"
  source: "`clinical_trials_mvm`.`compliance`.`protocol_deviation`"
  dimensions:
    - name: "deviation_category"
      display_name: "Deviation Category"
      expr: deviation_category
      comment: "Category of the protocol deviation"
  measures:
    - name: "total_deviations"
      display_name: "Total Deviations"
      expr: COUNT(1)
      comment: "Total number of protocol deviations recorded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_to_resolution"
      display_name: "Average Days to Resolution"
      expr: AVG(CAST(DATEDIFF(resolution_date, discovery_date) AS DOUBLE))
      comment: "Average time from deviation discovery to resolution"
      format:
        type: number
        decimal_places:
          type: all
    - name: "repeat_deviation_count"
      display_name: "Repeat Deviation Count"
      expr: COUNT(CASE WHEN repeat_deviation_flag THEN 1 END)
      comment: "Number of deviations flagged as repeats"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`compliance_quality_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Quality monitoring metrics for data and process integrity"
  source: "`clinical_trials_mvm`.`compliance`.`quality_event`"
  dimensions:
    - name: "event_type"
      display_name: "Event Type"
      expr: event_type
      comment: "Type of quality event (e.g., Data Issue, Process Failure)"
  measures:
    - name: "total_events"
      display_name: "Total Quality Events"
      expr: COUNT(1)
      comment: "Total number of quality events captured"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_error_rate"
      display_name: "Average Error Rate"
      expr: AVG(CAST(error_rate AS DOUBLE))
      comment: "Mean error rate across quality events"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "total_error_count"
      display_name: "Total Error Count"
      expr: SUM(CAST(error_count AS DOUBLE))
      comment: "Sum of error counts across all quality events"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`compliance_risk_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Strategic risk evaluation metrics for compliance"
  source: "`clinical_trials_mvm`.`compliance`.`risk_assessment`"
  dimensions:
    - name: "risk_category"
      display_name: "Risk Category"
      expr: risk_category
      comment: "Broad risk category (e.g., Operational, Clinical)"
  measures:
    - name: "total_assessments"
      display_name: "Total Risk Assessments"
      expr: COUNT(1)
      comment: "Total number of risk assessment records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_inherent_risk_score"
      display_name: "Average Inherent Risk Score"
      expr: AVG(CAST(inherent_risk_score AS DOUBLE))
      comment: "Mean inherent risk score across assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_residual_risk_score"
      display_name: "Average Residual Risk Score"
      expr: AVG(CAST(residual_risk_score AS DOUBLE))
      comment: "Mean residual risk score after mitigation"
      format:
        type: number
        decimal_places:
          type: all
$$;
