-- Metric views for domain: monitoring | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`monitoring_action_item`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key performance indicators for action items, tracking volume, closure, escalation and timeliness."
  source: "`clinical_trials_mvm`.`monitoring`.`action_item`"
  dimensions:
    - name: "action_type"
      display_name: "Action Type"
      expr: action_type
      comment: "Type of action item (e.g., Safety, Data, Protocol)"
    - name: "priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level assigned to the action item"
    - name: "status"
      display_name: "Status"
      expr: monitoring_action_item_status
      comment: "Current status of the action item"
    - name: "due_month"
      display_name: "Due Month"
      expr: DATE_TRUNC('month', due_date)
      comment: "Month of the due date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "created_month"
      display_name: "Created Month"
      expr: DATE_TRUNC('month', created_timestamp)
      comment: "Month when the action item was created"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Identifier of the study"
    - name: "study_site_id"
      display_name: "Study Site Id"
      expr: study_site_id
      comment: "Identifier of the study site"
  measures:
    - name: "total_action_items"
      display_name: "Total Action Items"
      expr: COUNT(1)
      comment: "Total number of action items"
      format:
        type: number
        decimal_places:
          type: all
    - name: "closed_action_items"
      display_name: "Closed Action Items"
      expr: SUM(CASE WHEN monitoring_action_item_status = 'Closed' THEN 1 ELSE 0 END)
      comment: "Number of action items that have been closed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "escalated_action_items"
      display_name: "Escalated Action Items"
      expr: SUM(CASE WHEN is_escalated THEN 1 ELSE 0 END)
      comment: "Number of action items that have been escalated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "overdue_action_items"
      display_name: "Overdue Action Items"
      expr: SUM(CASE WHEN due_date < CURRENT_DATE() AND monitoring_action_item_status <> 'Closed' THEN 1 ELSE 0 END)
      comment: "Action items past due and not closed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_overdue"
      display_name: "Avg Days Overdue"
      expr: AVG(CAST(days_overdue AS DOUBLE))
      comment: "Average days overdue for overdue items"
      format:
        type: number
        decimal_places:
          type: all
    - name: "closure_rate"
      display_name: "Closure Rate"
      expr: (AGG(`closed_action_items`) / NULLIF(AGG(`total_action_items`),0))
      comment: "Proportion of action items that are closed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "escalation_rate"
      display_name: "Escalation Rate"
      expr: (AGG(`escalated_action_items`) / NULLIF(AGG(`total_action_items`),0))
      comment: "Proportion of action items that have been escalated"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`monitoring_escalation_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Escalation management metrics tracking escalation response times, resolution effectiveness, and sponsor notification compliance"
  source: "`clinical_trials_mvm`.`monitoring`.`escalation_record`"
  dimensions:
    - name: "escalation_record_id"
      display_name: "Escalation Record ID"
      expr: escalation_record_id
      comment: "Unique identifier for each escalation record"
    - name: "escalation_level"
      display_name: "Escalation Level"
      expr: escalation_level
      comment: "Level of escalation (site, sponsor, regulatory authority, executive)"
    - name: "escalation_status"
      display_name: "Escalation Status"
      expr: escalation_status
      comment: "Current status of the escalation (open, under review, resolved, closed)"
    - name: "escalation_trigger_type"
      display_name: "Escalation Trigger Type"
      expr: escalation_trigger_type
      comment: "Type of event or condition that triggered the escalation"
    - name: "priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level of the escalation (critical, high, medium, low)"
    - name: "resolution_outcome"
      display_name: "Resolution Outcome"
      expr: resolution_outcome
      comment: "Outcome of the escalation resolution process"
    - name: "gcp_finding_category"
      display_name: "GCP Finding Category"
      expr: gcp_finding_category
      comment: "Good Clinical Practice finding category associated with the escalation"
    - name: "notification_status"
      display_name: "Notification Status"
      expr: notification_status
      comment: "Status of required notifications (pending, sent, acknowledged)"
    - name: "escalation_year"
      display_name: "Escalation Year"
      expr: DATE_TRUNC('year', escalation_date)
      comment: "Year when the escalation was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "escalation_month"
      display_name: "Escalation Month"
      expr: DATE_TRUNC('month', escalation_date)
      comment: "Month when the escalation was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_escalations"
      display_name: "Total Escalations"
      expr: COUNT(1)
      comment: "Total number of escalation records created across all studies and sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "critical_priority_escalations"
      display_name: "Critical Priority Escalations"
      expr: SUM(CAST(CASE WHEN priority = 'CRITICAL' THEN 1 ELSE 0 END AS INT))
      comment: "Count of critical priority escalations requiring immediate executive attention"
      format:
        type: number
        decimal_places:
          type: all
    - name: "escalations_with_data_integrity_impact"
      display_name: "Escalations with Data Integrity Impact"
      expr: SUM(CAST(CASE WHEN data_integrity_impact = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of escalations involving data integrity concerns requiring enhanced oversight"
      format:
        type: number
        decimal_places:
          type: all
    - name: "escalations_with_subject_safety_impact"
      display_name: "Escalations with Subject Safety Impact"
      expr: SUM(CAST(CASE WHEN subject_safety_impact = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of escalations involving subject safety concerns requiring immediate intervention"
      format:
        type: number
        decimal_places:
          type: all
    - name: "regulatory_reporting_required"
      display_name: "Regulatory Reporting Required"
      expr: SUM(CAST(CASE WHEN regulatory_reporting_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of escalations requiring regulatory authority notification and reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "sponsor_notified_escalations"
      display_name: "Sponsor Notified Escalations"
      expr: SUM(CAST(CASE WHEN sponsor_notified = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of escalations for which sponsor notification was completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "irb_iec_notified_escalations"
      display_name: "IRB/IEC Notified Escalations"
      expr: SUM(CAST(CASE WHEN irb_iec_notified = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of escalations for which IRB or IEC notification was completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "follow_up_required_escalations"
      display_name: "Follow-up Required Escalations"
      expr: SUM(CAST(CASE WHEN follow_up_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of escalations requiring follow-up action or verification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_overdue_at_escalation"
      display_name: "Avg Days Overdue at Escalation"
      expr: AVG(CAST(days_overdue_at_escalation AS DOUBLE))
      comment: "Average number of days items were overdue before escalation, indicating escalation trigger effectiveness"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`monitoring_risk_indicator`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Risk indicator KPIs used to assess study‑level risk exposure."
  source: "`clinical_trials_mvm`.`monitoring`.`risk_indicator`"
  dimensions:
    - name: "indicator_name"
      display_name: "Indicator Name"
      expr: indicator_name
      comment: "Name of the risk indicator"
    - name: "indicator_type"
      display_name: "Indicator Type"
      expr: indicator_type
      comment: "Category/type of the risk indicator"
    - name: "monitoring_plan_id"
      display_name: "Monitoring Plan Id"
      expr: monitoring_plan_id
      comment: "Monitoring plan associated with the indicator"
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "computation_month"
      display_name: "Computation Month"
      expr: DATE_TRUNC('month', computation_date)
      comment: "Month of indicator computation"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_indicators"
      display_name: "Total Indicators"
      expr: COUNT(1)
      comment: "Total number of risk indicators"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_computed_value"
      display_name: "Avg Computed Value"
      expr: AVG(CAST(computed_value AS DOUBLE))
      comment: "Average computed risk indicator value"
      format:
        type: number
        decimal_places:
          type: all
    - name: "high_risk_indicator_count"
      display_name: "High‑Risk Indicator Count"
      expr: SUM(CASE WHEN computed_value >= 80 THEN 1 ELSE 0 END)
      comment: "Count of indicators with computed value >= 80 (high risk)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_risk_score_contribution"
      display_name: "Total Risk Score Contribution"
      expr: SUM(CAST(risk_score_contribution AS DOUBLE))
      comment: "Sum of risk score contributions from all indicators"
      format:
        type: number
        decimal_places:
          type: all
    - name: "high_risk_indicator_rate"
      display_name: "High‑Risk Indicator Rate"
      expr: (AGG(`high_risk_indicator_count`) / NULLIF(AGG(`total_indicators`),0))
      comment: "Proportion of indicators that are high‑risk"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`monitoring_sdv_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Source data verification KPIs tracking SDV coverage, discrepancy rates, resolution status, and critical data point verification to ensure data quality and GCP compliance"
  source: "`clinical_trials_mvm`.`monitoring`.`sdv_record`"
  dimensions:
    - name: "SDV Type"
      display_name: "SDV Type"
      expr: sdv_type
      comment: "Type of source data verification (full, targeted, remote)"
    - name: "SDV Method"
      display_name: "SDV Method"
      expr: sdv_method
      comment: "Method used for source data verification"
    - name: "SDV Outcome"
      display_name: "SDV Outcome"
      expr: sdv_outcome
      comment: "Outcome of the source data verification (verified, discrepancy, not verifiable)"
    - name: "Resolution Status"
      display_name: "Resolution Status"
      expr: resolution_status
      comment: "Status of discrepancy resolution"
    - name: "Discrepancy Category"
      display_name: "Discrepancy Category"
      expr: discrepancy_category
      comment: "Category classification of the discrepancy found"
    - name: "Source Document Type"
      display_name: "Source Document Type"
      expr: source_document_type
      comment: "Type of source document verified"
    - name: "SDV Month"
      display_name: "SDV Month"
      expr: DATE_TRUNC('month', sdv_performed_timestamp)
      comment: "Month bucket for SDV performed time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "SDV Quarter"
      display_name: "SDV Quarter"
      expr: DATE_TRUNC('quarter', sdv_performed_timestamp)
      comment: "Quarter bucket for SDV performed time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "SDV Year"
      display_name: "SDV Year"
      expr: DATE_TRUNC('year', sdv_performed_timestamp)
      comment: "Year bucket for SDV performed time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Is Critical Data Point"
      display_name: "Is Critical Data Point"
      expr: is_critical_data_point
      comment: "Indicator whether the verified data point is critical"
    - name: "Is SDV Waived"
      display_name: "Is SDV Waived"
      expr: is_sdv_waived
      comment: "Indicator whether SDV was waived for this data point"
    - name: "Regulatory Impact Flag"
      display_name: "Regulatory Impact Flag"
      expr: regulatory_impact_flag
      comment: "Indicator whether the discrepancy has regulatory impact"
  measures:
    - name: "Total SDV Records"
      display_name: "Total SDV Records"
      expr: COUNT(1)
      comment: "Total number of source data verification records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg SDV Coverage"
      display_name: "Avg SDV Coverage"
      expr: AVG(CAST(sdv_coverage_percentage AS DOUBLE))
      comment: "Average SDV coverage percentage across all records"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg RBM Risk Score"
      display_name: "Avg RBM Risk Score"
      expr: AVG(CAST(rbm_risk_score AS DOUBLE))
      comment: "Average risk-based monitoring risk score across SDV records"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Critical Data Point Rate"
      display_name: "Critical Data Point Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_critical_data_point = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of SDV records that are critical data points"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SDV Waiver Rate"
      display_name: "SDV Waiver Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_sdv_waived = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of SDV records where verification was waived"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Impact Rate"
      display_name: "Regulatory Impact Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN regulatory_impact_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of SDV discrepancies with regulatory impact"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Subjects Verified"
      display_name: "Distinct Subjects Verified"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Number of unique trial subjects with SDV records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Sites Verified"
      display_name: "Distinct Sites Verified"
      expr: COUNT(DISTINCT study_site_id)
      comment: "Number of unique study sites with SDV records"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`monitoring_site_risk_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site risk assessment metrics to monitor site‑level risk and data verification status."
  source: "`clinical_trials_mvm`.`monitoring`.`site_risk_assessment`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "study_site_id"
      display_name: "Study Site Id"
      expr: study_site_id
      comment: "Study site identifier"
    - name: "risk_tier"
      display_name: "Risk Tier"
      expr: risk_tier
      comment: "Risk tier assigned to the site"
    - name: "assessment_month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month of the risk assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_assessments"
      display_name: "Total Assessments"
      expr: COUNT(1)
      comment: "Total number of site risk assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_overall_risk_score"
      display_name: "Avg Overall Risk Score"
      expr: AVG(CAST(overall_risk_score AS DOUBLE))
      comment: "Average overall risk score across assessed sites"
      format:
        type: number
        decimal_places:
          type: all
    - name: "high_risk_site_count"
      display_name: "High‑Risk Site Count"
      expr: SUM(CASE WHEN overall_risk_score >= 80 THEN 1 ELSE 0 END)
      comment: "Number of sites with overall risk score >= 80"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_sdv_completion_percent"
      display_name: "Avg SDV Completion %"
      expr: AVG(CAST(sdv_completion_percent AS DOUBLE))
      comment: "Average source data verification completion percent"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "high_risk_site_rate"
      display_name: "High‑Risk Site Rate"
      expr: (AGG(`high_risk_site_count`) / NULLIF(AGG(`total_assessments`),0))
      comment: "Proportion of assessed sites that are high‑risk"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`monitoring_visit_finding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Visit finding KPIs tracking finding severity, resolution rates, regulatory impact, and subject safety impact to drive corrective action and quality improvement"
  source: "`clinical_trials_mvm`.`monitoring`.`visit_finding`"
  dimensions:
    - name: "Finding Category"
      display_name: "Finding Category"
      expr: finding_category
      comment: "Category classification of the visit finding"
    - name: "Finding Subcategory"
      display_name: "Finding Subcategory"
      expr: finding_subcategory
      comment: "Subcategory classification of the visit finding"
    - name: "Severity"
      display_name: "Severity"
      expr: severity
      comment: "Severity level of the finding (critical, major, minor)"
    - name: "Resolution Status"
      display_name: "Resolution Status"
      expr: resolution_status
      comment: "Current resolution status of the finding"
    - name: "Escalation Level"
      display_name: "Escalation Level"
      expr: escalation_level
      comment: "Escalation level of the finding"
    - name: "Visit Type"
      display_name: "Visit Type"
      expr: visit_type
      comment: "Type of monitoring visit where finding was identified"
    - name: "Monitoring Approach"
      display_name: "Monitoring Approach"
      expr: monitoring_approach
      comment: "Monitoring approach used when finding was identified"
    - name: "Identified Month"
      display_name: "Identified Month"
      expr: DATE_TRUNC('month', identified_date)
      comment: "Month bucket for finding identification time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Identified Quarter"
      display_name: "Identified Quarter"
      expr: DATE_TRUNC('quarter', identified_date)
      comment: "Quarter bucket for finding identification time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Identified Year"
      display_name: "Identified Year"
      expr: DATE_TRUNC('year', identified_date)
      comment: "Year bucket for finding identification time-series analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Regulatory Impact"
      display_name: "Regulatory Impact"
      expr: regulatory_impact
      comment: "Indicator whether the finding has regulatory impact"
    - name: "Subject Safety Impact"
      display_name: "Subject Safety Impact"
      expr: subject_safety_impact
      comment: "Indicator whether the finding impacts subject safety"
    - name: "Data Integrity Impact"
      display_name: "Data Integrity Impact"
      expr: data_integrity_impact
      comment: "Indicator whether the finding impacts data integrity"
    - name: "Repeat Finding"
      display_name: "Repeat Finding"
      expr: repeat_finding
      comment: "Indicator whether this is a repeat finding"
    - name: "SDV Required"
      display_name: "SDV Required"
      expr: sdv_required
      comment: "Indicator whether source data verification is required"
    - name: "SDV Completed"
      display_name: "SDV Completed"
      expr: sdv_completed
      comment: "Indicator whether source data verification has been completed"
  measures:
    - name: "Total Findings"
      display_name: "Total Findings"
      expr: COUNT(1)
      comment: "Total number of visit findings identified"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Impact Rate"
      display_name: "Regulatory Impact Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN regulatory_impact = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of findings with regulatory impact"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Subject Safety Impact Rate"
      display_name: "Subject Safety Impact Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN subject_safety_impact = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of findings impacting subject safety"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Data Integrity Impact Rate"
      display_name: "Data Integrity Impact Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN data_integrity_impact = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of findings impacting data integrity"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Repeat Finding Rate"
      display_name: "Repeat Finding Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN repeat_finding = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of findings that are repeat findings"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SDV Required Rate"
      display_name: "SDV Required Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN sdv_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of findings requiring source data verification"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SDV Completion Rate"
      display_name: "SDV Completion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN sdv_completed = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN sdv_required = TRUE THEN 1 ELSE 0 END AS INT)), 0), 2)
      comment: "Percentage of required SDV that has been completed for findings"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Sites With Findings"
      display_name: "Distinct Sites With Findings"
      expr: COUNT(DISTINCT study_site_id)
      comment: "Number of unique study sites with visit findings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Studies With Findings"
      display_name: "Distinct Studies With Findings"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of unique studies with visit findings"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`monitoring_visit_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Visit report KPIs that reflect monitoring activity, query load, and data verification coverage."
  source: "`clinical_trials_mvm`.`monitoring`.`visit_report`"
  dimensions:
    - name: "visit_month"
      display_name: "Visit Month"
      expr: DATE_TRUNC('month', visit_date)
      comment: "Month of the monitoring visit"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "visit_type"
      display_name: "Visit Type"
      expr: visit_type
      comment: "Type of monitoring visit (e.g., On‑site, Remote)"
    - name: "monitoring_approach"
      display_name: "Monitoring Approach"
      expr: monitoring_approach
      comment: "Monitoring approach used for the visit"
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "study_site_id"
      display_name: "Study Site Id"
      expr: study_site_id
      comment: "Study site identifier"
  measures:
    - name: "total_visits"
      display_name: "Total Visits"
      expr: COUNT(1)
      comment: "Total number of monitoring visit reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_open_queries"
      display_name: "Avg Open Queries"
      expr: AVG(CAST(open_queries_count AS DOUBLE))
      comment: "Average number of open queries per visit"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_action_items_outstanding"
      display_name: "Avg Outstanding Action Items"
      expr: AVG(CAST(action_items_outstanding_count AS DOUBLE))
      comment: "Average number of outstanding action items per visit"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_subjects_enrolled"
      display_name: "Total Subjects Enrolled"
      expr: SUM(CAST(subjects_enrolled_count AS DOUBLE))
      comment: "Cumulative count of subjects enrolled across visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_sdv_coverage_percent"
      display_name: "Avg SDV Coverage %"
      expr: AVG(CAST(sdv_coverage_percent AS DOUBLE))
      comment: "Average source data verification coverage percent per visit"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;
