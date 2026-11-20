-- Metric views for domain: consent | Business: Clinical_Trials | Version: 19 | Generated on: 2026-11-20 12:39:51

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`consent_capacity_assessment`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Capacity assessment KPIs tracking assessment outcomes, vulnerable population identification, LAR requirement rates, and reassessment compliance."
  source: "`clinical_trials_mvm`.`consent`.`capacity_assessment`"
  dimensions:
    - name: "Assessment Outcome"
      display_name: "Assessment Outcome"
      expr: assessment_outcome
      comment: "Outcome of the capacity assessment (e.g., Capacity Confirmed, Capacity Impaired, Indeterminate)"
    - name: "Assessment Type"
      display_name: "Assessment Type"
      expr: assessment_type
      comment: "Type of capacity assessment (e.g., Initial, Reassessment, Triggered)"
    - name: "Assessment Tool"
      display_name: "Assessment Tool"
      expr: assessment_tool
      comment: "Tool or instrument used for capacity assessment (e.g., UBACC, MacCAT-CR, Custom)"
    - name: "Assessment Status"
      display_name: "Assessment Status"
      expr: assessment_status
      comment: "Current status of the assessment (e.g., Completed, Pending Review, Approved)"
    - name: "Assessor Role"
      display_name: "Assessor Role"
      expr: assessor_role
      comment: "Role of the person who performed the assessment (e.g., Physician, Psychologist, Qualified Designee)"
    - name: "Vulnerability Category"
      display_name: "Vulnerability Category"
      expr: vulnerability_category
      comment: "Category of vulnerable population (e.g., Cognitive Impairment, Pediatric, Elderly, Psychiatric)"
    - name: "LAR Required Flag"
      display_name: "LAR Required"
      expr: lar_required
      comment: "Whether a legally authorized representative is required based on assessment"
    - name: "Reassessment Required Flag"
      display_name: "Reassessment Required"
      expr: reassessment_required
      comment: "Whether reassessment is required at a future date"
    - name: "Vulnerable Population Flag"
      display_name: "Vulnerable Population"
      expr: vulnerable_population_flag
      comment: "Whether the subject is classified as a vulnerable population"
    - name: "IRB Notification Required Flag"
      display_name: "IRB Notification Required"
      expr: irb_iec_notification_required
      comment: "Whether IRB/IEC notification is required based on assessment outcome"
    - name: "Assessment Year"
      display_name: "Assessment Year"
      expr: DATE_TRUNC('year', assessment_date)
      comment: "Year in which the capacity assessment was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Assessment Month"
      display_name: "Assessment Month"
      expr: DATE_TRUNC('month', assessment_date)
      comment: "Month in which the capacity assessment was performed"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Capacity Assessments"
      display_name: "Total Capacity Assessments"
      expr: COUNT(1)
      comment: "Total number of capacity assessments performed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects Assessed"
      display_name: "Unique Subjects Assessed"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Distinct count of trial subjects who underwent capacity assessment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Assessments with Capacity Confirmed"
      display_name: "Assessments with Capacity Confirmed"
      expr: SUM(CAST(CASE WHEN assessment_outcome = 'Capacity Confirmed' THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments where capacity was confirmed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Capacity Confirmation Rate"
      display_name: "Capacity Confirmation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN assessment_outcome = 'Capacity Confirmed' THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments confirming capacity — subject autonomy and eligibility metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Assessments Requiring LAR"
      display_name: "Assessments Requiring LAR"
      expr: SUM(CAST(CASE WHEN lar_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments requiring legally authorized representative involvement"
      format:
        type: number
        decimal_places:
          type: all
    - name: "LAR Requirement Rate"
      display_name: "LAR Requirement Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN lar_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments requiring LAR — vulnerable population enrollment indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Vulnerable Population Assessments"
      display_name: "Vulnerable Population Assessments"
      expr: SUM(CAST(CASE WHEN vulnerable_population_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments for vulnerable populations"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Vulnerable Population Rate"
      display_name: "Vulnerable Population Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN vulnerable_population_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments for vulnerable populations — ethical oversight and protection metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Assessments Requiring Reassessment"
      display_name: "Assessments Requiring Reassessment"
      expr: SUM(CAST(CASE WHEN reassessment_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments requiring future reassessment"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Reassessment Requirement Rate"
      display_name: "Reassessment Requirement Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN reassessment_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments requiring reassessment — ongoing monitoring burden metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Assessments Requiring IRB Notification"
      display_name: "Assessments Requiring IRB Notification"
      expr: SUM(CAST(CASE WHEN irb_iec_notification_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments requiring IRB/IEC notification"
      format:
        type: number
        decimal_places:
          type: all
    - name: "IRB Notification Requirement Rate"
      display_name: "IRB Notification Requirement Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN irb_iec_notification_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of assessments requiring IRB notification — ethics oversight compliance metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Assessment Score"
      display_name: "Average Assessment Score"
      expr: AVG(CAST(assessment_score AS DOUBLE))
      comment: "Mean capacity assessment score across all assessments"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "IRB Notified Assessments"
      display_name: "IRB Notified Assessments"
      expr: SUM(CAST(CASE WHEN irb_iec_notification_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of assessments for which IRB/IEC was actually notified"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`consent_econsent_session`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "eConsent platform performance and subject engagement KPIs tracking session completion, comprehension pass rates, technical issues, and digital signature capture."
  source: "`clinical_trials_mvm`.`consent`.`econsent_session`"
  dimensions:
    - name: "Session Status"
      display_name: "Session Status"
      expr: session_status
      comment: "Current status of the eConsent session (e.g., Completed, In Progress, Abandoned)"
    - name: "Session Modality"
      display_name: "Session Modality"
      expr: session_modality
      comment: "Modality of the eConsent session (e.g., In-Person, Remote, Hybrid)"
    - name: "Device Type"
      display_name: "Device Type"
      expr: device_type
      comment: "Type of device used for eConsent (e.g., Tablet, Desktop, Mobile)"
    - name: "Session Language"
      display_name: "Session Language"
      expr: session_language
      comment: "Language in which the eConsent session was conducted"
    - name: "Consent Granted Flag"
      display_name: "Consent Granted"
      expr: consent_granted
      comment: "Whether consent was granted at the end of the session"
    - name: "Comprehension Passed Flag"
      display_name: "Comprehension Passed"
      expr: comprehension_overall_passed
      comment: "Whether the subject passed the overall comprehension check"
    - name: "Technical Issue Flag"
      display_name: "Technical Issue Encountered"
      expr: technical_issue_encountered
      comment: "Whether a technical issue was encountered during the session"
    - name: "eSignature Captured Flag"
      display_name: "eSignature Captured"
      expr: esignature_captured
      comment: "Whether an electronic signature was successfully captured"
    - name: "Interpreter Used Flag"
      display_name: "Interpreter Used"
      expr: interpreter_used
      comment: "Whether an interpreter was used during the session"
    - name: "Session Year"
      display_name: "Session Year"
      expr: DATE_TRUNC('year', session_start_timestamp)
      comment: "Year in which the eConsent session started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Session Month"
      display_name: "Session Month"
      expr: DATE_TRUNC('month', session_start_timestamp)
      comment: "Month in which the eConsent session started"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total eConsent Sessions"
      display_name: "Total eConsent Sessions"
      expr: COUNT(1)
      comment: "Total number of eConsent sessions initiated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects in Sessions"
      display_name: "Unique Subjects in Sessions"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Distinct count of trial subjects who initiated eConsent sessions"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Sessions with Consent Granted"
      display_name: "Sessions with Consent Granted"
      expr: SUM(CAST(CASE WHEN consent_granted = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of sessions where consent was granted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Consent Conversion Rate"
      display_name: "Consent Conversion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN consent_granted = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of eConsent sessions resulting in granted consent — key enrollment efficiency metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Sessions with Comprehension Pass"
      display_name: "Sessions with Comprehension Pass"
      expr: SUM(CAST(CASE WHEN comprehension_overall_passed = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of sessions where subject passed comprehension check"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Comprehension Pass Rate"
      display_name: "Comprehension Pass Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN comprehension_overall_passed = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sessions with comprehension pass — informed consent quality indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Comprehension Questions Passed"
      display_name: "Average Comprehension Questions Passed"
      expr: AVG(CAST(comprehension_questions_passed AS DOUBLE))
      comment: "Mean number of comprehension questions passed per session"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Average Comprehension Questions Total"
      display_name: "Average Comprehension Questions Total"
      expr: AVG(CAST(comprehension_questions_total AS DOUBLE))
      comment: "Mean total number of comprehension questions per session"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Sessions with Technical Issues"
      display_name: "Sessions with Technical Issues"
      expr: SUM(CAST(CASE WHEN technical_issue_encountered = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of sessions where technical issues were encountered"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Technical Issue Rate"
      display_name: "Technical Issue Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN technical_issue_encountered = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sessions with technical issues — platform reliability and user experience metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "eSignatures Captured"
      display_name: "eSignatures Captured"
      expr: SUM(CAST(CASE WHEN esignature_captured = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of sessions where electronic signature was captured"
      format:
        type: number
        decimal_places:
          type: all
    - name: "eSignature Capture Rate"
      display_name: "eSignature Capture Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN esignature_captured = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sessions with successful eSignature capture — digital consent completion metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Review Steps Completed"
      display_name: "Average Review Steps Completed"
      expr: AVG(CAST(review_steps_completed AS DOUBLE))
      comment: "Mean number of review steps completed per session — engagement depth indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Sessions Requiring Remediation"
      display_name: "Sessions Requiring Remediation"
      expr: SUM(CAST(CASE WHEN remediation_provided = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of sessions where remediation was provided after failed comprehension"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Remediation Rate"
      display_name: "Remediation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN remediation_provided = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of sessions requiring remediation — indicates consent complexity or subject comprehension challenges"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`consent_reconsent_trigger`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Reconsent trigger and campaign management KPIs tracking trigger types, affected subject populations, reconsent completion rates, and regulatory compliance."
  source: "`clinical_trials_mvm`.`consent`.`reconsent_trigger`"
  dimensions:
    - name: "Trigger Type"
      display_name: "Trigger Type"
      expr: trigger_type
      comment: "Type of reconsent trigger (e.g., Protocol Amendment, Safety Update, ICF Revision, Regulatory Directive)"
    - name: "Resolution Status"
      display_name: "Resolution Status"
      expr: resolution_status
      comment: "Current resolution status of the reconsent trigger (e.g., Open, In Progress, Completed, Closed)"
    - name: "Subject Scope"
      display_name: "Subject Scope"
      expr: subject_scope
      comment: "Scope of subjects affected (e.g., All Active Subjects, Specific Cohort, Single Site)"
    - name: "Escalation Required Flag"
      display_name: "Escalation Required"
      expr: escalation_required
      comment: "Whether escalation to senior management or sponsor is required"
    - name: "Capacity Assessment Required Flag"
      display_name: "Capacity Assessment Required"
      expr: capacity_assessment_required
      comment: "Whether capacity assessment is required as part of reconsent"
    - name: "Protocol Deviation Raised Flag"
      display_name: "Protocol Deviation Raised"
      expr: protocol_deviation_raised
      comment: "Whether a protocol deviation was raised in connection with this trigger"
    - name: "Subject Withdrawal Flag"
      display_name: "Subject Withdrawal Flag"
      expr: subject_withdrawal_flag
      comment: "Whether any subjects withdrew as a result of this reconsent trigger"
    - name: "Trigger Year"
      display_name: "Trigger Year"
      expr: DATE_TRUNC('year', trigger_date)
      comment: "Year in which the reconsent trigger was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Trigger Month"
      display_name: "Trigger Month"
      expr: DATE_TRUNC('month', trigger_date)
      comment: "Month in which the reconsent trigger was initiated"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "Total Reconsent Triggers"
      display_name: "Total Reconsent Triggers"
      expr: COUNT(1)
      comment: "Total number of reconsent triggers initiated"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Affected Subjects"
      display_name: "Total Affected Subjects"
      expr: SUM(CAST(affected_subject_count AS DOUBLE))
      comment: "Total count of subjects affected by reconsent triggers"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Total Reconsented Subjects"
      display_name: "Total Reconsented Subjects"
      expr: SUM(CAST(reconsented_subject_count AS DOUBLE))
      comment: "Total count of subjects who completed reconsent"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Reconsent Completion Rate"
      display_name: "Reconsent Completion Rate"
      expr: ROUND(100.0 * SUM(CAST(reconsented_subject_count AS DOUBLE)) / NULLIF(SUM(CAST(affected_subject_count AS DOUBLE)), 0), 2)
      comment: "Percentage of affected subjects who completed reconsent — campaign effectiveness and subject retention metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Affected Subjects per Trigger"
      display_name: "Average Affected Subjects per Trigger"
      expr: AVG(CAST(affected_subject_count AS DOUBLE))
      comment: "Mean number of subjects affected per reconsent trigger — impact scope indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "Triggers Requiring Escalation"
      display_name: "Triggers Requiring Escalation"
      expr: SUM(CAST(CASE WHEN escalation_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reconsent triggers requiring escalation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Escalation Rate"
      display_name: "Escalation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN escalation_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reconsent triggers requiring escalation — complexity and risk indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Triggers with Protocol Deviation"
      display_name: "Triggers with Protocol Deviation"
      expr: SUM(CAST(CASE WHEN protocol_deviation_raised = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reconsent triggers that resulted in protocol deviation"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Protocol Deviation Rate"
      display_name: "Protocol Deviation Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN protocol_deviation_raised = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reconsent triggers resulting in protocol deviation — compliance impact metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Triggers with Subject Withdrawal"
      display_name: "Triggers with Subject Withdrawal"
      expr: SUM(CAST(CASE WHEN subject_withdrawal_flag = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of reconsent triggers that resulted in subject withdrawal"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Subject Withdrawal Rate"
      display_name: "Subject Withdrawal Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN subject_withdrawal_flag = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reconsent triggers resulting in subject withdrawal — retention risk metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Completed Reconsent Campaigns"
      display_name: "Completed Reconsent Campaigns"
      expr: SUM(CAST(CASE WHEN reconsent_completed_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of reconsent triggers that have been completed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Campaign Completion Rate"
      display_name: "Campaign Completion Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN reconsent_completed_date IS NOT NULL THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of reconsent campaigns completed — operational efficiency and compliance closure metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Reminder Count"
      display_name: "Average Reminder Count"
      expr: AVG(CAST(reminder_count AS DOUBLE))
      comment: "Mean number of reminders sent per reconsent trigger — subject engagement effort indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`consent_subject`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core consent KPI view – tracks consent volume, grant outcomes, comprehension quality and re‑consent activity"
  source: "`clinical_trials_mvm`.`consent`.`consent_subject_consent`"
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier the consent belongs to"
    - name: "study_site_id"
      display_name: "Study Site Id"
      expr: study_site_id
      comment: "Study site identifier"
    - name: "trial_subject_id"
      display_name: "Trial Subject Id"
      expr: trial_subject_id
      comment: "Subject identifier"
    - name: "consent_type"
      display_name: "Consent Type"
      expr: consent_type
      comment: "Type of consent (e.g., e‑consent, paper)"
    - name: "consent_method"
      display_name: "Consent Method"
      expr: consent_method
      comment: "Method used to obtain consent"
    - name: "consent_status"
      display_name: "Consent Status"
      expr: consent_status
      comment: "Current status of the consent record"
    - name: "consent_date"
      display_name: "Consent Date"
      expr: consent_date
      comment: "Date the consent was recorded"
    - name: "consent_year"
      display_name: "Consent Year"
      expr: DATE_TRUNC('year', consent_date)
      comment: "Year bucket for consent date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "consent_month"
      display_name: "Consent Month"
      expr: DATE_TRUNC('month', consent_date)
      comment: "Month bucket for consent date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_consents"
      display_name: "Total Consents"
      expr: COUNT(1)
      comment: "Total number of consent records captured"
      format:
        type: number
        decimal_places:
          type: all
    - name: "granted_consents"
      display_name: "Granted Consents"
      expr: COUNT(CASE WHEN consent_status = 'Granted' THEN 1 END)
      comment: "Count of consents where status indicates consent was granted"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_comprehension_score"
      display_name: "Average Comprehension Score"
      expr: AVG(CAST(comprehension_assessment_score AS DOUBLE))
      comment: "Mean score of comprehension assessments for consents"
      format:
        type: number
        decimal_places:
          type: all
    - name: "reconsent_required_count"
      display_name: "Reconsent Required Count"
      expr: COUNT(CASE WHEN reconsent_required = TRUE THEN 1 END)
      comment: "Number of consents that required a re‑consent"
      format:
        type: number
        decimal_places:
          type: all
    - name: "data_use_after_withdrawal_count"
      display_name: "Data Use After Withdrawal Count"
      expr: COUNT(CASE WHEN data_use_after_withdrawal = TRUE THEN 1 END)
      comment: "Count of consents where data may be used after subject withdrawal"
      format:
        type: number
        decimal_places:
          type: all
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`consent_subject_consent`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Core consent KPIs tracking consent acquisition, reconsent activity, withdrawal rates, and comprehension assessment outcomes for clinical trial subjects."
  source: "`clinical_trials_mvm`.`consent`.`consent_subject_consent`"
  dimensions:
    - name: "Consent Status"
      display_name: "Consent Status"
      expr: consent_status
      comment: "Current status of the subject consent (e.g., Active, Withdrawn, Pending)"
    - name: "Consent Type"
      display_name: "Consent Type"
      expr: consent_type
      comment: "Type of consent obtained (e.g., Informed Consent, Assent, LAR Consent)"
    - name: "Consent Method"
      display_name: "Consent Method"
      expr: consent_method
      comment: "Method by which consent was obtained (e.g., eConsent, Paper, Verbal)"
    - name: "GDPR Lawful Basis"
      display_name: "GDPR Lawful Basis"
      expr: gdpr_lawful_basis
      comment: "GDPR Article 6 lawful basis for processing (e.g., Consent, Legitimate Interest)"
    - name: "Consent Year"
      display_name: "Consent Year"
      expr: DATE_TRUNC('year', consent_date)
      comment: "Year in which consent was obtained"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Consent Quarter"
      display_name: "Consent Quarter"
      expr: DATE_TRUNC('quarter', consent_date)
      comment: "Quarter in which consent was obtained"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "Consent Month"
      display_name: "Consent Month"
      expr: DATE_TRUNC('month', consent_date)
      comment: "Month in which consent was obtained"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "LAR Involved Flag"
      display_name: "LAR Involved"
      expr: lar_involved
      comment: "Whether a legally authorized representative was involved in the consent process"
    - name: "Reconsent Required Flag"
      display_name: "Reconsent Required"
      expr: reconsent_required
      comment: "Whether reconsent is required for this subject"
    - name: "Witness Required Flag"
      display_name: "Witness Required"
      expr: witness_required
      comment: "Whether a witness signature was required for this consent"
    - name: "Capacity Assessment Performed Flag"
      display_name: "Capacity Assessment Performed"
      expr: capacity_assessment_performed
      comment: "Whether a capacity assessment was performed prior to consent"
    - name: "HIPAA Authorization Obtained Flag"
      display_name: "HIPAA Authorization Obtained"
      expr: hipaa_authorization_obtained
      comment: "Whether HIPAA authorization was obtained as part of the consent process"
  measures:
    - name: "Total Consents"
      display_name: "Total Consents"
      expr: COUNT(1)
      comment: "Total number of subject consent records"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Unique Subjects Consented"
      display_name: "Unique Subjects Consented"
      expr: COUNT(DISTINCT trial_subject_id)
      comment: "Distinct count of trial subjects who have provided consent"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Consents Requiring Reconsent"
      display_name: "Consents Requiring Reconsent"
      expr: SUM(CAST(CASE WHEN reconsent_required = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of consents flagged as requiring reconsent"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Reconsent Rate"
      display_name: "Reconsent Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN reconsent_required = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of consents requiring reconsent — key compliance and protocol amendment impact metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Withdrawn Consents"
      display_name: "Withdrawn Consents"
      expr: SUM(CAST(CASE WHEN withdrawal_date IS NOT NULL THEN 1 ELSE 0 END AS INT))
      comment: "Count of consents that have been withdrawn by subjects"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Withdrawal Rate"
      display_name: "Withdrawal Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN withdrawal_date IS NOT NULL THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of consents withdrawn — critical retention and subject satisfaction indicator"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "LAR Consents"
      display_name: "LAR Consents"
      expr: SUM(CAST(CASE WHEN lar_involved = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of consents involving a legally authorized representative"
      format:
        type: number
        decimal_places:
          type: all
    - name: "LAR Involvement Rate"
      display_name: "LAR Involvement Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN lar_involved = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of consents requiring LAR involvement — indicates vulnerable population enrollment"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Capacity Assessments Performed"
      display_name: "Capacity Assessments Performed"
      expr: SUM(CAST(CASE WHEN capacity_assessment_performed = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of consents where capacity assessment was performed"
      format:
        type: number
        decimal_places:
          type: all
    - name: "Capacity Assessment Rate"
      display_name: "Capacity Assessment Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN capacity_assessment_performed = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of consents with capacity assessment — compliance metric for vulnerable populations"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "Average Comprehension Score"
      display_name: "Average Comprehension Score"
      expr: AVG(CAST(comprehension_assessment_score AS DOUBLE))
      comment: "Mean comprehension assessment score across all consents — quality of informed consent indicator"
      format:
        type: number
        decimal_places:
          type: exact
          places: 2
    - name: "HIPAA Authorizations Obtained"
      display_name: "HIPAA Authorizations Obtained"
      expr: SUM(CAST(CASE WHEN hipaa_authorization_obtained = TRUE THEN 1 ELSE 0 END AS INT))
      comment: "Count of consents with HIPAA authorization obtained"
      format:
        type: number
        decimal_places:
          type: all
    - name: "HIPAA Authorization Rate"
      display_name: "HIPAA Authorization Rate"
      expr: ROUND(100.0 * SUM(CAST(CASE WHEN hipaa_authorization_obtained = TRUE THEN 1 ELSE 0 END AS INT)) / NULLIF(COUNT(1), 0), 2)
      comment: "Percentage of consents with HIPAA authorization — US regulatory compliance metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
    - name: "eConsent Completion Percentage"
      display_name: "Average eConsent Completion %"
      expr: AVG(CAST(econsent_completion_pct AS DOUBLE))
      comment: "Mean eConsent completion percentage — digital consent process efficiency metric"
      format:
        type: percentage
        decimal_places:
          type: exact
          places: 2
$$;

CREATE OR REPLACE VIEW `clinical_trials_mvm`.`_metrics`.`consent_withdrawal`
WITH METRICS
LANGUAGE YAML
AS $$
  version: 1.1
  comment: "Withdrawal KPI view – monitors withdrawal volume, timeliness relative to consent, and regulatory notification requirements"
  source: "`clinical_trials_mvm`.`consent`.`withdrawal`"
  joins:
    - name: dim_consent_subject_consent
      source: "`clinical_trials_mvm`.`consent`.`consent_subject_consent`"
      'on': source.consent_subject_consent_id = dim_consent_subject_consent.consent_subject_consent_id
      rely:
        at_most_one_match: true
  dimensions:
    - name: "study_id"
      display_name: "Study Id"
      expr: study_id
      comment: "Study identifier associated with the withdrawal"
    - name: "study_site_id"
      display_name: "Study Site Id"
      expr: study_site_id
      comment: "Study site identifier"
    - name: "trial_subject_id"
      display_name: "Trial Subject Id"
      expr: trial_subject_id
      comment: "Subject identifier"
    - name: "withdrawal_reason"
      display_name: "Withdrawal Reason"
      expr: withdrawal_reason
      comment: "Reason provided for withdrawal"
    - name: "withdrawal_type"
      display_name: "Withdrawal Type"
      expr: withdrawal_type
      comment: "Categorization of withdrawal (e.g., voluntary, safety)"
    - name: "withdrawal_status"
      display_name: "Withdrawal Status"
      expr: withdrawal_status
      comment: "Current status of the withdrawal process"
    - name: "withdrawal_date"
      display_name: "Withdrawal Date"
      expr: withdrawal_date
      comment: "Date the withdrawal was recorded"
    - name: "withdrawal_year"
      display_name: "Withdrawal Year"
      expr: DATE_TRUNC('year', withdrawal_date)
      comment: "Year bucket for withdrawal date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
    - name: "withdrawal_month"
      display_name: "Withdrawal Month"
      expr: DATE_TRUNC('month', withdrawal_date)
      comment: "Month bucket for withdrawal date"
      format:
        type: date
        date_format: year_month_day
        leading_zeros: true
  measures:
    - name: "total_withdrawals"
      display_name: "Total Withdrawals"
      expr: COUNT(1)
      comment: "Total number of withdrawal events recorded"
      format:
        type: number
        decimal_places:
          type: all
    - name: "avg_days_to_withdrawal"
      display_name: "Average Days to Withdrawal"
      expr: AVG(CAST(DATEDIFF(withdrawal_date, dim_consent_subject_consent.consent_date) AS DOUBLE))
      comment: "Mean number of days between consent and subsequent withdrawal"
      format:
        type: number
        decimal_places:
          type: all
    - name: "irb_notification_required_count"
      display_name: "IRB Notification Required Count"
      expr: COUNT(CASE WHEN irb_iec_notification_required = TRUE THEN 1 END)
      comment: "Count of withdrawals where IRB/IEC notification was required"
      format:
        type: number
        decimal_places:
          type: all
$$;
