-- Metric views for domain: monitoring | Business: Clinical_Trials | Version: 13 | Generated on: 2026-11-19 16:37:37

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_central_monitoring_alert`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Central monitoring alert KPIs tracking risk-based monitoring signals, KRI breaches, and alert resolution performance"
  source: "`clinical_trials_ecm`.`monitoring`.`central_monitoring_alert`"
  dimensions:
    - name: "Alert Type"
      display_name: "Alert Type"
      expr: alert_type
      comment: "Type of central monitoring alert (KRI breach, data quality, enrollment)"
    - name: "Alert Category"
      display_name: "Alert Category"
      expr: alert_category
      comment: "Category classification of the alert"
    - name: "Alert Severity"
      display_name: "Alert Severity"
      expr: alert_severity
      comment: "Severity level of the alert (critical, high, medium, low)"
    - name: "Alert Status"
      display_name: "Alert Status"
      expr: alert_status
      comment: "Current status of the alert (open, under review, closed)"
    - name: "Trigger Source"
      display_name: "Trigger Source"
      expr: trigger_source
      comment: "Source system or process that triggered the alert"
    - name: "Threshold Type"
      display_name: "Threshold Type"
      expr: threshold_type
      comment: "Type of threshold that was breached (upper, lower, range)"
    - name: "Alert Generated Year"
      display_name: "Alert Year"
      expr: DATE_TRUNC('year', alert_generated_timestamp)
      comment: "Year alert was generated for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Alert Generated Quarter"
      display_name: "Alert Quarter"
      expr: DATE_TRUNC('quarter', alert_generated_timestamp)
      comment: "Quarter alert was generated for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Alert Generated Month"
      display_name: "Alert Month"
      expr: DATE_TRUNC('month', alert_generated_timestamp)
      comment: "Month alert was generated for monthly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Is Repeat Alert"
      display_name: "Repeat Alert"
      expr: is_repeat_alert
      comment: "Whether this is a repeat occurrence of a previous alert"
    - name: "Escalation Required"
      display_name: "Escalation Required"
      expr: escalation_required
      comment: "Whether the alert requires escalation"
    - name: "CAPA Required"
      display_name: "CAPA Required"
      expr: capa_required
      comment: "Whether corrective and preventive action is required"
  measures:
    - name: "Total Alerts"
      display_name: "Total Alerts"
      expr: COUNT(1)
      comment: "Total number of central monitoring alerts generated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Alerts"
      display_name: "Critical Alerts"
      expr: COUNT(CASE WHEN alert_severity = 'Critical' THEN 1 END)
      comment: "Number of critical severity alerts"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Critical Alert Rate"
      display_name: "Critical Alert %"
      expr: COUNT(CASE WHEN alert_severity = 'Critical' THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of alerts classified as critical severity"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Repeat Alerts"
      display_name: "Repeat Alerts"
      expr: COUNT(CASE WHEN is_repeat_alert = TRUE THEN 1 END)
      comment: "Number of alerts that are repeat occurrences"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Repeat Alert Rate"
      display_name: "Repeat Alert %"
      expr: COUNT(CASE WHEN is_repeat_alert = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of alerts that are repeat occurrences"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Required Rate"
      display_name: "Escalation Required %"
      expr: COUNT(CASE WHEN escalation_required = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of alerts requiring escalation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required %"
      expr: COUNT(CASE WHEN capa_required = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of alerts requiring corrective and preventive action"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Consecutive Breach Count"
      display_name: "Avg Consecutive Breaches"
      expr: AVG(CAST(consecutive_breach_count AS DOUBLE))
      comment: "Average number of consecutive threshold breaches per alert"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Observed Value"
      display_name: "Avg Observed Value"
      expr: AVG(CAST(observed_value AS DOUBLE))
      comment: "Average observed value that triggered alerts"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Threshold Value"
      display_name: "Avg Threshold"
      expr: AVG(CAST(threshold_value AS DOUBLE))
      comment: "Average threshold value across alerts"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Studies With Alerts"
      display_name: "Studies With Alerts"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of unique studies with central monitoring alerts"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Sites With Alerts"
      display_name: "Sites With Alerts"
      expr: COUNT(DISTINCT study_site_id)
      comment: "Number of unique study sites with central monitoring alerts"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_escalation_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Escalation management metrics tracking escalation response times, resolution effectiveness, and sponsor notification compliance"
  source: "`clinical_trials_ecm`.`monitoring`.`escalation_record`"
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

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_action_item`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Monitoring action item KPIs tracking issue resolution, escalation, and closure performance"
  source: "`clinical_trials_ecm`.`monitoring`.`monitoring_action_item`"
  dimensions:
    - name: "Action Item Status"
      display_name: "Action Item Status"
      expr: monitoring_action_item_status
      comment: "Current status of the monitoring action item"
    - name: "Action Item Category"
      display_name: "Category"
      expr: monitoring_action_item_category
      comment: "Category classification of the action item"
    - name: "Action Type"
      display_name: "Action Type"
      expr: action_type
      comment: "Type of action required"
    - name: "Priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level of the action item (high, medium, low)"
    - name: "Source Type"
      display_name: "Source Type"
      expr: source_type
      comment: "Source that generated the action item"
    - name: "Raised Year"
      display_name: "Raised Year"
      expr: DATE_TRUNC('year', raised_date)
      comment: "Year action item was raised for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Raised Quarter"
      display_name: "Raised Quarter"
      expr: DATE_TRUNC('quarter', raised_date)
      comment: "Quarter action item was raised for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Raised Month"
      display_name: "Raised Month"
      expr: DATE_TRUNC('month', raised_date)
      comment: "Month action item was raised for monthly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Is Escalated"
      display_name: "Escalated"
      expr: is_escalated
      comment: "Whether the action item has been escalated"
    - name: "Subject Safety Impact"
      display_name: "Safety Impact"
      expr: subject_safety_impact
      comment: "Whether the action item impacts subject safety"
    - name: "Data Integrity Impact"
      display_name: "Data Integrity Impact"
      expr: data_integrity_impact
      comment: "Whether the action item impacts data integrity"
  measures:
    - name: "Total Action Items"
      display_name: "Total Action Items"
      expr: COUNT(1)
      comment: "Total number of monitoring action items raised"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalated Action Items"
      display_name: "Escalated Items"
      expr: COUNT(CASE WHEN is_escalated = TRUE THEN 1 END)
      comment: "Number of action items that have been escalated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalation Rate"
      display_name: "Escalation Rate %"
      expr: COUNT(CASE WHEN is_escalated = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of action items that have been escalated"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Safety Impact Items"
      display_name: "Safety Impact Items"
      expr: COUNT(CASE WHEN subject_safety_impact = TRUE THEN 1 END)
      comment: "Number of action items with subject safety impact"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Impact Rate"
      display_name: "Safety Impact %"
      expr: COUNT(CASE WHEN subject_safety_impact = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of action items with subject safety impact"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Data Integrity Impact Items"
      display_name: "Data Integrity Items"
      expr: COUNT(CASE WHEN data_integrity_impact = TRUE THEN 1 END)
      comment: "Number of action items with data integrity impact"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Data Integrity Impact Rate"
      display_name: "Data Integrity %"
      expr: COUNT(CASE WHEN data_integrity_impact = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of action items with data integrity impact"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days Overdue"
      display_name: "Avg Days Overdue"
      expr: AVG(CAST(days_overdue AS DOUBLE))
      comment: "Average number of days action items are overdue"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Overdue Action Items"
      display_name: "Overdue Items"
      expr: COUNT(CASE WHEN days_overdue > 0 THEN 1 END)
      comment: "Number of action items currently overdue"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Overdue Rate"
      display_name: "Overdue Rate %"
      expr: COUNT(CASE WHEN days_overdue > 0 THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of action items currently overdue"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Studies With Action Items"
      display_name: "Studies With Items"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of unique studies with monitoring action items"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Sites With Action Items"
      display_name: "Sites With Items"
      expr: COUNT(DISTINCT study_site_id)
      comment: "Number of unique study sites with monitoring action items"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_visit`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core monitoring visit KPIs tracking visit execution, findings, and action items across studies and sites"
  source: "`clinical_trials_ecm`.`monitoring`.`monitoring_visit`"
  dimensions:
    - name: "Visit Type"
      display_name: "Visit Type"
      expr: visit_type
      comment: "Type of monitoring visit (initiation, interim, closeout, remote)"
    - name: "Visit Status"
      display_name: "Visit Status"
      expr: visit_status
      comment: "Current status of the monitoring visit"
    - name: "Visit Mode"
      display_name: "Visit Mode"
      expr: visit_mode
      comment: "Mode of visit delivery (on-site, remote, hybrid)"
    - name: "Visit Purpose"
      display_name: "Visit Purpose"
      expr: visit_purpose
      comment: "Primary purpose or objective of the monitoring visit"
    - name: "Actual Visit Year"
      display_name: "Visit Year"
      expr: DATE_TRUNC('year', actual_date)
      comment: "Year of actual visit date for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Visit Quarter"
      display_name: "Visit Quarter"
      expr: DATE_TRUNC('quarter', actual_date)
      comment: "Quarter of actual visit date for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Actual Visit Month"
      display_name: "Visit Month"
      expr: DATE_TRUNC('month', actual_date)
      comment: "Month of actual visit date for monthly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "SDV Completed Flag"
      display_name: "SDV Completed"
      expr: sdv_completed_flag
      comment: "Whether source data verification was completed during the visit"
    - name: "Follow Up Required"
      display_name: "Follow-Up Required"
      expr: follow_up_required
      comment: "Whether follow-up actions are required post-visit"
  measures:
    - name: "Total Monitoring Visits"
      display_name: "Total Visits"
      expr: COUNT(1)
      comment: "Total number of monitoring visits conducted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Action Items Raised"
      display_name: "Total Action Items"
      expr: SUM(CAST(action_items_count AS DOUBLE))
      comment: "Total number of action items raised across all monitoring visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Action Items Per Visit"
      display_name: "Avg Action Items/Visit"
      expr: AVG(CAST(action_items_count AS DOUBLE))
      comment: "Average number of action items raised per monitoring visit"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Visits With Follow Up Required"
      display_name: "Visits Requiring Follow-Up"
      expr: COUNT(CASE WHEN follow_up_required = TRUE THEN 1 END)
      comment: "Number of visits requiring follow-up actions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Follow Up Required Rate"
      display_name: "Follow-Up Rate"
      expr: COUNT(CASE WHEN follow_up_required = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of monitoring visits requiring follow-up actions"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SDV Completion Rate"
      display_name: "SDV Completion %"
      expr: COUNT(CASE WHEN sdv_completed_flag = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of monitoring visits where source data verification was completed"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Studies Monitored"
      display_name: "Studies Monitored"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of unique studies with monitoring visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Sites Monitored"
      display_name: "Sites Monitored"
      expr: COUNT(DISTINCT site_study_site_id)
      comment: "Number of unique study sites receiving monitoring visits"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_risk_indicator`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key risk indicator (KRI) performance metrics tracking threshold breaches, trend direction, and risk score contribution"
  source: "`clinical_trials_ecm`.`monitoring`.`risk_indicator`"
  dimensions:
    - name: "Indicator Type"
      display_name: "Indicator Type"
      expr: indicator_type
      comment: "Type of risk indicator (KRI, quality metric, performance metric)"
    - name: "Risk Indicator Category"
      display_name: "Category"
      expr: risk_indicator_category
      comment: "Category classification of the risk indicator"
    - name: "Indicator Status"
      display_name: "Indicator Status"
      expr: indicator_status
      comment: "Current status of the risk indicator (active, inactive, retired)"
    - name: "Alert Status"
      display_name: "Alert Status"
      expr: alert_status
      comment: "Alert status based on threshold evaluation (green, amber, red)"
    - name: "Threshold Direction"
      display_name: "Threshold Direction"
      expr: threshold_direction
      comment: "Direction of threshold evaluation (above, below, within range)"
    - name: "Trend Direction"
      display_name: "Trend Direction"
      expr: trend_direction
      comment: "Trend direction of the indicator (improving, stable, worsening)"
    - name: "Computation Year"
      display_name: "Computation Year"
      expr: DATE_TRUNC('year', computation_date)
      comment: "Year of indicator computation for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Computation Quarter"
      display_name: "Computation Quarter"
      expr: DATE_TRUNC('quarter', computation_date)
      comment: "Quarter of indicator computation for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Computation Month"
      display_name: "Computation Month"
      expr: DATE_TRUNC('month', computation_date)
      comment: "Month of indicator computation for monthly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Is Centralized Monitoring"
      display_name: "Centralized Monitoring"
      expr: is_centralized_monitoring
      comment: "Whether this is a centralized monitoring indicator"
    - name: "Escalation Required"
      display_name: "Escalation Required"
      expr: escalation_required
      comment: "Whether the indicator requires escalation"
    - name: "CAPA Required"
      display_name: "CAPA Required"
      expr: capa_required
      comment: "Whether corrective and preventive action is required"
  measures:
    - name: "Total Risk Indicators"
      display_name: "Total Indicators"
      expr: COUNT(1)
      comment: "Total number of risk indicator computations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Computed Value"
      display_name: "Avg Computed Value"
      expr: AVG(CAST(computed_value AS DOUBLE))
      comment: "Average computed value across all risk indicators"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Red Threshold"
      display_name: "Avg Red Threshold"
      expr: AVG(CAST(red_threshold AS DOUBLE))
      comment: "Average red threshold value across risk indicators"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Amber Threshold"
      display_name: "Avg Amber Threshold"
      expr: AVG(CAST(amber_threshold AS DOUBLE))
      comment: "Average amber threshold value across risk indicators"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Red Alert Indicators"
      display_name: "Red Alerts"
      expr: COUNT(CASE WHEN alert_status = 'Red' THEN 1 END)
      comment: "Number of risk indicators in red alert status"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Red Alert Rate"
      display_name: "Red Alert %"
      expr: COUNT(CASE WHEN alert_status = 'Red' THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of risk indicators in red alert status"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Consecutive Breach Count"
      display_name: "Avg Consecutive Breaches"
      expr: AVG(CAST(consecutive_breach_count AS DOUBLE))
      comment: "Average number of consecutive threshold breaches"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Risk Score Contribution"
      display_name: "Avg Risk Contribution"
      expr: AVG(CAST(risk_score_contribution AS DOUBLE))
      comment: "Average risk score contribution across indicators"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Escalation Required Rate"
      display_name: "Escalation Required %"
      expr: COUNT(CASE WHEN escalation_required = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of indicators requiring escalation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required %"
      expr: COUNT(CASE WHEN capa_required = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of indicators requiring corrective and preventive action"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Studies Monitored"
      display_name: "Studies Monitored"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of unique studies with risk indicator monitoring"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Sites Monitored"
      display_name: "Sites Monitored"
      expr: COUNT(DISTINCT study_site_id)
      comment: "Number of unique study sites with risk indicator monitoring"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_sdv_record`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Source data verification KPIs tracking SDV coverage, discrepancy rates, resolution status, and critical data point verification to ensure data quality and GCP compliance"
  source: "`clinical_trials_ecm`.`monitoring`.`sdv_record`"
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

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_site_risk_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Site risk assessment KPIs tracking risk scores, tier distribution, and quality indicators across study sites"
  source: "`clinical_trials_ecm`.`monitoring`.`site_risk_assessment`"
  dimensions:
    - name: "Risk Tier"
      display_name: "Risk Tier"
      expr: risk_tier
      comment: "Risk tier classification (high, medium, low) assigned to the site"
    - name: "Assessment Type"
      display_name: "Assessment Type"
      expr: assessment_type
      comment: "Type of risk assessment conducted (initial, periodic, triggered)"
    - name: "Assessment Status"
      display_name: "Assessment Status"
      expr: assessment_status
      comment: "Current status of the risk assessment"
    - name: "Approval Status"
      display_name: "Approval Status"
      expr: approval_status
      comment: "Approval status of the risk assessment"
    - name: "Assessment Year"
      display_name: "Assessment Year"
      expr: DATE_TRUNC('year', assessment_date)
      comment: "Year of risk assessment for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Quarter"
      display_name: "Assessment Quarter"
      expr: DATE_TRUNC('quarter', assessment_date)
      comment: "Quarter of risk assessment for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month of risk assessment for monthly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "CAPA Required"
      display_name: "CAPA Required"
      expr: capa_required
      comment: "Whether corrective and preventive action is required based on assessment"
  measures:
    - name: "Total Risk Assessments"
      display_name: "Total Assessments"
      expr: COUNT(1)
      comment: "Total number of site risk assessments conducted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Overall Risk Score"
      display_name: "Avg Risk Score"
      expr: AVG(CAST(overall_risk_score AS DOUBLE))
      comment: "Average overall risk score across all site assessments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Protocol Deviation Count"
      display_name: "Avg Protocol Deviations"
      expr: AVG(CAST(protocol_deviation_count AS DOUBLE))
      comment: "Average number of protocol deviations per site assessment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Major Deviation Count"
      display_name: "Avg Major Deviations"
      expr: AVG(CAST(major_protocol_deviation_count AS DOUBLE))
      comment: "Average number of major protocol deviations per site assessment"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Query Rate"
      display_name: "Avg Query Rate %"
      expr: AVG(CAST(query_rate_percent AS DOUBLE))
      comment: "Average query rate percentage across site assessments"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Enrollment Rate"
      display_name: "Avg Enrollment Rate %"
      expr: AVG(CAST(enrollment_rate_percent AS DOUBLE))
      comment: "Average enrollment rate percentage across site assessments"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Screen Failure Rate"
      display_name: "Avg Screen Failure %"
      expr: AVG(CAST(screen_failure_rate_percent AS DOUBLE))
      comment: "Average screen failure rate percentage across site assessments"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Subject Dropout Rate"
      display_name: "Avg Dropout Rate %"
      expr: AVG(CAST(subject_dropout_rate_percent AS DOUBLE))
      comment: "Average subject dropout rate percentage across site assessments"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg SDV Completion"
      display_name: "Avg SDV Completion %"
      expr: AVG(CAST(sdv_completion_percent AS DOUBLE))
      comment: "Average source data verification completion percentage across site assessments"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "High Risk Sites"
      display_name: "High Risk Sites"
      expr: COUNT(CASE WHEN risk_tier = 'High' THEN 1 END)
      comment: "Number of sites classified as high risk"
      format:
        type: number
        decimal_places:
          type: all
    - name: "High Risk Site Rate"
      display_name: "High Risk %"
      expr: COUNT(CASE WHEN risk_tier = 'High' THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of sites classified as high risk"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required %"
      expr: COUNT(CASE WHEN capa_required = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of assessments requiring corrective and preventive action"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Sites Assessed"
      display_name: "Sites Assessed"
      expr: COUNT(DISTINCT study_site_id)
      comment: "Number of unique study sites with risk assessments"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_visit_finding`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Visit finding KPIs tracking finding severity, resolution rates, regulatory impact, and subject safety impact to drive corrective action and quality improvement"
  source: "`clinical_trials_ecm`.`monitoring`.`visit_finding`"
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

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`monitoring_visit_report`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Monitoring visit report KPIs tracking SDV coverage, query resolution, protocol deviations, and site performance"
  source: "`clinical_trials_ecm`.`monitoring`.`visit_report`"
  dimensions:
    - name: "Report Status"
      display_name: "Report Status"
      expr: report_status
      comment: "Current status of the visit report (draft, submitted, approved)"
    - name: "Visit Type"
      display_name: "Visit Type"
      expr: visit_type
      comment: "Type of monitoring visit reported (initiation, interim, closeout)"
    - name: "Monitoring Approach"
      display_name: "Monitoring Approach"
      expr: monitoring_approach
      comment: "Monitoring approach used during the visit (on-site, remote, hybrid)"
    - name: "Site Overall Rating"
      display_name: "Site Rating"
      expr: site_overall_rating
      comment: "Overall performance rating assigned to the site"
    - name: "Visit Year"
      display_name: "Visit Year"
      expr: DATE_TRUNC('year', visit_date)
      comment: "Year of visit for annual trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Visit Quarter"
      display_name: "Visit Quarter"
      expr: DATE_TRUNC('quarter', visit_date)
      comment: "Quarter of visit for quarterly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Visit Month"
      display_name: "Visit Month"
      expr: DATE_TRUNC('month', visit_date)
      comment: "Month of visit for monthly trending"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "CAPA Required"
      display_name: "CAPA Required"
      expr: capa_required
      comment: "Whether corrective and preventive action is required based on visit findings"
    - name: "ICF Review Conducted"
      display_name: "ICF Review Done"
      expr: icf_review_conducted
      comment: "Whether informed consent form review was conducted"
    - name: "IP Accountability Reviewed"
      display_name: "IP Accountability Done"
      expr: ip_accountability_reviewed
      comment: "Whether investigational product accountability was reviewed"
  measures:
    - name: "Total Visit Reports"
      display_name: "Total Reports"
      expr: COUNT(1)
      comment: "Total number of monitoring visit reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg SDV Coverage Percent"
      display_name: "Avg SDV Coverage %"
      expr: AVG(CAST(sdv_coverage_percent AS DOUBLE))
      comment: "Average source data verification coverage percentage across visit reports"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Total SDV Discrepancies"
      display_name: "Total SDV Discrepancies"
      expr: SUM(CAST(sdv_discrepancies_found AS DOUBLE))
      comment: "Total number of source data verification discrepancies found"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg SDV Discrepancies Per Visit"
      display_name: "Avg SDV Discrepancies"
      expr: AVG(CAST(sdv_discrepancies_found AS DOUBLE))
      comment: "Average number of SDV discrepancies found per visit"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Protocol Deviations"
      display_name: "Total Protocol Deviations"
      expr: SUM(CAST(protocol_deviations_identified AS DOUBLE))
      comment: "Total number of protocol deviations identified across all visit reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Protocol Deviations Per Visit"
      display_name: "Avg Protocol Deviations"
      expr: AVG(CAST(protocol_deviations_identified AS DOUBLE))
      comment: "Average number of protocol deviations identified per visit"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Action Items Raised"
      display_name: "Total Action Items Raised"
      expr: SUM(CAST(action_items_raised_count AS DOUBLE))
      comment: "Total number of action items raised across all visit reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Action Items Per Visit"
      display_name: "Avg Action Items/Visit"
      expr: AVG(CAST(action_items_raised_count AS DOUBLE))
      comment: "Average number of action items raised per visit"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Total Queries Raised"
      display_name: "Total Queries Raised"
      expr: SUM(CAST(queries_raised_count AS DOUBLE))
      comment: "Total number of data queries raised across all visit reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Queries Resolved"
      display_name: "Total Queries Resolved"
      expr: SUM(CAST(queries_resolved_count AS DOUBLE))
      comment: "Total number of data queries resolved during visits"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Query Resolution Rate"
      display_name: "Query Resolution %"
      expr: SUM(CAST(queries_resolved_count AS DOUBLE)) * 100.0 / NULLIF(SUM(CAST(queries_raised_count AS DOUBLE)), 0)
      comment: "Percentage of raised queries that were resolved during visits"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "CAPA Required Rate"
      display_name: "CAPA Required %"
      expr: COUNT(CASE WHEN capa_required = TRUE THEN 1 END) * 100.0 / NULLIF(COUNT(1), 0)
      comment: "Percentage of visit reports requiring corrective and preventive action"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Distinct Studies Reported"
      display_name: "Studies Reported"
      expr: COUNT(DISTINCT study_id)
      comment: "Number of unique studies with visit reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Distinct Sites Reported"
      display_name: "Sites Reported"
      expr: COUNT(DISTINCT study_site_id)
      comment: "Number of unique study sites with visit reports"
      format:
        type: number
        decimal_places:
          type: all
$$;
