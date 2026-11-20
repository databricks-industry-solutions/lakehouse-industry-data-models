-- Metric views for domain: safety | Business: Clinical_Trials | Version: 17 | Generated on: 2026-11-20 10:03:07

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_adverse_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core adverse event KPIs tracking incidence, severity, seriousness, and regulatory reporting performance across studies and sites"
  source: "`clinical_trials_ecm`.`safety`.`adverse_event`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Site ID"
      display_name: "Site ID"
      expr: investigational_site_id
      comment: "Unique identifier for the investigational site"
    - name: "Is Serious"
      display_name: "Serious AE Flag"
      expr: is_serious
      comment: "Flag indicating whether the adverse event meets seriousness criteria"
    - name: "Is SUSAR"
      display_name: "SUSAR Flag"
      expr: is_susar
      comment: "Flag indicating whether the event is a Suspected Unexpected Serious Adverse Reaction"
    - name: "Is TEAE"
      display_name: "TEAE Flag"
      expr: is_teae
      comment: "Flag indicating whether the event is a Treatment-Emergent Adverse Event"
    - name: "Severity"
      display_name: "Severity"
      expr: severity
      comment: "Severity or intensity grade of the adverse event"
    - name: "Outcome"
      display_name: "Outcome"
      expr: outcome
      comment: "Final outcome of the adverse event"
    - name: "CTCAE Grade"
      display_name: "CTCAE Grade"
      expr: ctcae_grade
      comment: "Common Terminology Criteria for Adverse Events grade (1-5)"
    - name: "MedDRA SOC"
      display_name: "MedDRA SOC"
      expr: meddra_soc_name
      comment: "MedDRA System Organ Class name for the adverse event"
    - name: "MedDRA PT"
      display_name: "MedDRA PT"
      expr: meddra_pt_name
      comment: "MedDRA Preferred Term name for the adverse event"
    - name: "Onset Year"
      display_name: "Onset Year"
      expr: DATE_TRUNC('year', onset_date)
      comment: "Year of adverse event onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Onset Quarter"
      display_name: "Onset Quarter"
      expr: DATE_TRUNC('quarter', onset_date)
      comment: "Quarter of adverse event onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Onset Month"
      display_name: "Onset Month"
      expr: DATE_TRUNC('month', onset_date)
      comment: "Month of adverse event onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Report Type"
      display_name: "Report Type"
      expr: report_type
      comment: "Type of regulatory report (initial, follow-up, etc.)"
  measures:
    - name: "Total Adverse Events"
      display_name: "Total AEs"
      expr: COUNT(1)
      comment: "Total count of adverse event records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects with AEs"
      display_name: "Subjects with AEs"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Count of unique subjects experiencing at least one adverse event"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Serious Adverse Events"
      display_name: "SAEs"
      expr: SUM(CAST(CASE WHEN is_serious = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of adverse events meeting seriousness criteria"
      format:
        type: number
        decimal_places:
          type: all
    - name: "SUSAR Count"
      display_name: "SUSARs"
      expr: SUM(CAST(CASE WHEN is_susar = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of Suspected Unexpected Serious Adverse Reactions requiring expedited reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Treatment-Emergent AEs"
      display_name: "TEAEs"
      expr: SUM(CAST(CASE WHEN is_teae = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of adverse events emerging during or after treatment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Grade 3-5 Events"
      display_name: "Grade 3+ AEs"
      expr: SUM(CAST(CASE WHEN ctcae_grade >= 3 THEN 1 ELSE 0 END AS INT))
      comment: "Count of severe, life-threatening, or fatal adverse events (CTCAE grade 3 or higher)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Seriousness Rate"
      display_name: "SAE Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_serious = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of adverse events meeting seriousness criteria"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "SUSAR Rate"
      display_name: "SUSAR Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN is_susar = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of adverse events classified as SUSARs"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Regulatory Reports Overdue"
      display_name: "Overdue Reports"
      expr: SUM(CASE WHEN regulatory_report_due_date < CURRENT_DATE() AND regulatory_report_submitted_date IS NULL THEN 1 ELSE 0 END)
      comment: "Count of adverse events with overdue regulatory reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "On-Time Reporting Rate"
      display_name: "On-Time Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN regulatory_report_submitted_date <= regulatory_report_due_date THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN regulatory_report_submitted_date IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0), 2)
      comment: "Percentage of regulatory reports submitted by deadline"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_serious_adverse_event`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Serious adverse event metrics tracking SAE incidence, causality, expectedness, and regulatory reporting timeliness"
  source: "`clinical_trials_ecm`.`safety`.`adverse_event`"
  dimensions:
    - name: "Study ID"
      display_name: "Study"
      expr: study_id
      comment: "Clinical study identifier"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Is SUSAR"
      display_name: "SUSAR Flag"
      expr: is_susar
      comment: "Whether the SAE is a Suspected Unexpected Serious Adverse Reaction"
    - name: "Causality Assessment"
      display_name: "Causality"
      expr: causality_assessment
      comment: "Investigator causality assessment (related, not related, possibly related, etc.)"
    - name: "Outcome"
      display_name: "SAE Outcome"
      expr: outcome
      comment: "Final outcome of the serious adverse event"
    - name: "CTCAE Grade"
      display_name: "CTCAE Grade"
      expr: ctcae_grade
      comment: "CTCAE severity grade (1-5)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DSMB Reported"
      display_name: "DSMB Reported"
      expr: dsmb_reported
      comment: "Whether the SAE was reported to the Data Safety Monitoring Board"
    - name: "Onset Year"
      display_name: "Onset Year"
      expr: DATE_TRUNC('year', onset_date)
      comment: "Year of SAE onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Onset Month"
      display_name: "Onset Month"
      expr: DATE_TRUNC('month', onset_date)
      comment: "Month of SAE onset"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total SAEs"
      display_name: "Total SAEs"
      expr: COUNT(1)
      comment: "Total count of serious adverse event records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects with SAEs"
      display_name: "Subjects with SAEs"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Count of distinct trial subjects experiencing at least one serious adverse event"
      format:
        type: number
        decimal_places:
          type: all
    - name: "SUSAR Count"
      display_name: "SUSARs"
      expr: SUM(CAST(CASE WHEN is_susar = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of SUSARs (Suspected Unexpected Serious Adverse Reactions)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Related SAEs"
      display_name: "Related SAEs"
      expr: SUM(CAST(CASE WHEN causality_assessment LIKE '%related%' OR causality_assessment LIKE '%Related%' THEN 1 ELSE 0 END AS INT))
      comment: "Count of SAEs assessed as related to investigational product"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Grade 4-5 SAEs"
      display_name: "Grade 4-5 SAEs"
      expr: SUM(CAST(CASE WHEN ctcae_grade >= 4 THEN 1 ELSE 0 END AS INT))
      comment: "Count of SAEs with CTCAE grade 4 (life-threatening) or 5 (death)"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DSMB Reported SAEs"
      display_name: "DSMB Reported SAEs"
      expr: SUM(CAST(CASE WHEN dsmb_reported = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of SAEs reported to Data Safety Monitoring Board"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Reports Overdue"
      display_name: "Overdue Reports"
      expr: SUM(CASE WHEN regulatory_report_due_date < CURRENT_DATE() THEN 1 ELSE 0 END)
      comment: "Count of SAEs with overdue regulatory reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "SUSAR Rate"
      display_name: "SUSAR Rate"
      expr: CAST(SUM(CAST(CASE WHEN is_susar = TRUE THEN 1 ELSE 0 END AS INT)) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of SAEs that are SUSARs (SUSAR count / total SAE count)"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Related SAE Rate"
      display_name: "Related SAE Rate"
      expr: CAST(SUM(CAST(CASE WHEN causality_assessment LIKE '%related%' OR causality_assessment LIKE '%Related%' THEN 1 ELSE 0 END AS INT)) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of SAEs assessed as related to investigational product"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_benefit_risk_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Benefit-risk assessment KPIs tracking evaluation frequency, conclusions, regulatory submission outcomes, and study continuation decisions"
  source: "`clinical_trials_ecm`.`safety`.`benefit_risk_assessment`"
  dimensions:
    - name: "Clinical Program ID"
      display_name: "Program ID"
      expr: clinical_program_id
      comment: "Unique identifier for the clinical development program"
    - name: "Assessment Status"
      display_name: "Status"
      expr: assessment_status
      comment: "Current status of the benefit-risk assessment"
    - name: "Assessment Type"
      display_name: "Type"
      expr: assessment_type
      comment: "Type of benefit-risk assessment (periodic, ad-hoc, regulatory-triggered, etc.)"
    - name: "Assessment Trigger"
      display_name: "Trigger"
      expr: assessment_trigger
      comment: "Event or milestone that triggered the benefit-risk assessment"
    - name: "Benefit-Risk Conclusion"
      display_name: "Conclusion"
      expr: benefit_risk_conclusion
      comment: "Overall conclusion of the benefit-risk assessment (favorable, unfavorable, uncertain)"
    - name: "Study Continuation Recommended"
      display_name: "Continue Study"
      expr: study_continuation_recommended
      comment: "Flag indicating whether assessment recommends continuing the study"
    - name: "Protocol Amendment Required"
      display_name: "Amendment Required"
      expr: protocol_amendment_required
      comment: "Flag indicating whether assessment recommends a protocol amendment"
    - name: "Regulatory Submission Required"
      display_name: "Reg Submission"
      expr: regulatory_submission_required
      comment: "Flag indicating whether assessment requires regulatory submission"
    - name: "IRB Notification Required"
      display_name: "IRB Notification"
      expr: irb_iec_notification_required
      comment: "Flag indicating whether assessment requires IRB/IEC notification"
    - name: "Assessment Year"
      display_name: "Assessment Year"
      expr: DATE_TRUNC('year', assessment_date)
      comment: "Year of benefit-risk assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Quarter"
      display_name: "Assessment Quarter"
      expr: DATE_TRUNC('quarter', assessment_date)
      comment: "Quarter of benefit-risk assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month of benefit-risk assessment"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Assessments"
      display_name: "Total Assessments"
      expr: COUNT(1)
      comment: "Total count of benefit-risk assessments conducted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Favorable Conclusions"
      display_name: "Favorable"
      expr: SUM(CAST(CASE WHEN benefit_risk_conclusion = 'Favorable' THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments with favorable benefit-risk conclusion"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unfavorable Conclusions"
      display_name: "Unfavorable"
      expr: SUM(CAST(CASE WHEN benefit_risk_conclusion = 'Unfavorable' THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments with unfavorable benefit-risk conclusion"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Study Continuation Rate"
      display_name: "Continuation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN study_continuation_recommended = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments recommending study continuation"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Protocol Amendments Required"
      display_name: "Amendments"
      expr: SUM(CAST(CASE WHEN protocol_amendment_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments requiring protocol amendments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Submissions Required"
      display_name: "Reg Submissions"
      expr: SUM(CAST(CASE WHEN regulatory_submission_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments requiring regulatory submission"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IRB Notifications Required"
      display_name: "IRB Notifications"
      expr: SUM(CAST(CASE WHEN irb_iec_notification_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments requiring IRB/IEC notification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total SAEs Reviewed"
      display_name: "SAEs Reviewed"
      expr: SUM(CAST(sae_count AS DOUBLE))
      comment: "Total number of serious adverse events reviewed across all assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total SUSARs Reviewed"
      display_name: "SUSARs Reviewed"
      expr: SUM(CAST(susar_count AS DOUBLE))
      comment: "Total number of SUSARs reviewed across all assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Subjects Exposed"
      display_name: "Subjects Exposed"
      expr: SUM(CAST(subjects_exposed_count AS DOUBLE))
      comment: "Total number of subjects exposed to investigational product across all assessments"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Days to Approval"
      display_name: "Avg Approval Days"
      expr: AVG(CAST(DATEDIFF(approval_date, assessment_date) AS DOUBLE))
      comment: "Average number of days from assessment completion to approval"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Days to IRB Notification"
      display_name: "Avg IRB Days"
      expr: AVG(CAST(DATEDIFF(irb_iec_notification_date, assessment_date) AS DOUBLE))
      comment: "Average number of days from assessment to IRB/IEC notification"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_dsmb_review`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Data Safety Monitoring Board review KPIs tracking meeting frequency, recommendations, stopping rules, and study continuation decisions"
  source: "`clinical_trials_ecm`.`safety`.`dsmb_review`"
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

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_expedited_report_deadline`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Expedited safety reporting deadline metrics tracking regulatory reporting timeliness, compliance, and overdue reports"
  source: "`clinical_trials_ecm`.`safety`.`expedited_report_deadline`"
  dimensions:
    - name: "Study ID"
      display_name: "Study"
      expr: study_id
      comment: "Clinical study identifier"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Regulatory Agency"
      display_name: "Regulatory Agency"
      expr: regulatory_agency
      comment: "Regulatory agency to which the report is submitted"
    - name: "Report Type"
      display_name: "Report Type"
      expr: report_type
      comment: "Type of expedited report (initial, follow-up, etc.)"
    - name: "Report Category"
      display_name: "Report Category"
      expr: report_category
      comment: "Category of expedited report (SUSAR, fatal SAE, etc.)"
    - name: "Deadline Status"
      display_name: "Deadline Status"
      expr: deadline_status
      comment: "Status of the reporting deadline (on-time, overdue, pending, etc.)"
    - name: "Is On Time"
      display_name: "On Time"
      expr: is_on_time
      comment: "Whether the report was submitted on or before the deadline"
    - name: "Is Fatal or Life Threatening"
      display_name: "Fatal/Life-Threatening"
      expr: is_fatal_or_life_threatening
      comment: "Whether the event was fatal or life-threatening"
    - name: "Is Unexpected"
      display_name: "Unexpected"
      expr: is_unexpected
      comment: "Whether the event was unexpected based on reference safety information"
    - name: "Follow-Up Required"
      display_name: "Follow-Up Required"
      expr: follow_up_required
      comment: "Whether a follow-up report is required"
    - name: "DSMB Notified"
      display_name: "DSMB Notified"
      expr: dsmb_notified
      comment: "Whether the DSMB was notified of the event"
    - name: "Waiver Granted"
      display_name: "Waiver Granted"
      expr: waiver_granted
      comment: "Whether a reporting waiver was granted"
    - name: "Submission Method"
      display_name: "Submission Method"
      expr: submission_method
      comment: "Method of report submission (e-gateway, email, fax, etc.)"
    - name: "Reporting Country"
      display_name: "Reporting Country"
      expr: reporting_country_code
      comment: "Country code for the regulatory authority"
    - name: "Awareness Year"
      display_name: "Awareness Year"
      expr: DATE_TRUNC('year', awareness_date)
      comment: "Year sponsor became aware of the event"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Awareness Month"
      display_name: "Awareness Month"
      expr: DATE_TRUNC('month', awareness_date)
      comment: "Month sponsor became aware of the event"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Year"
      display_name: "Submission Year"
      expr: DATE_TRUNC('year', submission_date)
      comment: "Year the report was submitted"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Submission Month"
      display_name: "Submission Month"
      expr: DATE_TRUNC('month', submission_date)
      comment: "Month the report was submitted"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Expedited Reports"
      display_name: "Total Expedited Reports"
      expr: COUNT(1)
      comment: "Total count of expedited report deadline records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "On-Time Reports"
      display_name: "On-Time Reports"
      expr: SUM(CAST(CASE WHEN is_on_time = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports submitted on or before the deadline"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Overdue Reports"
      display_name: "Overdue Reports"
      expr: SUM(CAST(CASE WHEN is_on_time = FALSE OR days_overdue > 0 THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports submitted after the deadline or currently overdue"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Fatal or Life-Threatening Reports"
      display_name: "Fatal/Life-Threatening Reports"
      expr: SUM(CAST(CASE WHEN is_fatal_or_life_threatening = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports for fatal or life-threatening events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unexpected Event Reports"
      display_name: "Unexpected Event Reports"
      expr: SUM(CAST(CASE WHEN is_unexpected = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports for unexpected events"
      format:
        type: number
        decimal_places:
          type: all
    - name: "7-Day Deadline Reports"
      display_name: "7-Day Deadline Reports"
      expr: SUM(CAST(CASE WHEN applicable_deadline_days = 7 THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports with a 7-day reporting deadline"
      format:
        type: number
        decimal_places:
          type: all
    - name: "15-Day Deadline Reports"
      display_name: "15-Day Deadline Reports"
      expr: SUM(CAST(CASE WHEN applicable_deadline_days = 15 THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports with a 15-day reporting deadline"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Follow-Up Reports Required"
      display_name: "Follow-Up Reports Required"
      expr: SUM(CAST(CASE WHEN follow_up_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports requiring follow-up"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DSMB Notified Reports"
      display_name: "DSMB Notified Reports"
      expr: SUM(CAST(CASE WHEN dsmb_notified = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports where DSMB was notified"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Waiver Granted Reports"
      display_name: "Waiver Granted Reports"
      expr: SUM(CAST(CASE WHEN waiver_granted = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reports where a reporting waiver was granted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Days Overdue"
      display_name: "Total Days Overdue"
      expr: SUM(CAST(days_overdue AS DOUBLE))
      comment: "Total cumulative days overdue across all late reports"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Days Overdue"
      display_name: "Avg Days Overdue"
      expr: AVG(CAST(days_overdue AS DOUBLE))
      comment: "Average number of days overdue for late reports"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "Avg Applicable Deadline Days"
      display_name: "Avg Deadline Days"
      expr: AVG(CAST(applicable_deadline_days AS DOUBLE))
      comment: "Average reporting deadline in days (typically 7 or 15)"
      format:
        type: number
        decimal_places:
          type: exact
          places: 1
    - name: "On-Time Reporting Rate"
      display_name: "On-Time Reporting Rate"
      expr: CAST(SUM(CAST(CASE WHEN is_on_time = TRUE THEN 1 ELSE 0 END AS INT)) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of reports submitted on or before the deadline"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Overdue Reporting Rate"
      display_name: "Overdue Reporting Rate"
      expr: CAST(SUM(CAST(CASE WHEN is_on_time = FALSE OR days_overdue > 0 THEN 1 ELSE 0 END AS INT)) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of reports submitted after the deadline or currently overdue"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Fatal or Life-Threatening Rate"
      display_name: "Fatal/Life-Threatening Rate"
      expr: CAST(SUM(CAST(CASE WHEN is_fatal_or_life_threatening = TRUE THEN 1 ELSE 0 END AS INT)) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of reports for fatal or life-threatening events"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Unexpected Event Rate"
      display_name: "Unexpected Event Rate"
      expr: CAST(SUM(CAST(CASE WHEN is_unexpected = TRUE THEN 1 ELSE 0 END AS INT)) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of reports for unexpected events"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "DSMB Notification Rate"
      display_name: "DSMB Notification Rate"
      expr: CAST(SUM(CAST(CASE WHEN dsmb_notified = TRUE THEN 1 ELSE 0 END AS INT)) AS DOUBLE) / NULLIF(CAST(COUNT(1) AS DOUBLE), 0)
      comment: "Proportion of reports where DSMB was notified"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_icsr`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Individual Case Safety Report KPIs tracking regulatory submission timeliness, acknowledgement rates, and SUSAR reporting compliance"
  source: "`clinical_trials_ecm`.`safety`.`icsr`"
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

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_reporting_obligation`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Regulatory reporting obligation KPIs tracking compliance requirements, reporting timelines, and obligation lifecycle management"
  source: "`clinical_trials_ecm`.`safety`.`reporting_obligation`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Clinical Program ID"
      display_name: "Program ID"
      expr: clinical_program_id
      comment: "Unique identifier for the clinical development program"
    - name: "Health Authority ID"
      display_name: "Authority ID"
      expr: health_authority_id
      comment: "Unique identifier for the regulatory health authority"
    - name: "Obligation Status"
      display_name: "Status"
      expr: obligation_status
      comment: "Current status of the reporting obligation (active, superseded, expired)"
    - name: "Reporting Category"
      display_name: "Category"
      expr: reporting_category
      comment: "Category of regulatory reporting (expedited, periodic, etc.)"
    - name: "Event Type"
      display_name: "Event Type"
      expr: event_type
      comment: "Type of event requiring reporting (SAE, SUSAR, etc.)"
    - name: "Seriousness Scope"
      display_name: "Seriousness"
      expr: seriousness_scope
      comment: "Scope of seriousness criteria covered by the obligation"
    - name: "Causality Scope"
      display_name: "Causality"
      expr: causality_scope
      comment: "Scope of causality assessment covered by the obligation"
    - name: "Country Code"
      display_name: "Country"
      expr: country_code
      comment: "ISO country code for the reporting obligation"
    - name: "Submission Format"
      display_name: "Format"
      expr: submission_format
      comment: "Required format for regulatory submission (E2B, MedWatch, etc.)"
  measures:
    - name: "Total Obligations"
      display_name: "Total Obligations"
      expr: COUNT(1)
      comment: "Total count of regulatory reporting obligations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Active Obligations"
      display_name: "Active"
      expr: SUM(CAST(CASE WHEN obligation_status = 'Active' THEN 1 ELSE 0 END AS INT))
      comment: "Count of currently active reporting obligations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Superseded Obligations"
      display_name: "Superseded"
      expr: SUM(CAST(CASE WHEN obligation_status = 'Superseded' THEN 1 ELSE 0 END AS INT))
      comment: "Count of reporting obligations superseded by newer versions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Expedited Reporting Obligations"
      display_name: "Expedited"
      expr: SUM(CAST(CASE WHEN reporting_category = 'Expedited' THEN 1 ELSE 0 END AS INT))
      comment: "Count of obligations requiring expedited reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Periodic Reporting Obligations"
      display_name: "Periodic"
      expr: SUM(CAST(CASE WHEN reporting_category = 'Periodic' THEN 1 ELSE 0 END AS INT))
      comment: "Count of obligations requiring periodic reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DSMB Notification Required"
      display_name: "DSMB Required"
      expr: SUM(CAST(CASE WHEN dsmb_notification_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of obligations requiring DSMB notification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IRB Notification Required"
      display_name: "IRB Required"
      expr: SUM(CAST(CASE WHEN irb_iec_notification_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of obligations requiring IRB/IEC notification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Investigator Notification Required"
      display_name: "Investigator Required"
      expr: SUM(CAST(CASE WHEN investigator_notification_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of obligations requiring investigator notification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Reporting Clock Days"
      display_name: "Avg Clock Days"
      expr: AVG(CAST(reporting_clock_days AS DOUBLE))
      comment: "Average number of calendar days allowed for regulatory reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Follow-Up Clock Days"
      display_name: "Avg Follow-Up Days"
      expr: AVG(CAST(follow_up_clock_days AS DOUBLE))
      comment: "Average number of calendar days allowed for follow-up reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Escalation Alert Days"
      display_name: "Avg Alert Days"
      expr: AVG(CAST(escalation_alert_days AS DOUBLE))
      comment: "Average number of days before deadline when escalation alert is triggered"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Countries"
      display_name: "Countries"
      expr: COUNT(DISTINCT country_code)
      comment: "Count of unique countries with reporting obligations"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_signal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Safety signal detection and evaluation KPIs tracking signal identification, assessment cycle time, and regulatory action outcomes"
  source: "`clinical_trials_ecm`.`safety`.`signal`"
  dimensions:
    - name: "Study ID"
      display_name: "Study ID"
      expr: study_id
      comment: "Unique identifier for the clinical study"
    - name: "Clinical Program ID"
      display_name: "Program ID"
      expr: clinical_program_id
      comment: "Unique identifier for the clinical development program"
    - name: "Signal Status"
      display_name: "Signal Status"
      expr: signal_status
      comment: "Current status of the safety signal (open, under evaluation, closed, etc.)"
    - name: "Priority"
      display_name: "Priority"
      expr: priority
      comment: "Priority level assigned to the safety signal"
    - name: "Detection Method"
      display_name: "Detection Method"
      expr: detection_method
      comment: "Method used to detect the safety signal (statistical, clinical review, etc.)"
    - name: "Final Disposition"
      display_name: "Final Disposition"
      expr: final_disposition
      comment: "Final outcome of signal evaluation (confirmed, refuted, requires further monitoring)"
    - name: "DSMB Referred"
      display_name: "DSMB Referred"
      expr: is_dsmb_referred
      comment: "Flag indicating whether signal was referred to Data Safety Monitoring Board"
    - name: "Expedited Reporting Required"
      display_name: "Expedited Reporting"
      expr: is_expedited_reporting_required
      comment: "Flag indicating whether signal requires expedited regulatory reporting"
    - name: "Detection Year"
      display_name: "Detection Year"
      expr: DATE_TRUNC('year', detection_date)
      comment: "Year of signal detection"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Detection Quarter"
      display_name: "Detection Quarter"
      expr: DATE_TRUNC('quarter', detection_date)
      comment: "Quarter of signal detection"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Detection Month"
      display_name: "Detection Month"
      expr: DATE_TRUNC('month', detection_date)
      comment: "Month of signal detection"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Signals"
      display_name: "Total Signals"
      expr: COUNT(1)
      comment: "Total count of safety signals detected"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Open Signals"
      display_name: "Open Signals"
      expr: SUM(CASE WHEN signal_status IN ('Open', 'Under Evaluation') THEN 1 ELSE 0 END)
      comment: "Count of signals currently open or under evaluation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Confirmed Signals"
      display_name: "Confirmed Signals"
      expr: SUM(CAST(CASE WHEN final_disposition = 'Confirmed' THEN 1 ELSE 0 END AS INT))
      comment: "Count of signals confirmed as true safety concerns"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Refuted Signals"
      display_name: "Refuted Signals"
      expr: SUM(CAST(CASE WHEN final_disposition = 'Refuted' THEN 1 ELSE 0 END AS INT))
      comment: "Count of signals refuted after evaluation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "DSMB Referrals"
      display_name: "DSMB Referrals"
      expr: SUM(CAST(CASE WHEN is_dsmb_referred = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of signals referred to Data Safety Monitoring Board"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Signals Requiring Expedited Reporting"
      display_name: "Expedited Signals"
      expr: SUM(CAST(CASE WHEN is_expedited_reporting_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of signals requiring expedited regulatory reporting"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Evaluation Cycle Days"
      display_name: "Avg Eval Days"
      expr: AVG(CAST(DATEDIFF(evaluation_completion_date, evaluation_start_date) AS DOUBLE))
      comment: "Average number of days to complete signal evaluation from start to completion"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Contributing Cases"
      display_name: "Total Cases"
      expr: SUM(CAST(case_count AS DOUBLE))
      comment: "Total number of adverse event cases contributing to all signals"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Avg Cases per Signal"
      display_name: "Avg Cases/Signal"
      expr: AVG(CAST(case_count AS DOUBLE))
      comment: "Average number of adverse event cases per safety signal"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Overdue Evaluations"
      display_name: "Overdue Evals"
      expr: SUM(CASE WHEN evaluation_due_date < CURRENT_DATE() AND evaluation_completion_date IS NULL THEN 1 ELSE 0 END)
      comment: "Count of signals with overdue evaluation completion dates"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Confirmation Rate"
      display_name: "Confirmation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN final_disposition = 'Confirmed' THEN 1 ELSE 0 END AS INT)) / NULLIF(SUM(CAST(CASE WHEN final_disposition IS NOT NULL THEN 1 ELSE 0 END AS INT)), 0), 2)
      comment: "Percentage of evaluated signals confirmed as true safety concerns"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_ecm`.`_metrics`.`safety_susar`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "SUSAR-specific KPIs tracking expedited reporting compliance, causality assessment, and regulatory submission performance"
  source: "`clinical_trials_ecm`.`safety`.`susar`"
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
