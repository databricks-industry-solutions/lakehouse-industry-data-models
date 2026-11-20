-- Metric views for domain: safety | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`safety_adverse_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Key safety KPI view for adverse events across studies"
  source: "`clinical_trials_mvm`.`safety`.`adverse_event`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "protocol_id"
      display_name: "Protocol Id"
      expr: protocol_id
      comment: "Protocol identifier"
    - name: "investigational_site_id"
      display_name: "Investigational Site Id"
      expr: investigational_site_id
      comment: "Investigational site identifier"
    - name: "is_serious"
      display_name: "Is Serious"
      expr: is_serious
      comment: "Flag indicating if the event is serious"
    - name: "is_susar"
      display_name: "Is Susar"
      expr: is_susar
      comment: "Flag indicating if the event is a SUSAR"
    - name: "ctcae_grade"
      display_name: "Ctcae Grade"
      expr: ctcae_grade
      comment: "CTCAE grade of the event"
    - name: "event_month"
      display_name: "Event Month"
      expr: DATE_TRUNC('month', awareness_date)
      comment: "Month of event awareness"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_adverse_events"
      display_name: "Total Adverse Events"
      expr: COUNT(1)
      comment: "Total number of adverse events recorded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "serious_adverse_events"
      display_name: "Serious Adverse Events"
      expr: SUM(CASE WHEN is_serious THEN 1 ELSE 0 END)
      comment: "Count of adverse events marked as serious"
      format:
        type: number
        decimal_places:
          type: all
    - name: "susar_adverse_events"
      display_name: "SUSAR Adverse Events"
      expr: SUM(CASE WHEN is_susar THEN 1 ELSE 0 END)
      comment: "Count of adverse events classified as SUSAR (Suspected Unexpected Serious Adverse Reaction)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_ctcae_grade"
      display_name: "Average CTCAE Grade"
      expr: AVG(CAST(ctcae_grade AS DOUBLE))
      comment: "Average CTCAE grade across adverse events"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`safety_dsmb_review`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Data Safety Monitoring Board review KPIs tracking meeting frequency, recommendations, stopping rules, and study continuation decisions"
  source: "`clinical_trials_mvm`.`safety`.`dsmb_review`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Clinical Program ID"
      display_name: "Program ID"
      expr: clinical_program_id
      comment: "Unique identifier for the clinical development program"
    - name: "Review Status"
      display_name: "Review Status"
      expr: review_status
      comment: "Current status of the DSMB review"
    - name: "Meeting Type"
      display_name: "Meeting Type"
      expr: meeting_type
      comment: "Type of DSMB meeting (interim, ad-hoc, final, etc.)"
    - name: "Recommendation"
      display_name: "Recommendation"
      expr: recommendation
      comment: "DSMB recommendation outcome (continue, modify, stop, etc.)"
    - name: "Stopping Rule Triggered"
      display_name: "Stopping Rule"
      expr: stopping_rule_triggered
      comment: "Flag indicating whether a pre-defined stopping rule was triggered"
    - name: "Protocol Amendment Required"
      display_name: "Amendment Required"
      expr: protocol_amendment_required
      comment: "Flag indicating whether DSMB recommended a protocol amendment"
    - name: "Safety Signal Identified"
      display_name: "Signal Identified"
      expr: safety_signal_identified
      comment: "Flag indicating whether DSMB identified a new safety signal"
    - name: "Meeting Year"
      display_name: "Meeting Year"
      expr: DATE_TRUNC('year', meeting_date)
      comment: "Year of DSMB meeting"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Meeting Quarter"
      display_name: "Meeting Quarter"
      expr: DATE_TRUNC('quarter', meeting_date)
      comment: "Quarter of DSMB meeting"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Meeting Month"
      display_name: "Meeting Month"
      expr: DATE_TRUNC('month', meeting_date)
      comment: "Month of DSMB meeting"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total DSMB Reviews"
      display_name: "Total Reviews"
      expr: COUNT(1)
      comment: "Total count of DSMB review meetings conducted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Continue Recommendations"
      display_name: "Continue"
      expr: SUM(CAST(CASE WHEN recommendation = 'Continue' THEN 1 ELSE 0 END AS INT))
      comment: "Count of DSMB recommendations to continue the study as planned"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Stop Recommendations"
      display_name: "Stop"
      expr: SUM(CAST(CASE WHEN recommendation = 'Stop' THEN 1 ELSE 0 END AS INT))
      comment: "Count of DSMB recommendations to stop the study"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Modify Recommendations"
      display_name: "Modify"
      expr: SUM(CAST(CASE WHEN recommendation = 'Modify' THEN 1 ELSE 0 END AS INT))
      comment: "Count of DSMB recommendations to modify the study protocol or conduct"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Stopping Rules Triggered"
      display_name: "Stopping Rules"
      expr: SUM(CAST(CASE WHEN stopping_rule_triggered = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reviews where a pre-defined stopping rule was triggered"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Protocol Amendments Required"
      display_name: "Amendments"
      expr: SUM(CAST(CASE WHEN protocol_amendment_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reviews resulting in a protocol amendment requirement"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Safety Signals Identified"
      display_name: "Signals"
      expr: SUM(CAST(CASE WHEN safety_signal_identified = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reviews where DSMB identified a new safety signal"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Quorum Achieved Rate"
      display_name: "Quorum Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN quorum_achieved = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of DSMB meetings achieving required quorum"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Members Present"
      display_name: "Avg Members"
      expr: AVG(CAST(members_present_count AS DOUBLE))
      comment: "Average number of DSMB members present at meetings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects Reviewed"
      display_name: "Subjects Reviewed"
      expr: SUM(CAST(subjects_enrolled_count AS DOUBLE))
      comment: "Total number of enrolled subjects reviewed across all DSMB meetings"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Days to Implementation"
      display_name: "Avg Impl Days"
      expr: AVG(CAST(DATEDIFF(implementation_date, meeting_date) AS DOUBLE))
      comment: "Average number of days from DSMB meeting to implementation of recommendations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Notifications Required"
      display_name: "Reg Notifications"
      expr: SUM(CAST(CASE WHEN regulatory_notification_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of DSMB reviews requiring regulatory authority notification"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`safety_dsur`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Periodic safety reporting (DSUR) KPI view"
  source: "`clinical_trials_mvm`.`safety`.`dsur`"
  dimensions:
    - name: "protocol_id"
      display_name: "Protocol Id"
      expr: protocol_id
      comment: "Protocol identifier"
    - name: "reporting_month"
      display_name: "Reporting Month"
      expr: DATE_TRUNC('month', reporting_period_start_date)
      comment: "Month of the reporting period start"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "cumulative_sae_count_total"
      display_name: "Cumulative SAE Count"
      expr: SUM(CAST(cumulative_sae_count AS DOUBLE))
      comment: "Cumulative count of serious adverse events up to the reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "period_sae_count_total"
      display_name: "Period SAE Count"
      expr: SUM(CAST(period_sae_count AS DOUBLE))
      comment: "Serious adverse events occurring within the reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "fatal_sae_count_total"
      display_name: "Fatal SAE Count"
      expr: SUM(CAST(fatal_sae_count AS DOUBLE))
      comment: "Fatal serious adverse events in the reporting period"
      format:
        type: number
        decimal_places:
          type: all
    - name: "new_safety_signal_identified_count"
      display_name: "New Safety Signals Identified"
      expr: SUM(CASE WHEN new_safety_signal_identified THEN 1 ELSE 0 END)
      comment: "Count of newly identified safety signals during the period"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`safety_icsr`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Individual Case Safety Report KPIs tracking regulatory submission timeliness, acknowledgement rates, and SUSAR reporting compliance"
  source: "`clinical_trials_mvm`.`safety`.`icsr`"
  dimensions:
    - name: "Study ID"
      display_name: "Study"
      expr: study_id
      comment: "Study identifier for study-specific ICSR tracking"
    - name: "Health Authority ID"
      display_name: "Health Authority"
      expr: health_authority_id
      comment: "Health authority identifier for authority-specific submission tracking"
    - name: "Submission Status"
      display_name: "Submission Status"
      expr: submission_status
      comment: "Current status of the ICSR submission (draft, submitted, acknowledged, rejected)"
    - name: "Report Type"
      display_name: "Report Type"
      expr: report_type
      comment: "Type of ICSR report (initial, follow-up, final)"
    - name: "Submission Method"
      display_name: "Submission Method"
      expr: submission_method
      comment: "Method used for ICSR submission (E2B, gateway, portal)"
    - name: "Is SUSAR"
      display_name: "SUSAR Flag"
      expr: is_susar
      comment: "Boolean flag indicating whether the ICSR is for a SUSAR"
    - name: "Is Fatal"
      display_name: "Fatal Flag"
      expr: is_fatal
      comment: "Boolean flag indicating whether the case resulted in death"
    - name: "Is Life Threatening"
      display_name: "Life-Threatening Flag"
      expr: is_life_threatening
      comment: "Boolean flag indicating whether the case was life-threatening"
    - name: "Is On Time"
      display_name: "On-Time Flag"
      expr: is_on_time
      comment: "Boolean flag indicating whether submission met regulatory deadline"
    - name: "DSMB Notified"
      display_name: "DSMB Notified"
      expr: dsmb_notified
      comment: "Boolean flag indicating whether DSMB was notified of the case"
    - name: "IRB IEC Notified"
      display_name: "IRB/IEC Notified"
      expr: irb_iec_notified
      comment: "Boolean flag indicating whether IRB/IEC was notified of the case"
    - name: "Is Current Version"
      display_name: "Current Version"
      expr: is_current_version
      comment: "Boolean flag indicating whether this is the current version of the ICSR"
    - name: "MedDRA SOC"
      display_name: "SOC Code"
      expr: meddra_soc_code
      comment: "MedDRA System Organ Class code for therapeutic area grouping"
    - name: "MedDRA PT"
      display_name: "PT Code"
      expr: meddra_pt_code
      comment: "MedDRA Preferred Term code for standardized case classification"
    - name: "Submission Month"
      display_name: "Submission Month"
      expr: DATE_TRUNC('month', submission_date)
      comment: "Month bucket of submission date for temporal trend analysis"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Awareness Month"
      display_name: "Awareness Month"
      expr: DATE_TRUNC('month', awareness_date)
      comment: "Month bucket of awareness date for reporting timeline tracking"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total ICSR Count"
      display_name: "Total ICSRs"
      expr: COUNT(icsr_id)
      comment: "Total number of Individual Case Safety Reports submitted"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "SUSAR ICSR Count"
      display_name: "SUSAR ICSRs"
      expr: SUM(CAST(CASE WHEN is_susar = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of ICSRs for SUSARs requiring expedited reporting"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Fatal ICSR Count"
      display_name: "Fatal ICSRs"
      expr: SUM(CAST(CASE WHEN is_fatal = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of ICSRs for fatal cases, highest severity outcome"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Life Threatening ICSR Count"
      display_name: "Life-Threatening ICSRs"
      expr: SUM(CAST(CASE WHEN is_life_threatening = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of ICSRs for life-threatening cases requiring immediate attention"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "On Time Submission Count"
      display_name: "On-Time Submissions"
      expr: SUM(CAST(CASE WHEN is_on_time = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of ICSRs submitted within regulatory deadline"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Acknowledged ICSR Count"
      display_name: "Acknowledged ICSRs"
      expr: SUM(CAST(CASE WHEN acknowledgement_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of ICSRs acknowledged by health authority"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "Rejected ICSR Count"
      display_name: "Rejected ICSRs"
      expr: SUM(CAST(CASE WHEN submission_status = 'REJECTED' THEN 1 ELSE 0 END AS INT))
      comment: "Count of ICSRs rejected by health authority, quality indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
    - name: "On Time Submission Rate"
      display_name: "On-Time %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_on_time = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(icsr_id), 0), 2)
      comment: "Percentage of ICSRs submitted on time, key regulatory compliance metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Acknowledgement Rate"
      display_name: "Acknowledgement %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN acknowledgement_date IS NOT NULL THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(icsr_id), 0), 2)
      comment: "Percentage of ICSRs acknowledged by health authority, measures submission quality"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Rejection Rate"
      display_name: "Rejection %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN submission_status = 'REJECTED' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(icsr_id), 0), 2)
      comment: "Percentage of ICSRs rejected, inverse quality indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SUSAR Rate"
      display_name: "SUSAR %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_susar = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(icsr_id), 0), 2)
      comment: "Percentage of ICSRs for SUSARs, key safety signal indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Fatal Case Rate"
      display_name: "Fatality %"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_fatal = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(icsr_id), 0), 2)
      comment: "Percentage of ICSRs for fatal cases, highest severity metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Avg Days to Submission"
      display_name: "Avg Days to Submission"
      expr: AVG(CAST(CAST(DATEDIFF(submission_date, awareness_date) AS DOUBLE) AS DOUBLE))
      comment: "Average days from awareness to submission, measures reporting efficiency"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Days to Acknowledgement"
      display_name: "Avg Days to Acknowledgement"
      expr: AVG(CAST(DATEDIFF(acknowledgement_date, submission_date) AS DOUBLE))
      comment: "Average days from submission to health authority acknowledgement"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Distinct Subjects in ICSRs"
      display_name: "Subjects with ICSRs"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Number of unique subjects with ICSRs submitted"
      format:
        type: number
        decimal_places:
          type: exact
          places: 0
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`safety_serious_adverse_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Metrics focused on serious adverse events, including fatal and SUSAR counts"
  source: "`clinical_trials_mvm`.`safety`.`adverse_event`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "protocol_id"
      display_name: "Protocol Id"
      expr: protocol_id
      comment: "Protocol identifier"
    - name: "is_susar"
      display_name: "Is Susar"
      expr: is_susar
      comment: "Flag indicating SUSAR classification"
    - name: "event_month"
      display_name: "Event Month"
      expr: DATE_TRUNC('month', onset_date)
      comment: "Month of event onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_serious_events"
      display_name: "Total Serious Events"
      expr: COUNT(1)
      comment: "Total number of serious adverse events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "susar_serious_events"
      display_name: "SUSAR Serious Events"
      expr: SUM(CASE WHEN is_susar THEN 1 ELSE 0 END)
      comment: "Count of serious events classified as SUSAR"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_ctcae_grade"
      display_name: "Average CTCAE Grade"
      expr: AVG(CAST(ctcae_grade AS DOUBLE))
      comment: "Average CTCAE grade for serious events"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`safety_signal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Safety signal tracking view with severity and strength metrics"
  source: "`clinical_trials_mvm`.`safety`.`signal`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier"
    - name: "protocol_id"
      display_name: "Protocol Id"
      expr: protocol_id
      comment: "Protocol identifier"
    - name: "signal_status"
      display_name: "Signal Status"
      expr: signal_status
      comment: "Current status of the signal (e.g., open, closed)"
    - name: "priority"
      display_name: "Priority"
      expr: priority
      comment: "Signal priority classification"
    - name: "detection_month"
      display_name: "Detection Month"
      expr: DATE_TRUNC('month', detection_date)
      comment: "Month when the signal was detected"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_signals"
      display_name: "Total Signals"
      expr: COUNT(1)
      comment: "Total number of safety signals recorded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "susar_related_signals"
      display_name: "SUSAR Related Signals"
      expr: SUM(CASE WHEN is_susar_related THEN 1 ELSE 0 END)
      comment: "Count of signals that are SUSAR related"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_strength_value"
      display_name: "Average Strength Value"
      expr: AVG(CAST(strength_value AS DOUBLE))
      comment: "Average quantitative strength metric for signals"
      format:
        type: number
        decimal_places:
          type: all
    - name: "total_case_count"
      display_name: "Total Case Count"
      expr: SUM(CAST(case_count AS DOUBLE))
      comment: "Aggregate number of cases associated with signals"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`safety_susar`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "SUSAR-specific KPIs tracking expedited reporting compliance, causality assessment, and regulatory submission performance"
  source: "`clinical_trials_mvm`.`safety`.`susar`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Site ID"
      display_name: "Site ID"
      expr: investigational_site_id
      comment: "Unique identifier for the investigational site"
    - name: "Causality Assessment"
      display_name: "Causality"
      expr: causality_assessment
      comment: "Sponsor causality assessment for the SUSAR"
    - name: "Reporting Status"
      display_name: "Reporting Status"
      expr: reporting_status
      comment: "Current status of regulatory reporting for the SUSAR"
    - name: "Blind Status"
      display_name: "Blind Status"
      expr: blind_status
      comment: "Blinding status of the SUSAR case"
    - name: "CTCAE Grade"
      display_name: "CTCAE Grade"
      expr: ctcae_grade
      comment: "Common Terminology Criteria for Adverse Events grade (1-5)"
    - name: "MedDRA PT"
      display_name: "MedDRA PT Code"
      expr: meddra_pt_code
      comment: "MedDRA Preferred Term code for the SUSAR"
    - name: "Awareness Year"
      display_name: "Awareness Year"
      expr: DATE_TRUNC('year', awareness_date)
      comment: "Year of sponsor awareness of the SUSAR"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Awareness Quarter"
      display_name: "Awareness Quarter"
      expr: DATE_TRUNC('quarter', awareness_date)
      comment: "Quarter of sponsor awareness of the SUSAR"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Awareness Month"
      display_name: "Awareness Month"
      expr: DATE_TRUNC('month', awareness_date)
      comment: "Month of sponsor awareness of the SUSAR"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total SUSARs"
      display_name: "Total SUSARs"
      expr: COUNT(1)
      comment: "Total count of Suspected Unexpected Serious Adverse Reactions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects with SUSARs"
      display_name: "Subjects with SUSARs"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Count of unique subjects experiencing at least one SUSAR"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Fatal SUSARs"
      display_name: "Fatal SUSARs"
      expr: SUM(CAST(CASE WHEN fatal_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of SUSARs with fatal outcome"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Fatality Rate"
      display_name: "Fatality Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN fatal_date IS NOT NULL THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of SUSARs resulting in death"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Unblinded SUSARs"
      display_name: "Unblinded Cases"
      expr: SUM(CAST(CASE WHEN blind_broken = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of SUSARs requiring emergency unblinding"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DSMB Notified"
      display_name: "DSMB Notified"
      expr: SUM(CAST(CASE WHEN dsmb_notified = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of SUSARs reported to Data Safety Monitoring Board"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IRB Notified"
      display_name: "IRB Notified"
      expr: SUM(CAST(CASE WHEN irb_iec_notified = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of SUSARs reported to Institutional Review Board or Independent Ethics Committee"
      format:
        type: number
        decimal_places:
          type: all
    - name: "7-Day Deadline Breaches"
      display_name: "7-Day Breaches"
      expr: SUM(CASE WHEN deadline_7day < CURRENT_DATE() AND reporting_status != 'Submitted' THEN 1 ELSE 0 END)
      comment: "Count of SUSARs missing the 7-day expedited reporting deadline"
      format:
        type: number
        decimal_places:
          type: all
    - name: "15-Day Deadline Breaches"
      display_name: "15-Day Breaches"
      expr: SUM(CASE WHEN deadline_15day < CURRENT_DATE() AND reporting_status != 'Submitted' THEN 1 ELSE 0 END)
      comment: "Count of SUSARs missing the 15-day expedited reporting deadline"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Days to Awareness"
      display_name: "Avg Days to Awareness"
      expr: AVG(CAST(DATEDIFF(awareness_date, onset_date) AS DOUBLE))
      comment: "Average number of days from SUSAR onset to sponsor awareness"
      format:
        type: number
        decimal_places:
          type: all
$$;
